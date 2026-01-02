
## 📝 RHL  (`DevOps-Arsenal/k8s/AWS/RHL/README.md`)
---

# ☸️ Kubernetes on AWS EC2 (Enterprise Linux 🐧)

This folder contains automation scripts for setting up Kubernetes clusters on **AWS EC2** using **Rocky Linux / AlmaLinux**.

## 🧩 Scripts 
📜- `k8s-EC2-RHL-master.sh` → Bootstraps a Kubernetes **master node**.
📜- `k8s-EC2-RHL-worker.sh` → Prepares a Kubernetes **worker node**.

## 🚀 Usage
```powershell
# 🧩 Master node
sudo ./k8s-EC2-RHL-master.sh

# 🧩 Worker node
sudo ./k8s-EC2-RHL-worker.sh
# Then run the 'kubeadm join ...' command provided by the master
