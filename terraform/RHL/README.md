📘 README for k8s-Arsenal/ansible (RHEL)
markdown
# k8s-Arsenal Ansible Package (RHEL)

## Overview
This Ansible package configures **RHEL-based EC2 instances** provisioned by Terraform into a working Kubernetes cluster.  
It:
- Extracts the `kubeadm join` command from the Master node
- Runs the join command on Worker nodes
- Validates cluster readiness

---

## 📂 Structure
ansible/
├── inventory.ini                  # Hosts file (IPs from Terraform outputs)
├── group_vars/
│   └── all.yml                      # Global variables
├── master-playbook.yml      # Configures master node, exports join command
└── worker-playbook.yml      # Configures worker nodes, runs join command

Code

---

## ⚙️ Prerequisites
- Ansible >= 2.15
- SSH access to EC2 nodes (`ec2-user` for RHEL)
- Terraform outputs copied into `inventory.ini`

---

## 🚀 Usage
1. **Update Inventory**
   ```ini
   [master]
   54.210.123.45

   [workers]
   54.211.234.56
   54.212.345.67

   [all:vars]
   ansible_user=ec2-user
   ansible_ssh_private_key_file=~/.ssh/my-keypair.pem
Run Master Playbook

bash
ansible-playbook -i inventory.ini master-playbook.yml
Run Worker Playbook

bash
ansible-playbook -i inventory.ini worker-playbook.yml
Validate Cluster

bash
kubectl get nodes
kubectl get pods -A
🔑 Notes
Master playbook ensures the join command is available at /etc/kubeadm_join_cmd.sh.

Worker playbook executes the join command to connect nodes.

Default user for RHEL AMIs is ec2-user.

For production, integrate with CI/CD pipelines and secrets management.

Code

---
