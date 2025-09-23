# NixOS on EKS Nodes – Notes & Caveats

> **Uddhava Gītā (SB 11.19.36)**  
> *dayā bhūteṣu santuṣṭiḥ titikṣoparatiḥ śamaḥ* [#SB-11.19.36a]  
> *ahimsā satyam asteyam ity ādīnāṁ samāsataḥ* [#SB-11.19.36b]  
> **Translation (ISKCON):** "Compassion, contentment, tolerance, peace, non-violence, truth and honesty are to be cultivated."

Running **NixOS** as worker nodes on AWS EKS is possible but **not standard**.
You must maintain AMIs and bootstrap scripts.

## Considerations
- **AMI**: NixOS with containerd, kubelet, CNI.  
- **NodeGroup**: self-managed ASG + Launch Template.  
- **Support**: you own updates and security patches.  
- **Upgrades**: immutable images; roll nodes on bumps.

## Pointers
- Use NixOS modules for kubelet/containerd/networking.  
- Build AMIs via `nixos-generators` or `packer + nix`.

## Recommendation
Start with **Amazon Linux managed node groups**. Explore NixOS later.

---

> **Uddhava Gītā (SB 11.7.41)**  
> *ātmaupamyena bhūteṣu dayāṁ kurvanti sūrayaḥ* [#SB-11.7.41]  
> **Translation (ISKCON):** "Saintly persons extend mercy to all living beings, seeing them as equal to themselves."
