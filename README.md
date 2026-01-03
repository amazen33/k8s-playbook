##	   🏗️ Architecture document  
		
		k8s-playbook is an automation environment that provisions reproducible Kubernetes clusters
		and DevOps workflows inside	WSL2 on Windows and on AWS EC2. 
		It standardizes cloning and bootstrapping of Community Linux (CLx) and Enterprise Linux (RHL) distros,
		enabling master/worker roles, container runtime setup, and Kubernetes initialization. 
		The project integrates CI/CD, Infrastructure as Code, security automation, 
		tests, examples, and tooling to deliver a developer experience suitable for training, POCs, and enterprise validation.
		
		
       🐧 Community Linux (CLx) - Ubuntu/Debian/Fedora

       🏢 Enterprise Linux (RHL) - Rocky/AlmaLinux (RHEL-compatible)
		
				+------ 🪟 Windows Host ----+         +----- 🔄 CI/CD & IaC Layer -------+
				| 💠 PowerShell (clone PS)  |         |  🛠️ Jenkins pipelines (jenkins)  |
				| 🔀 Git & repo mgmt        |         |  🏗️ Terraform & Ansible (infra)  |
				+-------------+-------------+         +--------------------+---------------					                                            
							  |                                    | Provisioning, tests
							  v                                    v
				+---🟢 WSL2 CLx/RHL --------+        +------ EC2 CLx/RHL--------+
				|👨 systemd, default user   |        | 👨 systemd, default user |
				|👑 → ⚙️ master/worker      |        | 👑 → ⚙️ master/worker    |
				|🐳 containerd + kube		|        | 🐳 containerd + kube      |
				+-------------+-------------+        +-------------+-------------+
							  | kubeadm init/join                  | kubeadm init/join
							  v                                    v
		          +--------------------- ☸️ Kubernetes cluster ------------------+
				   | 📑Control plane (master)      |⚙️ Worker nodes (compute)     |
				   | 🌐CNI (Flannel 🪁/Calico 🐆)  |⚙️ kubelet, pods,📊 workloads |
				   +---------------------------------------------------------------+
			

		📂 Repository Structure
				k8s-playbook/
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
---


#		Components 
		🐧CLx (Community Linux):

		Ubuntu/Debian/Fedora clones configured with systemd and a default user.

		Optional master/worker roles via Bash scripts to bootstrap Kubernetes clusters.

		Emphasizes fast onboarding and cross distro experimentation.

	   🐧RHL (Enterprise Linux):

		Rocky/AlmaLinux clones configured with systemd and a default user.

		Kubernetes bootstrap scripts for master/worker nodes, containerd configuration, and repo setup.

		Aligns with enterprise, RHEL compatible workflows and stability constraints.

		Automation scripts:

		PowerShell for cloning base distros and producing CLx/RHL clones (naming conventions, directories, user defaults).

		```Bash```
		master/worker setup scripts for container runtime, kubeadm/kubelet/kubectl, and CNI initialization.
		
		🔄 Pipeline:
		🛠️ CI/CD (Jenkins):

		Declarative Jenkinsfile and job scripts for provisioning, testing, linting, and deployment.

		Pipeline stages orchestrate clone creation, environment setup, validation, and artifact publication.

		IaC (infra/):

		🏗 Terraform modules for cloud resources (e.g., EC2, networking, storage).

		📈 Ansible playbooks for post provision configuration, package installs, and security baselines.

		🔐 Security:

		🏔️ IAM role definitions, secrets management workflows, and compliance checks.

		Policies and scripts to enforce minimal privileges, MFA expectations, and configuration hardening.

		🏭 Tests:

		Health checks for kubelet status, CNI readiness, and node registration.

		CI validation scripts to ensure reproducible builds and environment integrity.

		📚 Examples:

		Sample Kubernetes manifests for CNI installation and demo apps.

		Reference deployments to verify cluster functionality end to end.

		🔄 Tools:

		Utilities for log parsing, metrics export, and troubleshooting.

		Developer helpers that accelerate diagnosis and operational visibility.

		🔁 Workflow
		Clone provisioning:

		PowerShell clones create CLx/RHL WSL distros from a base image with standardized naming and directory layout.

		Default user and systemd are configured to ensure services and kubelet operate reliably under WSL.

		Node setup:

		Bash master/worker scripts install containerd, enable systemd cgroups, configure Kubernetes repositories, and install kubeadm/kubelet/kubectl.

		Master initialization via kubeadm init sets the pod network CIDR; worker nodes join using the provided token and CA cert hash.

		CNI and networking:

		Apply a CNI plugin (e.g., Flannel or Calico), ensuring bridge netfilter and sysctl parameters are set.

		Validate networking with test workloads and kubectl inspections.

		CI/CD integration:

		Jenkins pipelines orchestrate provisioning, setup, tests, and publishing of artifacts/documents.

		Pipelines can trigger Terraform/Ansible for cloud resources or hybrid scenarios.

		Validation and documentation:

		tests/ scripts verify cluster health and readiness.

		docs/ capture architecture, onboarding steps, and operational guidance for collaborators and employers.

*		Extensibility
		New distros:

		Add subfolders under CLx or RHL, define base clone templates, and reuse master/worker scripts with minimal changes.

	   ☁️ Cloud providers:

		Extend infra/ with modules for AWS, Azure, GCP, and on prem; align provisioning with Terraform backends and Ansible inventories.

		🔄 CI/CD tools:

		Introduce ci/ for GitHub Actions, GitLab CI, or Azure DevOps pipelines; maintain consistent stages and validation scripts.

		Security controls:

		Integrate Vault, SOPS, or cloud native secret stores; expand policies.md  and automation to enforce compliance and rotation.

		Observability and tooling:

		Add tools for metrics, tracing, and logging; integrate with Prometheus, Grafana, and OpenTelemetry to enhance feedback loops.

*		Author and links
		Name: Ahmed Ameen Mazen Tayeb

		LinkedIn: https://www.linkedin.com/in/amazen33/

		GitHub: https://github.com/amazen33/