# container-cloud-cli
CLI binaries for Docker Enterprise Container Cloud

## docker containercloud plugin

### Windows
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

## Linux and MacOS
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