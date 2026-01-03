# Kubernetes on WSL2 (RHL Linux)

This folder contains automation scripts for setting up Kubernetes clusters inside **WSL2** using **Rocky/AlmaLinux**.

## 📜 Scripts
- `k8s-WSL2-RHL-clones.ps1` → PowerShell script to clone base Rocky/AlmaLinux distros in WSL2.
- `k8s-WSL2-RHL-master.sh` → Bootstraps a Kubernetes **master node** inside WSL2.
- `k8s-WSL2-RHL-worker.sh` → Prepares a Kubernetes **worker node** inside WSL2.

## 🚀 Usage
```powershell
# Clone Rocky/A distros
.\k8s-WSL2-RHL-clones.ps1 -BaseDistroName "Ubuntu-Base" -ClonePrefix "RHL" -Count 3 -InstallRoot "D:\WSL\RHL" -DefaultUser "devops" -Role "Worker"

# Run setup scripts inside WSL
wsl -d k8s-WSL2-RHL-master-01 bash ./k8s-WSL2-RHL-master.sh
