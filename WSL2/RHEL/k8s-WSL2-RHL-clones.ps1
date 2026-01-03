<#
.SYNOPSIS
    Create multiple WSL clones for AlmaLinux/Rocky from a base distro, enable systemd, set default user,
    configure hostname, and optionally run master/worker setup scripts inside each clone.

.PARAMETER BaseDistroName
    Name of the base WSL distro to export (e.g., "AlmaLinux-Base" or "Rocky-Base").

.PARAMETER ClonePrefix
    Prefix for clone names (e.g., "RHL").

.PARAMETER Count
    Number of clones to create.

.PARAMETER InstallRoot
    Root folder where clones will be imported (each clone gets its own subfolder).

.PARAMETER DefaultUser
    Default user to create inside the distro and set in /etc/wsl.conf (e.g., "devops").

.PARAMETER Role
    "Worker" or "Master" — used for tagging clone names.

.PARAMETER SetupScriptPath
    Optional path to your Linux setup script (worker or master) on Windows; will be copied into each clone and executed.
    Example: C:\repos\velocityPilot\k8s\RHL\rocky-worker.sh

.EXAMPLE
    .\RHL-WSLClones.ps1 `
      -BaseDistroName "AlmaLinux-Base" `
      -ClonePrefix "RHL" `
      -Count 3 `
      -InstallRoot "D:\WSL\RHL" `
      -DefaultUser "devops" `
      -Role "Worker" `
      -SetupScriptPath "C:\repos\k8s\WSL2\RHL\rocky-worker.sh"
#>

param(
    [Parameter(Mandatory=$true)] [string] $BaseDistroName,
    [Parameter(Mandatory=$true)] [string] $ClonePrefix,
    [Parameter(Mandatory=$true)] [int]    $Count,
    [Parameter(Mandatory=$true)] [string] $InstallRoot,
    [Parameter(Mandatory=$true)] [string] $DefaultUser,
    [Parameter(Mandatory=$true)] [ValidateSet("Worker","Master")] [string] $Role,
    [Parameter(Mandatory=$false)] [string] $SetupScriptPath
)

$ErrorActionPreference = 'Stop'

function Ensure-Folder { param([string] $Path) if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null } }
function Get-ExistingDistros { wsl --list --quiet }

function Export-Base {
    param([string] $DistroName, [string] $TarPath)
    if (-not (Test-Path $TarPath)) {
        Write-Host "📦 Exporting base distro '$DistroName'..."
        wsl --export $DistroName $TarPath
    }
    Write-Host "✅ Base tar ready: $TarPath"
}

function Import-Clone {
    param([string] $CloneName, [string] $InstallPath, [string] $TarPath)
    if ((Get-ExistingDistros) -contains $CloneName) { Write-Host "⏭️  Clone '$CloneName' exists — skipping."; return }
    Ensure-Folder -Path $InstallPath
    Write-Host "📥 Importing clone '$CloneName'..."
    wsl --import $CloneName $InstallPath $TarPath --version 2
}

function Configure-Clone {
    param([string] $CloneName, [string] $DefaultUser)
    Write-Host "⚙️  Configuring '$CloneName'..."
    wsl -d $CloneName -- bash -lc "dnf -y install sudo || true"
    wsl -d $CloneName -- bash -lc "id -u $DefaultUser >/dev/null 2>&1 || useradd -m -s /bin/bash $DefaultUser"
    wsl -d $CloneName -- bash -lc "echo '$DefaultUser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$DefaultUser && chmod 440 /etc/sudoers.d/$DefaultUser"
    wsl -d $CloneName -- bash -lc "cat > /etc/wsl.conf <<'EOF'
[boot]
systemd=true
[user]
default=$DefaultUser
EOF"
    wsl -d $CloneName -- bash -lc "echo '$CloneName' > /etc/hostname"
    Write-Host "✅ Configured '$CloneName'. Run 'wsl --terminate $CloneName' to reload systemd."
}

function Copy-And-Run-Setup {
    param([string] $CloneName, [string] $SetupScriptPath, [string] $DefaultUser)
    if (-not $SetupScriptPath) { Write-Host "ℹ️  No setup script — skipping."; return }
    if (-not (Test-Path $SetupScriptPath)) { throw "Setup script not found: $SetupScriptPath" }
    $LinuxMount = "/mnt/" + ($SetupScriptPath.Substring(0,1).ToLower()) + ($SetupScriptPath.Substring(2) -replace '\\','/')
    $TargetPath = "/home/$DefaultUser/" + [IO.Path]::GetFileName($SetupScriptPath)
    wsl -d $CloneName -- bash -lc "cp -f '$LinuxMount' '$TargetPath' && chmod +x '$TargetPath'"
    wsl -d $CloneName -- bash -lc "dnf -y install dos2unix || true && dos2unix '$TargetPath' || sed -i 's/\r$//' '$TargetPath'"
    Write-Host "🚀 Running setup script inside '$CloneName' as $DefaultUser..."
    wsl -d $CloneName --user $DefaultUser -- bash -lc "'$TargetPath'"
}

# --- Main ---
Ensure-Folder -Path $InstallRoot
$BaseTar = Join-Path $InstallRoot "$BaseDistroName-base.tar"
Export-Base -DistroName $BaseDistroName -TarPath $BaseTar

for ($i = 1; $i -le $Count; $i++) {
    $suffix   = "{0:D2}" -f $i
    $clone    = "$ClonePrefix-$Role-$suffix"
    $install  = Join-Path $InstallRoot $clone
    Import-Clone    -CloneName $clone -InstallPath $install -TarPath $BaseTar
    Configure-Clone -CloneName $clone -DefaultUser $DefaultUser
    wsl --terminate $clone | Out-Null
    Copy-And-Run-Setup -CloneName $clone -SetupScriptPath $SetupScriptPath -DefaultUser $DefaultUser
}
Write-Host "🎉 Completed cloning $Count distros from '$BaseDistroName' with prefix '$ClonePrefix-$Role'."
