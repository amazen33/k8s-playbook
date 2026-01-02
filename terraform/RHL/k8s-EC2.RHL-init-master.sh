#!/bin/bash
set -euo pipefail
exec > /var/log/cloud-init-master.log 2>&1

# Base setup
dnf update -y
dnf install -y curl wget git

# Docker (via Podman or Docker CE repo)
dnf install -y yum-utils device-mapper-persistent-data lvm2
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker

# Kubernetes (kubeadm, kubelet, kubectl)
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=0
EOF

dnf install -y kubeadm kubelet kubectl
systemctl enable kubelet

# Sysctl for networking
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF
sysctl --system

# Initialize control plane
kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for ec2-user
mkdir -p /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# Install Flannel CNI
sleep 15
sudo -u ec2-user kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Store join command
kubeadm token create --print-join-command >/etc/kubeadm_join_cmd.sh
chmod +x /etc/kubeadm_join_cmd.sh
