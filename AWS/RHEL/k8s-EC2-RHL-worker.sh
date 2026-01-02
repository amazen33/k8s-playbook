#!/bin/bash
# =============================================================================
#  Kubernetes Worker Bootstrap Script (AWS EC2 - Rocky/AlmaLinux)
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  Repository: https://github.com/amazen333/velocityPilot
#  
#  Purpose:
#    Automates setup of a Kubernetes worker node on AWS EC2 instances.
#
#  Features:
#    - Disables swap
#    - Configures sysctl networking parameters
#    - Installs container runtime (containerd)
#    - Sets up Kubernetes repositories
#    - Prepares node to join Kubernetes cluster with kubeadm
#
#  Usage:
#    sudo ./ec2-rocky-worker.sh
#    Then run the `kubeadm join ...` command provided by the master node.
#
#  Notes:
#    Tested on Rocky Linux / AlmaLinux on AWS EC2
#
#  License: MIT
# =============================================================================

set -euo pipefail
echo "🚀 Configuring Kubernetes Worker on Rocky/AlmaLinux (AWS EC2)..."

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

# --- Pre-pull Kubernetes images (optional, speeds up join) ---
sudo kubeadm config images pull || true

echo "✅ Worker node prepared."
echo "👉 Use the 'kubeadm join ...' command provided by the master node to connect this worker."
