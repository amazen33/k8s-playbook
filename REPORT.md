# Shell Scripts Tags & Comments Report

## D:\IoT-Nexus\k8s-Arsenal\k8s\control-plane.sh

### Tags
  echo "### Tags (TODO FIXME HACK SECURITY OPTIMIZE DOC TAG)" >> "$out"
  grep -nE 'TODO|FIXME|HACK|OPTIMIZE|SECURITY|DOC|TAG:' "$f" || echo "- none found" >> "$out"
### Header comments (first 20)
#!/usr/bin/env bash

## D:\IoT-Nexus\k8s-Arsenal\k8s\AWS\CLx\k8s-EC2-CLx-master.sh

### Tags
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
### Header comments (first 20)
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

## D:\IoT-Nexus\k8s-Arsenal\k8s\AWS\CLx\k8s-EC2-CLx-worker.sh

### Tags
### Header comments (first 20)
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

## D:\IoT-Nexus\k8s-Arsenal\k8s\AWS\RHEL\k8s-EC2-RHL-master.sh

### Tags
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
### Header comments (first 20)
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

## D:\IoT-Nexus\k8s-Arsenal\k8s\AWS\RHEL\k8s-EC2-RHL-worker.sh

### Tags
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
### Header comments (first 20)
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

## D:\IoT-Nexus\k8s-Arsenal\k8s\terraform\CLx\cloud-init-master.sh

### Tags
# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  >/etc/apt/sources.list.d/docker.list
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
### Header comments (first 20)
#!/bin/bash
# Log file
# Base setup
# Docker
# Kubernetes (kubeadm, kubelet, kubectl)
# Sysctl for Kubernetes networking
# Initialize control plane
# Using Flannel defaults; adapt pod CIDR to your CNI choice
# Setup kubectl for ubuntu user
# Install CNI (Flannel)
# Wait for API to be ready
# Store join command for Ansible retrieval

## D:\IoT-Nexus\k8s-Arsenal\k8s\terraform\CLx\cloud-init-worker.sh

### Tags
# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  >/etc/apt/sources.list.d/docker.list
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
### Header comments (first 20)
#!/bin/bash
# Log file
# Base setup
# Docker
# Kubernetes (kubeadm, kubelet)
# Sysctl for Kubernetes networking
# Wait for Ansible to run the join command

## D:\IoT-Nexus\k8s-Arsenal\k8s\terraform\RHL\k8s-EC2-RHL-init-worker.sh

### Tags
# Docker
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker
### Header comments (first 20)
#!/bin/bash
# Base setup
# Docker
# Kubernetes (kubeadm, kubelet)
# Sysctl for networking

## D:\IoT-Nexus\k8s-Arsenal\k8s\terraform\RHL\k8s-EC2.RHL-init-master.sh

### Tags
# Docker (via Podman or Docker CE repo)
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker
sudo -u ec2-user kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
### Header comments (first 20)
#!/bin/bash
# Base setup
# Docker (via Podman or Docker CE repo)
# Kubernetes (kubeadm, kubelet, kubectl)
# Sysctl for networking
# Initialize control plane
# Configure kubectl for ec2-user
# Install Flannel CNI
# Store join command

## D:\IoT-Nexus\k8s-Arsenal\k8s\WSL2\CLx\k8s-WSL2-CLx-clones.sh

### Tags
### Header comments (first 20)
#!/bin/bash
# =============================================================================
#  WSL Ubuntu Clone Automation Script
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  Repository: https://github.com/amazen333/violcityPilot
#
#  Purpose:
#    Automates creation of multiple WSL2 clones from a base Ubuntu/Debian distro.
#    Each clone is imported with systemd enabled, a default user configured,
#    and optionally a setup script applied (e.g., Kubernetes worker bootstrap).
#
#  Features:
#    - Exports a base WSL distro to tarball
#    - Imports multiple clones with unique names and paths
#    - Ensures required folders exist before operations
#    - Optionally copies setup scripts into each clone
#    - Informational ROLE tag for Master/Worker designation
#

## D:\IoT-Nexus\k8s-Arsenal\k8s\WSL2\CLx\k8s-WSL2-CLx-master.sh

### Tags
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
### Header comments (first 20)
# =============================================================================
#  Kubernetes Master Bootstrap Script (Debian/Ubuntu)
# =============================================================================
#  Author: Ahmed Ameen Mazen Tayeb
#  Project: VelocityPilot (Automation DevOps Scripts)
#  Repository: https://github.com/amazen333/violcityPilot
#  
#  Purpose: Automates setup of a Kubernetes master node on Debian/Ubuntu systems
#           with containerd runtime and Flannel CNI.
#
#  Features:
#    - Verifies systemd presence (critical for kubelet/containerd)
#    - Prepares system packages and disables swap
#    - Configures kernel modules and sysctl for networking
#    - Installs and configures containerd with systemd cgroups
#    - Adds Kubernetes apt repository and installs kubelet/kubeadm/kubectl
#    - Pre-pulls Kubernetes images (pause aligned to v3.9)
#    - Initializes master node with Flannel pod network
#    - Configures kubectl for current user
#

## D:\IoT-Nexus\k8s-Arsenal\k8s\WSL2\CLx\k8s-WSL2-CLx-worker.sh

### Tags
### Header comments (first 20)
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

## D:\IoT-Nexus\k8s-Arsenal\k8s\WSL2\RHEL\k8s-EC2-RHL-master.sh

### Tags
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
### Header comments (first 20)
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

## D:\IoT-Nexus\k8s-Arsenal\k8s\WSL2\RHEL\k8s-EC2-RHL-worker.sh

### Tags
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
### Header comments (first 20)
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
