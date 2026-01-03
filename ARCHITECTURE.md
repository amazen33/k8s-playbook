Executive Summary
k8s‑playbook is a reproducible, hands‑on toolkit for provisioning and validating Kubernetes labs and small clusters across WSL2 (Windows) and AWS EC2. It combines Terraform for infrastructure, Ansible for configuration, PowerShell helpers for WSL2 cloning, and CI smoke tests to ensure repeatable, testable environments. Use this repo to bootstrap training labs, POCs, or developer sandboxes with consistent cluster topology, automated provisioning, and built‑in observability checks.

ARCHITECTURE.md (ready to add to docs/ARCHITECTURE.md)
Overview
Purpose: Provide a single source of truth describing how k8s‑playbook provisions reproducible Kubernetes environments, the components involved, and how they interact.
Scope: WSL2-based developer labs and small EC2 clusters; Terraform for infra, Ansible for configuration, CI for validation, and scripts for local cloning and bootstrapping.

Project structure
Top-level layout (conceptual)

infra/ — Terraform modules and cloud init for EC2 provisioning.

ansible/ — Inventories, group_vars, and playbooks for master/worker configuration.

scripts/ or wsl2/ — PowerShell and bash helpers to clone and prepare WSL2 images.

ci/ — Pipeline definitions for linting, provisioning, and smoke tests.

docs/ — Architecture, quickstart, and manifests.

High-level system diagram (text)
User (Windows) -> WSL2 (CLx/RHL clones) -> Ansible -> Kubernetes (master/worker)  
Terraform -> Cloud infra (AWS EC2) -> cloud-init -> Ansible -> Kubernetes  
CI pipelines validate both WSL2 and EC2 provisioning and run smoke tests against kubectl endpoints.

Core components
Terraform (infra/) — VPC, subnets, EC2 instances, security groups, and cloud‑init scripts to bootstrap nodes.

Ansible (ansible/) — Inventory files, roles/playbooks to install container runtime (containerd), kubeadm, kubelet, and apply cluster join.

WSL2 tooling — PowerShell scripts to clone Community Linux (CLx) or RHL images, prepare filesystems, and launch WSL instances for local labs.

CI / Validation — Jenkins/GitHub Actions jobs that run terraform plan/apply (or simulate), run Ansible playbooks, and execute smoke tests (kubectl get nodes, kubectl get pods -A).

Observability — Example stacks and guidance for Prometheus/Grafana/Loki to validate cluster health and collect metrics during POCs.

Security & secrets
Secrets handling: Use secrets.tfvars (excluded from repo) or environment variables for cloud credentials. Do not commit keys.

Network: Security groups restrict access to control plane ports; recommend bastion or SSH jump for EC2 access.

Hardening: TLS for kube‑apiserver, RBAC for cluster operations, and Vault/Secrets Manager for production secrets (notes included).

CI/CD & testing
Pipeline stages: lint → infra provision → config apply → smoke tests → teardown (optional).

Smoke tests: verify node readiness, core DNS, and a sample deployment. Include rollback/cleanup steps for ephemeral labs.

Extensibility & maintenance
Add new cloud providers by adding provider modules under infra/.

Add OS images by extending WSL2 templates and cloud‑init scripts.

Add CNI choices (Calico/Flannel) via Ansible role variables.

Documentation: keep README.md, ARCHITECTURE.md, and MANIFEST.csv in sync.

Quickstart (example)
bash
# Local WSL2 lab (high-level)
# 1. Prepare WSL2 image using provided PowerShell script (Windows)
# 2. Inside WSL2, run bootstrap scripts to install containerd and kubeadm
# 3. Initialize control plane and join workers

# AWS EC2 (example)
cd infra/aws
terraform init
terraform apply -var-file=secrets.tfvars

cd ../../ansible
ansible-playbook -i inventory/hosts.ini playbooks/bootstrap-k8s.yml

# Validate
kubectl get nodes
kubectl get pods -A
README top (improved quickstart + pitch)
k8s‑playbook — reproducible Kubernetes labs for WSL2 and EC2  
A practical toolkit to provision, configure, and validate small Kubernetes clusters for training, POCs, and developer sandboxes. It combines Terraform (infra), Ansible (config), WSL2 cloning scripts (local labs), and CI smoke tests (validation).

Quickstart

Add cloud credentials to secrets.tfvars (do not commit).

For AWS: cd infra/aws && terraform init && terraform apply -var-file=secrets.tfvars.

Run Ansible playbooks: ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/bootstrap-k8s.yml.

Verify: kubectl get nodes && kubectl get pods -A.

What you’ll find

infra/ — Terraform modules and cloud‑init.

ansible/ — Playbooks and inventories for cluster configuration.

wsl2/ — PowerShell and helper scripts for local labs.

ci/ — Example pipelines for provisioning and smoke tests.

Contribute / Use

Read docs/ARCHITECTURE.md for design and operational guidance.

Open issues for new OS images, CNI options, or provider modules.

Share PRs for improved automation, tests, or templates