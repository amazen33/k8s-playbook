#!/bin/bash
set -euo pipefail

# Log file
exec > /var/log/cloud-init-master.log 2>&1

# Base setup
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  >/etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker

# Kubernetes (kubeadm, kubelet, kubectl)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" >/etc/apt/sources.list.d/kubernetes.list
apt-get update -y
apt-get install -y kubeadm kubelet kubectl
systemctl enable kubelet

# Sysctl for Kubernetes networking
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF
sysctl --system

# Initialize control plane
# Using Flannel defaults; adapt pod CIDR to your CNI choice
kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubectl for ubuntu user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Install CNI (Flannel)
# Wait for API to be ready
sleep 15
sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Store join command for Ansible retrieval
kubeadm token create --print-join-command >/etc/kubeadm_join_cmd.sh
chmod +x /etc/kubeadm_join_cmd.sh
