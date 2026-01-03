# wsl2-k8s-lab

🚀 **wsl2-k8s-lab** is a curated collection of automation scripts and guides for building lightweight Kubernetes clusters across **WSL2** using Community Linux (CLx) and Enterprise Linux (RHL) distributions.

---

## Overview

**What this repo provides**
- **Automation scripts** to bootstrap Kubernetes master and worker nodes on WSL2.  
- **WSL2 cloning utilities** to create repeatable distro clones for testing and labs.  
- **Runtime guides** for Docker and container runtimes.  
- **CI/CD and deployment helpers** for rolling out clusters.

**Audience**  
- Developers learning Kubernetes on Windows via WSL2.  
- DevOps engineers building reproducible lab clusters.  
- Educators and trainers creating hands-on workshops.

---

## Quick Navigation

- **Docker Runtime** 🐳 — Scripts and instructions for Docker and containerd.  
- **Shell Scripts** 🐚 — Ubuntu/Debian (CLx) and Rocky/AlmaLinux (RHL) automation.  
- **Kubernetes on RHL** ☸️ — `WSL2-RHL-master.sh`, `WSL2-RHL-worker.sh`.  
- **Kubernetes on CLx** ☸️ — `WSL2-CLx-master.sh`, `WSL2-CLx-worker.sh`.  
- **PowerShell Cloning** 💠 — `WSL2-CLx-clones.ps1`, `WSL2-RHL-clones.ps1`.  
- **Implementation Guides** 🔧 — Step-by-step cluster setup.  
- **Deployment** 🚀 — CI/CD and rollout automation.

---

## Features and Benefits

- **Reproducible environments** — Create identical WSL2 clones for consistent testing.  
- **Lightweight clusters** — Run multi-node Kubernetes clusters locally for learning and CI.  
- **Cross-distro support** — Community (Ubuntu/Debian) and Enterprise (Rocky/AlmaLinux) workflows.  
- **Idempotent scripts** — Designed to be safe to re-run during iterative development.

---

## Community vs Enterprise Linux

| Aspect | Community Linux Ubuntu Debian | Enterprise Linux Rocky AlmaLinux |
|--------|------------------------------|----------------------------------|
| **Support** | Community-driven, fast updates | Vendor-backed, long-term support |
| **Flexibility** | Rapid prototyping and customization | Standardized configs, enterprise governance |
| **Cost** | Free, community support | Free base; optional enterprise subscriptions |
| **Use Cases** | Developer onboarding, staging | Mission-critical workloads |
| **Demand** | Popular in startups and devs | Strong in enterprise environments |

---

## Getting Started

### Prerequisites
- **Windows 10/11** with WSL2 enabled.  
- **WSL CLI** available (`wsl` command).  
- **PowerShell** for cloning scripts.  
- Sufficient disk space for exported tarballs and clones.

### Typical Workflow
1. **Prepare base distro** — Install and configure a base Ubuntu or RHL distro in WSL.  
2. **Export base** — Use `wsl --export <BaseDistro> <tarfile>` to create a reusable image.  
3. **Create clones** — Run the PowerShell cloning script to import multiple WSL2 clones.  
4. **Bootstrap master** — Run `WSL2-CLx-master.sh` or `WSL2-RHL-master.sh` inside the master distro.  
5. **Prepare workers** — Run `WSL2-CLx-worker.sh` or `WSL2-RHL-worker.sh` inside each worker distro.  
6. **Join cluster** — Use the kubeadm join token or provided join script to add workers to the master.

### Example Commands
```powershell
# Export base distro to tarball
wsl --export Ubuntu-22.04 C:\WSL\images\ubuntu-22.04.tar

# Import a clone (PowerShell)
wsl --import Ubuntu-Clone1 C:\WSL\Ubuntu-Clone1 C:\WSL\images\ubuntu-22.04.tar --version 2

# Run a setup script inside a clone
wsl -d Ubuntu-Clone1 bash ./WSL2-CLx-master.sh
```
---
## 🔧 Post-Import Recommendations

**Why:** These steps make each clone usable as a node (systemd, user, hostname, role scripts) and reduce manual setup.

### ✅ Enable systemd (if required)
Some services expect `systemd`. Add or update `/etc/wsl.conf` inside each clone:
```bash
sudo tee /etc/wsl.conf > /dev/null <<'EOF'
[boot]
systemd=true
EOF```
---
## 👤 Create and set the default user
Create the user and set it as the default in /etc/wsl.conf:

bash
sudo adduser --gecos "" devops
sudo usermod -aG sudo devops
echo -e "[user]\ndefault=devops" | sudo tee /etc/wsl.conf
🏷️ Set a unique hostname per clone
Give each clone a clear identity:

bash
sudo hostnamectl set-hostname clx-worker-01
📁 Copy and run role-specific setup scripts
From Windows, place your ubuntu-worker.sh or ubuntu-master.sh in a path accessible inside WSL (e.g., /mnt/c/...) or include them in the exported tar. Then inside the clone:

bash
chmod +x /mnt/c/path/to/ubuntu-worker.sh
sudo /mnt/c/path/to/ubuntu-worker.sh
🔁 Make scripts idempotent
Ensure setup scripts can be re-run safely (check for existing users, packages, or config before applying changes).

🔒 Sanitize and secure exported images
Remove secrets, SSH keys, or credentials from the base before exporting.

Rotate any credentials after cloning if the tarball was shared.

🧰 Quick checklist
[ ] systemd enabled (if needed)

[ ] default user created and sudo access granted

[ ] hostname set uniquely for each clone

[ ] role script copied and executed successfully

[ ] exported tarball sanitized for secrets