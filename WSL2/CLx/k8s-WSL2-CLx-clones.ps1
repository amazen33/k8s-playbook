<#
.SYNOPSIS
    Create multiple WSL clones for Ubuntu from a base distro, enable systemd, set default user,
    configure hostname, and optionally run master/worker setup scripts inside each clone.

.DESCRIPTION
    This script automates the export of a base Ubuntu WSL distro and imports multiple clones.
    Each clone is configured with systemd enabled, a default user, and a unique hostname.
    Optionally, a setup script (worker or master) can be copied into each clone and executed.

.PARAMETER BaseDistroName
    Name of the base WSL distro to export (e.g., "Ubuntu-Base" or "Ubuntu-22.04").

.PARAMETER ClonePrefix
    Prefix for clone names (e.g., "Ubuntu-Worker" or "Ubuntu-Master").

.PARAMETER Count
    Number of clones to create.

.PARAMETER InstallRoot
    Root folder where clones will be imported (each clone gets its own subfolder).

.PARAMETER DefaultUser
    Default user to create inside the distro and set in /etc/wsl.conf (e.g., "devops").

.PARAMETER Role
    "Worker" or "Master" — used only for informational tagging.

.PARAMETER SetupScriptPath
    Optional path to your Linux setup script (worker or master) on Windows; will be copied into each clone and executed.
    Example: C:\repos\k8s\CLx\ubuntu-worker.sh

.EXAMPLE
    .\New-UbuntuWSLClones.ps1 `
      -BaseDistroName "Ubuntu-22.04" `
      -ClonePrefix "Ubuntu-Worker" `
      -Count 3 `
      -InstallRoot "D:\WSL\Ubuntu" `
      -DefaultUser "devops" `
      -Role "Worker" `
      -SetupScriptPath "C:\repos\velocityPilot\k8s\CLx\ubuntu

.EXAMPLE
    .\New-UbuntuWSLClones.ps1 `
      -BaseDistroName "Ubuntu-22.04" `
      -ClonePrefix "Ubuntu-Master" `
      -Count 1 `
      -InstallRoot "D:\WSL\Ubuntu" `
      -DefaultUser "devops" `
      -Role "Master" `
      -SetupScriptPath "C:\repos\velocityPilot\k8s\CLx\ubuntu-master.sh"

.NOTES
    Created by: Ahmed Ameen Mazen Tayeb
    Date: December 2025
    Project: VelocityPilot (Automation DevOps Scripts)
    Role: Master | Worker Clone Node Setup
    Tested on: Ubuntu / Debian under WSL2

.LINK
    GitHub: https://github.com/amazen333/velocityPilot
#>

param(
    [string]$BaseDistro = "Ubuntu",   		# Change to your desired Ubuntu/Debian version
    [int]$CloneCount = 3,                   # Number of clones you want
    [string]$ImagePath = "C:\WSL\images",   # Where to store exported tarball
    [string]$InstallRoot = "C:\WSL"         # Root folder for clones
)

# Ensure folders exist
New-Item -ItemType Directory -Force -Path $ImagePath | Out-Null
New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null

# Export base distro
$tarFile = Join-Path $ImagePath "$($BaseDistro).tar"
Write-Host "Exporting $BaseDistro to $tarFile..."
wsl --export $BaseDistro $tarFile

# Import clones
for ($i = 1; $i -le $CloneCount; $i++) {
    $cloneName = "$($BaseDistro)-Clone$i"
    $clonePath = Join-Path $InstallRoot $cloneName
    Write-Host "Importing clone $cloneName..."
    New-Item -ItemType Directory -Force -Path $clonePath | Out-Null
    wsl --import $cloneName $clonePath $tarFile --version 2
}

Write-Host "✅ $CloneCount clones of $BaseDistro created successfully."
Write-Host "Use 'wsl -d <CloneName>' to launch each clone."
