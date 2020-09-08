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