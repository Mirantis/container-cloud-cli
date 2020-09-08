#!/usr/bin/env pwsh

<#
.SYNOPSIS Installs the Docker Enterprise Container Cloud CLI plugin

.PARAMETER BearerToken
Specify your GitHub bearer token if you are interacting with a private repo.

.PARAMETER Organization
Specify an alternative GitHub organization for the target repository. Defaults
to 'Mirantis'

.PARAMETER Repository
Specify an alternative GitHub target repository name. Defaults to
'container-cloud-cli'

.PARAMETER Version
Specify a target version to install. Defaults to 'v0.0.1-alpha2'

.PARAMETER OutputDir
Specify the directory containing docker CLI plugins on your machine.
Defaults to 'C:\Program Files\Docker\cli-plugins'
#>

[CmdletBinding(PositionalBinding=$FALSE)]
param(
    [string]$BearerToken = "",
    [string]$Organization = "Mirantis",
    [string]$Repository = "container-cloud-cli",
    [string]$Version = "v0.0.1-alpha2", # Update to "latest" on first release
    [string]$OutputDir = "C:\Program Files\Docker\cli-plugins"
)

$ErrorActionPreference = "Stop"
$global:ProgressPreference = "SilentlyContinue"

function Ensure-Docker {
    try {
        Get-Command docker | Out-Null
    } catch {
        throw "docker must be installed in order to unstall the Container Cloud plugin"
    }
}

function Get-Release {
    param(
        [string]$BearerToken,
        [string]$Organization,
        [string]$Repository,
        [string]$Version
    )

    $headers = @{}
    if ($BearerToken -ne "") {
        $headers["Authorization"] = "Bearer $BearerToken"
    }

    if ($Version -ne "latest") {
        $Version = "tags/$Version"
    }

    $uri = "https://api.github.com/repos/$Organization/$Repository/releases/$Version"

    Invoke-RestMethod -Uri $uri -Headers $headers
}

function Get-AssetID {
    param(
        $Release,
        [string]$Name = "docker-containercloud-windows-amd64.exe"
    )

    foreach ($asset in $Release.assets) {
        if ($asset.name -eq $Name) {
            return $asset.id
        }
    }
    throw "could not find asset with name $Name"
}

function Get-Asset {
    param(
        [string]$BearerToken,
        [string]$Organization,
        [string]$Repository,
        [string]$AssetID,
        [string]$OutFile
    )

    $headers = @{Accept = "application/octet-stream"}
    if ($BearerToken -ne "") {
        $headers["Authorization"] = "Bearer $BearerToken"
    }

    $uri = "https://api.github.com/repos/$Organization/$Repository/releases/assets/$AssetID"

    Invoke-WebRequest -Headers $headers -Uri $uri -OutFile $OutFile
}

function Check-Install {
    docker containercloud *>&1 | Out-Null
    if ($? -eq $FALSE) {
        throw "Failed to find docker containercloud subcommand"
    }
}

echo "Installing Docker Enterprise Container Cloud CLI plugin version $Version..."
Ensure-Docker

$release = Get-Release `
               -BearerToken $BearerToken `
               -Organization $Organization `
               -Repository $Repository `
               -Version $Version

$assetID = Get-AssetID -Release $release

Get-Asset `
    -BearerToken $BearerToken `
    -Organization $Organization `
    -Repository $Repository `
    -AssetID $assetID `
    -OutFile "$OutputDir\docker-containercloud.exe"

Check-Install
echo "Installed $OutputDir\docker-containercloud.exe; run 'docker containercloud'"