# =============================================================================
#  Kubernetes Worker Bootstrap Script (AWS EC2 - Debian/Ubuntu)
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  Repository: https://github.com/amazen333/velocityPilot
#
#  Purpose:
#    Automates setup of a Kubernetes worker node on AWS EC2 instances.
#
#  Features:
#    - Prepares system packages and disables swap
#    - Configures kernel modules and sysctl for networking
#    - Installs and configures containerd with systemd cgroups
#    - Adds Kubernetes apt/yum repository and installs kubelet/kubeadm/kubectl
#    - Pre-pulls Kubernetes images (pause aligned to v3.9)
#    - Prepares node for joining cluster via kubeadm join
#
#  Usage:
#    Run this script as root or with sudo privileges on a fresh EC2 instance.
#    Example:
#      sudo ./k8s-worker-bootstrap.sh
#
#  Notes:
#    - Designed for reproducibility in AWS EC2 environments.
#    - Requires the `kubeadm join` command provided by the master node after init.
#    - Tested on Ubuntu, Debian.
#
#  License: MIT
# =============================================================================

set -euo pipefail

echo "==> Kubernetes worker bootstrap (AWS EC2)"

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

echo "✅ Worker node prepared. Use the kubeadm join command provided by the master node to join the cluster."
