# ☁️ MantraOS Cloud Deploy – Reminders & Next Steps

> **Uddhava Gītā (SB 11.19.36)** *dayā bhūteṣu santuṣṭiḥ titikṣoparatiḥ śamaḥ*
> [#SB-11.19.36a] *ahimsā satyam asteyam ity ādīnāṁ samāsataḥ* [#SB-11.19.36b]
> **Translation (ISKCON):** "Compassion, contentment, tolerance, peace,
non-violence, truth and honesty are to be cultivated."

This document is a **living checklist** for the MantraOS PBC admin and
contributors working on the website deployment stack.

---

## ✅ Immediate Next Steps

- [ ] Replace placeholders in manifests/Helm:
  - `REPLACE_WITH_ECR_URI` `REPLACE_TAG` `REPLACE_WITH_DOMAIN`
- [ ] Confirm ECR repo exists:
  ```bash
  aws ecr describe-repositories --repository-names mantraos/site
  ```
- [ ] Test container locally:
  ```bash
  docker run -p 8080:80 mantraos/site:local
  ```
- [ ] Push image → ECR → update Deployment → rollout in EKS.

---

## 🌱 NixOS Worker Nodes (Advanced)

• Default = Amazon Linux managed node groups (simpler). • NixOS nodes require: •
Custom AMI (packer + nixos-generators). • Self-managed node group. • Maintaining
kubelet + containerd config. • See `nixos-notes.md`.

---

## 📈 Scaling & Resilience

• Add HPA (Horizontal Pod Autoscaler):

```bash
kubectl autoscale deploy mantraos-site --cpu-percent=70 --min=2 --max=5 -n
mantraos
```

• Readiness/liveness probes already configured. • Consider CloudFront CDN →
cache + TLS termination.

---

## 📜 Infrastructure as Code (Future)

• Add Terraform Helm releases (ALB Controller, cert-manager, External DNS). •
Consider GitOps (Flux/ArgoCD).

---

## 🔄 CI/CD Enhancements

• GitHub Actions builds & pushes the container. • Add deploy step (kubectl or
Helm) on main merges. • Consider staging + production namespaces.

---

## 📓 Documentation Reminders

• Admin runbook: rollbacks, IAM rotation, NixOS AMI regeneration. • Developer
guide: local run, PR process, validation.

---

## 🛡️ Security Considerations

• Restrict ECR permissions. • Consider IRSA if pods need AWS APIs. • Enforce
HTTPS with Ingress + ACM certs.

---

## 🕰️ Future Improvements

• SvelteKit SSR (routing & SEO). • CloudFront (or equivalent) for caching/TLS. •
Multi-region failover if needed.

---

## 🧪 CI Link-Audit Note

If you add deeper subdirectories in the future or special cases (like vendored
docs), you may need to adjust the link-audit script or CI ignore list: • Script:
`scripts/check-relative-links.sh` • CI workflow:
`.github/workflows/relative-links-check.yml`

---

> **Uddhava Gītā (SB 11.7.41)** *ātmaupamyena bhūteṣu dayāṁ kurvanti sūrayaḥ*
> [#SB-11.7.41] **Translation (ISKCON):** "Saintly persons extend mercy to all
> living beings,
seeing them as equal to themselves."
