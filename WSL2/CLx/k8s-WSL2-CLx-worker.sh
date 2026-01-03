#!/bin/bash
# =============================================================================
#  Kubernetes Worker Bootstrap Script (Debian/Ubuntu)
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  Repository: https://github.com/amazen333/violcityPilot
#  
#  Purpose: Automates setup of a Kubernetes worker node on Debian/Ubuntu systems
#           with containerd runtime, ready to join a master cluster.
#
#  Features:
#    - Verifies systemd presence (critical for kubelet/containerd)
#    - Prepares system packages and disables swap
#    - Configures kernel modules and sysctl for networking
#    - Installs and configures containerd with systemd cgroups
#    - Adds Kubernetes apt repository and installs kubelet/kubeadm/kubectl
#    - Pre-pulls Kubernetes images (pause aligned to v3.9)
#    - Prepares node for joining cluster via kubeadm join
#
#  Usage:
#    Run this script as root or with sudo privileges on a fresh Debian/Ubuntu host.
#    Example:
#      sudo ./k8s-WSL2-CLxWorker.sh
#
#  Notes:
#    - Designed for reproducibility and onboarding in cloud or WSL2 environments.
#    - Requires the `kubeadm join` command provided by the master node after init.
#    - Tested on Ubuntu and Debian .
#
#  License: MIT (adapt as needed for project branding)
# =============================================================================

set -euo pipefail

echo "==> Kubernetes worker bootstrap (Debian/Ubuntu)"

# --- Verify systemd ---
if [ "$(ps -p 1 -o comm=)" != "systemd" ]; then
  echo "ERROR: systemd is not PID 1. In WSL, enable systemd:"
  echo "  sudo tee /etc/wsl.conf <<'EOF'\n[boot]\nsystemd=true\nEOF"
  echo "  Then run: wsl --shutdown, and restart your distro."
  exit 1
fi

# --- Detect distro ---
. /etc/os-release
DISTRO=${ID:-unknown}
CODENAME=${VERSION_CODENAME:-unknown}
echo "Detected distro: $DISTRO ($CODENAME)"

# --- System prep ---
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https tmux

# --- Disable swap ---
sudo swapoff -a || true
if [ -f /etc/fstab ]; then
  sudo sed -i '/ swap / s/^/#/' /etc/fstab || true
fi

# --- Kernel modules ---
echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf >/dev/null
sudo modprobe br_netfilter || true

# --- Sysctl settings ---
sudo tee /etc/sysctl.d/k8s.conf >/dev/null <<'EOF'
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sudo sysctl --system

# --- Install containerd ---
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

# --- Kubernetes repo ---
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg

echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# --- Pre-pull Kubernetes images ---
sudo kubeadm config images pull
sudo ctr images pull registry.k8s.io/pause:3.9 || true

echo "✅ Worker node prepared. Use the kubeadm join command provided by the master node to join the cluster."
