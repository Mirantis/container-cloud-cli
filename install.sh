#!/usr/bin/env bash

HEADERS=""
BEARER_TOKEN=${BEARER_TOKEN:-}
ORGANIZATION=${ORGANIZATION:-Mirantis}
REPOSITORY=${REPOSITORY:-container-cloud-cli}
VERSION=${VERSION:-v0.0.1-alpha2}
API_VERSION=${VERSION}
OUTPUT_DIR=${OUTPUT_DIR:-/usr/local/lib/docker/cli-plugins}
WORK_DIR=$(mktemp -d)

trap "rm -rf ${WORK_DIR}" EXIT

if [ "${VERSION}" != "latest" ]; then
    API_VERSION="tags/${VERSION}"
fi

if [ -n "${BEARER_TOKEN}" ]; then
    HEADERS="-H 'Authorization: Bearer ${BEARER_TOKEN}'"
fi

if [ ! -d "${OUTPUT_DIR}" ]; then
    RESULT=$(mkdir -p "${OUTPUT_DIR}" 2>&1)
    if [ $? -ne 0 ]; then
        echo "failed to create ${OUTPUT_DIR}: ${RESULT}"
        exit 1
    fi
fi

if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
    ASSET_NAME="docker-containercloud-linux-amd64"
elif [[ "${OSTYPE}" == "darwin"* ]]; then
    ASSET_NAME="docker-containercloud-darwin-amd64"
else
    echo "Unsupported OS type ${OSTYPE}"
    exit 1
fi

# The docker CLI must be installed
which docker &>/dev/null
if [ $? -ne 0 ]; then
    echo "The docker CLI must be installed in order to install the Container Cloud plugin"
    exit 1
fi

# We depend on cURL and jq. If we have a connection to the
# docker daemon, then we can run them as containers. Otherwise,
# they need to be installed.
CURL="curl -fsSL 2>&1"
JQ="jq"

docker version &>/dev/null
if [ $? -eq 0 ]; then
    CURL="docker run --rm curlimages/curl:7.72.0 ${CURL}"
    JQ="docker run --rm -i stedolan/jq:latest"
else
    which curl &>/dev/null
    if [ $? -ne 0 ]; then
        echo "You must have cURL installed or be connected to a docker daemon"
        exit 1
    fi

    which jq &>/dev/null
    if [ $? -ne 0 ]; then
        echo "You must have jq installed or be connected to a docker daemon"
        exit 1
    fi
fi

echo "Installing Docker Enterprise Container Cloud CLI plugin version ${VERSION}"

# Fetch the release metadata in order to determine the asset ID of the binary
RELEASE=$(eval "${CURL} ${HEADERS} https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/releases/${API_VERSION}")
if [ $? -ne 0 ]; then
    echo "failed to get release for version ${VERSION}: ${RELEASE}"
    exit 1
fi

# Get the asset ID from the release metadata
ASSET_ID=$(echo "${RELEASE}" | ${JQ} ".assets[] | select(.name == \"${ASSET_NAME}\") | .id")
if [[ ! "${ASSET_ID}" =~ ^[0-9]+$ ]]; then
    echo "failed to get asset ID from release"
    exit 1
fi

# Fetch the plugin binary
RESULT=$(eval "${CURL} ${HEADERS} -H 'Accept: application/octet-stream' https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/releases/assets/${ASSET_ID} > ${WORK_DIR}/docker-containercloud")
if [ $? -ne 0 ]; then
    echo "failed to fetch asset ${ASSET_ID}: ${RESULT}"
    exit 1
fi

# Set file permissions
RESULT=$(chmod 0755 "${WORK_DIR}/docker-containercloud" 2>&1)
if [ $? -ne 0 ]; then
    echo "failed to set executable permissions: ${RESULT}"
    exit 1
fi

# Install
RESULT=$(mv "${WORK_DIR}/docker-containercloud" "${OUTPUT_DIR}/docker-containercloud" 2>&1)
if [ $? -ne 0 ]; then
    echo "failed to move binary to ${OUTPUT_DIR}: ${RESULT}"
    exit 1
fi

echo "Installed ${OUTPUT_DIR}/docker-containercloud; run 'docker containercloud'"
