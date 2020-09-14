# container-cloud-cli
CLI binaries for Docker Enterprise Container Cloud

## docker containercloud plugin (BETA)
`docker containercloud` is a plugin that integrates the Docker CLI with
the Mirantis Docker Enterprise Container Cloud. It allows for the simple
creation of, and switching between, docker contexts derived from Container
Cloud UCP clusters.

### Usage
First, install the plugin according to the installation instructions below.

To configure the plugin, run `docker containercloud setup`.
```bash
$ docker containercloud setup http://******.us-east-2.elb.amazonaws.com/
Username: operator
Password:
Docker Enterprise Container Cloud setup successful. Use `docker containercloud ls` to list your clusters.
```

To view the available clusters, use `docker containercloud ls`.
```bash
$ docker containercloud ls
PROJECT   NAME     PROVIDER   RELEASE                   MANAGERS   WORKERS   CREATED
demo      demo-1   aws        ucp-5-7-0-rc-3-3-3-tp10   3          3         1 week ago
demo      demo-2   aws        ucp-5-7-0-rc-3-3-3-tp10   3          3         1 week ago
```

To select a particular cluster, run `docker containercloud select NAMESPACE/NAME`.
```bash
$ docker containercloud select demo/demo-1
Context "containercloud" has been updated. To use the cluster type `docker context use containercloud`.
```

This creates a docker context called `containercloud`.
```bash
$ docker context ls
NAME                DESCRIPTION                               DOCKER ENDPOINT                                 KUBERNETES ENDPOINT                                 ORCHESTRATOR
containercloud      demo/demo-1                               tcp://******.elb.us-east-2.amazonaws.com:6443   https://******.elb.us-east-2.amazonaws.com:443 ()   all
default *           Current DOCKER_HOST based configuration   unix:///var/run/docker.sock                                                                         swarm
```

When a particular cluster is selected, the `containercloud` context is created or updated.
The `docker containercloud ls` command will indicate the currently selected cluster.
```bash
$ docker containercloud ls
PROJECT   NAME      PROVIDER   RELEASE                   MANAGERS   WORKERS   CREATED
demo      demo-1*   aws        ucp-5-7-0-rc-3-3-3-tp10   3          3         1 week ago
demo      demo-2    aws        ucp-5-7-0-rc-3-3-3-tp10   3          3         1 week ago
```

### Installing on Windows
To install on Windows, in an elevated command prompt, run the following.
```powershell
PS> Invoke-WebRequest -Uri https://raw.githubusercontent.com/Mirantis/container-cloud-cli/master/install.ps1 -OutFile install.ps1
PS> .\install.ps1
```
It is possible to override the installation version by specifying the
`-Version` flag; see the available release versions in this repo if you
prefer something other than the default.

By default, the script will install the plugin to
`C:\Program Files\Docker\cli-plugins`; if your CLI will search elsewhere
for plugins, you can specify the desired directory with the `-OutputDir`
flag.

### Installing on Linux and MacOS
To install on Linux or MacOS, note that you need to have the ability to
run containers using docker, or you need to have cURL and jq installed.
Run the following.
```bash
curl https://raw.githubusercontent.com/Mirantis/container-cloud-cli/master/install.sh | sudo bash
```
It is possible to override the installation version by setting the `VERSION`
environment variable; see the available release versions in this repo if
you prefer something other than the default.

By default, the script will install the plugin to
`/usr/local/lib/docker/cli-plugins`; if your CLI will search elsewhere for
plugins, you can specify the `OUTDIR_DIR` environment variable.

### Contributing
The plugin is closed source. If you find an issue, or have a feature request,
please raise an issue in this repository.
