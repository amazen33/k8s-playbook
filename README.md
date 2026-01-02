##k8s-arsenal — automation scripts and IaC examples to build reproducible Kubernetes labs on AWS EC2.

**Overview**
A compact toolkit for trainers, students, and engineers who want to run multi‑node Kubernetes 
clusters on EC2 for testing and demos.
The repo contains bootstrap scripts, cloning utilities, Terraform examples, and Ansible playbooks to automate provisioning, configuration, and basic CI/CD rollouts.

**Key goals

Reproducible environments for labs and POCs.

Clear, idempotent scripts that can be re-run safely.

Minimal host impact and easy cleanup.


##Quickstart
**Prerequisites

AWS account (for EC2).

Git, PowerShell (or Git Bash), and basic Linux tooling.

For EC2: AWS CLI configured with appropriate IAM permissions.

For GitHub pushes: use PAT or SSH keys (do not rely on cached credentials).

EC2 quick demo

```bash
# Initialize Terraform (example folder: infra/aws)
cd infra/aws
terraform init
terraform apply -var-file=secrets.tfvars
# After instances are up, run Ansible playbook to bootstrap nodes
ansible-playbook -i inventory/ec2.ini playbooks/bootstrap-k8s.yml
```
**Tip: use a dedicated IAM role with least privilege for provisioning.

#Scripts and what they do
**Docker Runtime

Scripts to install and configure Docker or containerd on target nodes; includes recommended daemon settings for Kubernetes.

Kubernetes Setup

k8s-EC2-RHL-master.sh — bootstrap a master node on Rocky/AlmaLinux (installs runtime, kubeadm, kubelet, configures sysctl and networking).

k8s-EC2-RHL-worker.sh — prepare a worker node and run kubeadm join.

Shell Scripts

bootstrap/master.sh and bootstrap/worker.sh — Ubuntu/Debian focused scripts; idempotent and annotated with steps to enable systemd, create users, and set hostnames.

PowerShell Scripts

Comments added to scripts

Each script includes a header with purpose, expected inputs, idempotency notes, and sanitization checklist (remove secrets before export). Look for # NOTE: and # TODO: markers in scripts for maintainers.

#Terraform Integration
Example modules to provision EC2 instances, security groups, and VPCs for a small k8s cluster.

Usage pattern

Keep state remote (S3 + DynamoDB) for team use.

Use variables for AMI IDs and instance types; do not hardcode credentials.

Recommended workflow

terraform init → terraform plan -var-file=secrets.tfvars → terraform apply -var-file=secrets.tfvars.

#Ansible Integration
Playbooks to configure nodes after provisioning: install runtime, kubeadm init/join, apply CNI, and deploy a simple app for smoke tests.

Inventory examples include static and dynamic (EC2) inventory scripts.

Best practice: run Ansible from a bastion or CI runner with SSH keys stored securely.

Architecture and Design
Topology: single control-plane (or HA control-plane) with multiple worker nodes; optional load balancer for control-plane in EC2 setups.

*Design notes

Keep bootstrap tasks idempotent.

Separate concerns: provisioning (Terraform) vs configuration (Ansible/scripts).

Use small, focused scripts and document expected inputs/outputs.

*CI/CD and Deployment
*Example GitHub Actions workflows for:

Linting shell scripts with shellcheck.

Running smoke tests against a freshly provisioned cluster.

Packaging and releasing scripts as a tarball.

*Recommendation: add a ci/ folder with a minimal pipeline that runs shellcheck and a smoke test to validate cloning and bootstrap scripts.

Contributing
How to contribute

Fork the repo, create a branch, and open a PR. Use feat:, fix:, docs:, or chore: prefixes in commit messages.

Add tests or a manual verification checklist for code changes.

Create small good first issue tasks for newcomers.

Files to add

CONTRIBUTING.md — contribution flow and coding standards.

ISSUE_TEMPLATE.md and PULL_REQUEST_TEMPLATE.md — to standardize reports and PRs.

Security and Sanitization
Sanitize exported images: remove /home/*/.ssh/authorized_keys, /root/.ssh, cloud-init data, and any secrets before exporting.

Do not commit secrets: use .gitignore and environment variables for credentials.

IAM: use least privilege for Terraform and automation.

License and Contact
License: Add a LICENSE file (MIT recommended for tooling).

Contact: For collaboration or questions, open an issue or tag maintainers in PRs.

*Appendix Useful commands and checks
```bash
---
# Show kubelet and kubeadm versions
kubeadm version
kubelet --version

# Basic cluster health
kubectl get nodes
kubectl get pods -A