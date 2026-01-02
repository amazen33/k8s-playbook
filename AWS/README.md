## ☸️ Kubernetes on AWS EC2 — DevOps-Arsenal Scripts

This section of DevOps-Arsenal provides automation scripts for bootstrapping Kubernetes clusters on **AWS EC2**.  
Two families of scripts are included:

- **CLx (Community Linux)** → Ubuntu/Debian based
- **RHL (Enterprise Linux)** → Rocky/AlmaLinux based

## ⚖️ Comparison: EC2 vs EKS

| Factor        | EC2 + Scripts (DIY Kubernetes) | EKS (Managed Kubernetes) |
|---------------|--------------------------------|---------------------------|
| **Control**   | Full control over master/worker setup, networking, and upgrades | AWS manages control plane, limited customization |
| **Complexity**| Higher — you maintain everything | Lower — AWS handles upgrades and HA |
| **Cost**      | Pay only for EC2 + infra; can optimize with spot instances | Extra per‑cluster fee + EC2 costs |
| **Use Cases** | Training, custom networking, hybrid setups, R&D | Production workloads, enterprise apps, teams wanting less ops burden |
| **Demand**    | Niche but steady (DevOps, infra engineers) | Broad demand across enterprises |

## 📂 Subfolders
- [`CLx`](./CLx) → Scripts for Ubuntu/Debian (Community Linux)
- [`RHL`](./RHL) → Scripts for Rocky/AlmaLinux (Enterprise Linux)
