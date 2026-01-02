#!/bin/bash
set -euo pipefail
exec > /var/log/cloud-init-worker.log 2>&1

# Base setup
dnf update -y
dnf install -y curl wget git

# Docker
dnf install -y yum-utils device-mapper-persistent-data lvm2
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker

# Kubernetes (kubeadm, kubelet)
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=0
EOF

dnf install -y kubeadm kubelet
systemctl enable kubelet

# Sysctl for networking
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF
sysctl --system

echo "Awaiting kubeadm join command via Ansible..."
