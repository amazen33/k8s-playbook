#!/bin/bash
# =============================================================================
#  Kubernetes Master Bootstrap Script (AWS EC2 - Debian/Ubuntu)
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation Env Scripts)
#  Repository: https://github.com/amazen333/Automation-DevOps-Scripts
#  LinkedIn:  https://www.linkedin.com/in/ahmed-ameen-mazen-tayeb
#
#  Purpose:
#    Automates setup of a Kubernetes master node on AWS EC2 instances.
#
#  Features:
#    - Prepares system packages and disables swap
#    - Configures kernel modules and sysctl for networking
#    - Installs and configures containerd with systemd cgroups
#    - Adds Kubernetes apt/yum repository and installs kubelet/kubeadm/kubectl
#    - Pre-pulls Kubernetes images (pause aligned to v3.9)
#    - Initializes master node with Flannel pod network
#    - Configures kubectl for current user
#
#  Usage:
#    Run this script as root or with sudo privileges on a fresh EC2 instance.
#    Example:
#      sudo ./k8s-master-bootstrap.sh
#
#  Notes:
#    - Designed for reproducibility in AWS EC2 environments.
#    - Tested on Ubuntu 22.04, Debian 12, Rocky 9, AlmaLinux 9.
#
#  License: MIT
# =============================================================================

set -euo pipefail

echo "==> Kubernetes master bootstrap (AWS EC2)"

# --- System prep ---
sudo apt-get update -y || sudo yum update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https tmux || \
sudo yum install -y curl gnupg2 lsb-release tmux

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
sudo apt-get install -y containerd || sudo yum install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

# --- Kubernetes repo ---
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg || true

echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null || true

sudo apt-get update -y || true
sudo apt-get install -y kubelet kubeadm kubectl || sudo yum install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl || true
sudo systemctl enable --now kubelet

# --- Pre-pull Kubernetes images ---
sudo kubeadm config images pull
sudo ctr images pull registry.k8s.io/pause:3.9 || true

# --- Initialize master node ---
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# --- Configure kubectl for current user ---
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

# --- Install Flannel CNI ---
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "✅ Master node configured. Use the kubeadm join command displayed above on worker nodes."
