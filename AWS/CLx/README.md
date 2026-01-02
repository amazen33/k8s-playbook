## 📝 README
## Kubernetes on AWS EC2 (Community Linux)

This folder contains automation scripts for **Ubuntu/Debian** clusters on AWS EC2.

---

## 📂 Subpackages
- [`bootstrap`](./bootstrap) → Master/worker setup scripts
- [`cni`](./cni) → CNI plugin installers (Flannel, Calico)
- [`addons`](./addons) → Optional add-ons (Metrics Server, Dashboard)
- [`security`](./security) → Hardening scripts

---

## ⚖️ Comparison: Community vs Enterprise Linux
 --------------------------------------------------------------------------------------
| Aspect        | Community Linux (Ubuntu/Debian) | Enterprise Linux (Rocky/AlmaLinux) |
|---------------|---------------------------------|------------------------------------|
| **Support**   | Community-driven, fast updates  | Vendor-backed, long-term support   |
| **Flexibility**| Highly customizable, rapid prototyping | Standardized configs, enterprise governance |
| **Cost**      | Free, community support only    | Free base, optional enterprise subscriptions |
| **Use Cases** | Developer onboarding, staging clusters, IoT workloads | Mission-critical workloads, regulated industries |
| **Demand**    | Broad adoption in startups/devs | Strong demand in enterprises       |
 ---------------------------------------------------------------------------------------