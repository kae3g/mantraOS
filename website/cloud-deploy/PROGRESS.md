# 🌿 MantraOS Progress Log – Website & Cloud Deploy

> **Uddhava Gītā (Śrīmad-Bhāgavatam 11.10.4)**  
> *yadṛcchayā mat-kathādau jāta-śraddhas tu yaḥ pumān*  
> *na nirvinno nāti-sakto bhakti-yogo 'sya siddhi-daḥ*  
> **Translation (ISKCON):**  
> "A person who develops faith in hearing narrations about Me,  
> who is neither too detached nor overly attached, is assured of perfection in bhakti-yoga."

---

## 🪔 Where We Began

- **001-sadhana.md** set the spiritual foundation.  
- We unfolded the **curriculum scrolls (`030-edu/`)**, linking each stage like lanterns in a forest.  
- Added **REPOSITORY.md** to map the whole repo like a village map.  
- Created **CONTRIBUTING.md** and **CONTRIBUTING-tech.md** to welcome all companions.  
- Drafted **FUNDING.md** (Public Benefit Corporation vision).  
- Added **assets/logo-prompt.md** for dragon iconography guidance.  
- Built **cloud-deploy** scaffolding for Kubernetes on AWS EKS with NixOS options.

---

## 🧭 Progress in Cloud Deployment

- **Terraform scaffolding**:  
  - VPC, EKS, IAM roles (already in place).  
  - Added `addons.tf` for **AWS Load Balancer Controller**.  
  - Added `externaldns-irsa.tf` and `externaldns-helm.tf` for Route53 automation.  
  - Added `acm.tf` for DNS-validated TLS certificates.  

- **Ingress layer**:  
  - ALB Ingress with annotations for ACM certificate + ExternalDNS.  
  - Host-based routing ready for `your.domain.example.org`.  

- **CI/CD**:  
  - GitHub Actions pipeline (`deploy-website.yml`) builds + pushes to ECR + applies manifests.  
  - OIDC IAM role configured for secure GitHub → AWS trust.  

- **Namespaces**:  
  - `mantraos` production namespace in place.  
  - Staging namespace recommended for safe testing (`mantraos-staging`).  

---

## 🔭 Next Steps

1. **Helm Chart Unification**  
   - Convert raw `k8s/` manifests into a single Helm chart.  
   - Values: `domain`, `certArn`, `namespace`, `replicas`.  
   - Terraform `helm_release` → declarative deploy.

2. **Environments**  
   - Split staging vs production with different hostnames + certs.  
   - Add `namespace-staging.yaml`.

3. **Observability**  
   - Enable ALB access logs (S3).  
   - Add `kubectl events` to CI output.  
   - Consider Prometheus + Grafana later.

4. **Budgets & Security**  
   - AWS Budgets alarm for cost control.  
   - (Optional) AWS WAFv2 on ALB.  
   - IRSA for any pods with AWS API needs.

5. **NixOS exploration**  
   - Keep managed Amazon Linux nodes.  
   - Document optional NixOS nodegroup migration (Launch Templates + AMI).  

---

## 🔔 Reminders

- CI now checks for **relative links + nav ribbons** in Markdown.  
- If deeper subdirectories are added later, update `scripts/check-relative-links.sh` to handle them.  
- ExternalDNS must be limited to your hosted zone for safety.  
- ACM cert ARN must match the one Terraform outputs.  

---

> **Uddhava Gītā (Śrīmad-Bhāgavatam 11.29.34)**  
> *bhaktyāham ekayā grāhyaḥ śraddhayātmā priyaḥ satām*  
> *bhaktir mama priyā yāvān mayy ātmā ca yathā priyaḥ*  
> **Translation (ISKCON):**  
> "I am attained only by unalloyed devotion.  
> Devotion is dear to Me, just as the devotee is dear,  
> and the devotee regards Me as dear as his own self."
