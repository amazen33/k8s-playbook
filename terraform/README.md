		📘 Top Level README.md (Index)
		markdown
		# k8s-Arsenal Kubernetes Cluster Automation

		## Overview
		k8s-Arsenal provides a **productionready automation toolkit** for deploying a Kubernetes cluster on AWS.  
		It combines:
		- **Terraform** → Infrastructure provisioning (EC2 master + worker nodes, security groups, networking).
		- **Ansible** → Post‑provisioning configuration (cluster initialization, worker node join, CNI setup).
		This repo is designed for **repeatable, scalable, and professional deployments**.
		## 📂 Repository Structure
		k8s-Arsenal/
		├── terraform/   # Infrastructure as Code (AWS EC2 cluster)
		│   ├── main.tf
		│   ├── variables.tf
		│   ├── outputs.tf
		│   ├── cloud-init-master.sh
		│   └── cloud-init-worker.sh
		└── ansible/     # Configuration Management (Kubernetes setup)
		├── inventory.ini
		├── group_vars/
		│   └── all.yml
		├── master-playbook.yml
		└── worker-playbook.yml
		├───AWS
		│   ├───CLx
		│   └───RHEL
		└───WSL2
			├───CLx
			└───RHEL
		## 🚀 Workflow

		### 1. Provision Infrastructure (Terraform)
		```bash
		cd terraform
		terraform init
		terraform apply
		Creates 1 master + N workers.

		Outputs public/private IPs for Ansible.

		2. Configure Cluster (Ansible)
		bash
		cd ../ansible
		ansible-playbook -i inventory.ini master-playbook.yml
		ansible-playbook -i inventory.ini worker-playbook.yml
		Master initializes Kubernetes and exports join command.

		Workers join the cluster automatically.

		3. Validate Cluster
		bash
		kubectl get nodes
		kubectl get pods -A
		🔑 Key Features
		Cloud‑init bootstrapping → Docker, kubeadm, kubelet installed at first boot.

		Terraform outputs → IPs and SG IDs exposed for Ansible.

		Ansible automation → Master join command captured and applied to workers.

		Scalable → Adjust worker_count in variables.tf.

		Secure → Security groups defined with CIDR allowlists.

		⚙️ Prerequisites
		Terraform >= 1.9

		Ansible >= 2.15

		AWS CLI configured with credentials

		Existing AWS VPC, Subnet, and Key Pair

		SSH access to EC2 nodes (ubuntu user)

		📌 Notes
		Default CNI: Flannel (simple networking). For production, consider Calico.

		Restrict SSH/API CIDRs for security.

		Use remote backend (S3 + DynamoDB) for Terraform state.

		Integrate with CI/CD pipelines for automated deployments.

		📎 Documentation
		Terraform README → Infrastructure provisioning details

		Ansible README → Cluster configuration details

		Code

		---