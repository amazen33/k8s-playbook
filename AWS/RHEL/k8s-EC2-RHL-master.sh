#!/bin/bash
# =============================================================================
#  Kubernetes Master Bootstrap Script (AWS EC2 - Rocky/AlmaLinux)
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  
#  Repository: https://github.com/amazen333/velocityPilot
#  
#
#  Purpose:
#    Automates setup of a Kubernetes master node on AWS EC2 instances.
#
#  Features:
#    - Disables swap
#    - Configures sysctl networking parameters
#    - Installs container runtime (containerd)
#    - Sets up Kubernetes repositories
#    - Initializes Kubernetes control plane with kubeadm
#    - Configures kubectl for the current user
#
#  Usage:
#    sudo ./ec2-rocky-master.sh
#
#  Notes:
#    Tested on Rocky Linux / AlmaLinux on AWS EC2
#
#  License: MIT
# =============================================================================

set -euo pipefail

echo "🚀 Configuring Kubernetes Master on Rocky/AlmaLinux (AWS EC2)..."

# --- Update system ---
sudo dnf update -y
sudo dnf install -y curl vim git epel-release dnf-plugins-core

# --- Disable swap ---
if [ -f /etc/fstab ]; then
  sudo sed -i '/ swap / s/^/#/' /etc/fstab
fi
sudo swapoff -a

# --- Kernel modules ---
sudo mkdir -p /etc/modules-load.d
echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
sudo modprobe br_netfilter

# --- Sysctl settings ---
sudo mkdir -p /etc/sysctl.d
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sudo sysctl --system

# --- Install containerd ---
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
if ! sudo dnf install -y containerd.io; then
  echo "⚠️ containerd.io not found, falling back to EPEL..."
  sudo dnf install -y containerd
fi

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

# --- Kubernetes repo ---
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

# --- Refresh repo metadata ---
sudo dnf clean all
sudo dnf makecache

# --- Install kubeadm, kubelet, kubectl ---
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# --- Initialize Kubernetes master ---
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# --- Configure kubectl for the current user ---
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

echo "✅ Master node initialized."
echo "👉 Apply a CNI plugin (Flannel: 10.244.0.0/16, Calico: 192.168.0.0/16)."
echo "👉 Use the 'kubeadm join ...' command shown above on worker nodes."
