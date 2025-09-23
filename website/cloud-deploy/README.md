# Cloud Deploy – AWS EKS (Kubernetes) with Nix

> **Uddhava Gītā (SB 11.19.36)**  
> *dayā bhūteṣu santuṣṭiḥ titikṣoparatiḥ śamaḥ* [#SB-11.19.36a]  
> *ahimsā satyam asteyam ity ādīnāṁ samāsataḥ* [#SB-11.19.36b]  
> **Translation (ISKCON):** "Compassion, contentment, tolerance, peace, non-violence, truth and honesty are to be cultivated."

This is the **MantraOS PBC admin runbook** for deploying the website on Kubernetes (EKS).

## Architecture

- **App**: static Svelte site → served by NGINX container
- **K8s**: Deployment + Service + Ingress (ALB) + HPA (optional)
- **EKS**: managed control plane
- **Nodes**:
  - **Recommended**: standard Amazon Linux managed node groups (simplest)
  - **Advanced**: **self-managed NixOS node group** (see `nixos-notes.md`)

## Prerequisites

- AWS account, IAM permissions for EKS, VPC, ALB
- `awscli`, `kubectl`, `helm` (or `nix develop`)
- Container registry (ECR recommended)

## One-time setup (high level)

1) **ECR repo**:
```bash
aws ecr create-repository --repository-name mantraos/site
```

2. **Build & push image**:

```bash
docker build -t mantraos/site:$(git rev-parse --short HEAD) ..
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <ACCOUNT>.dkr.ecr.<REGION>.amazonaws.com
docker tag mantraos/site:$(git rev-parse --short HEAD) <ACCOUNT>.dkr.ecr.<REGION>.amazonaws.com/mantraos/site:$(git rev-parse --short HEAD)
docker push <ACCOUNT>.dkr.ecr.<REGION>.amazonaws.com/mantraos/site:$(git rev-parse --short HEAD)
```

3. **Create EKS cluster (fast path)**:

```bash
eksctl create cluster --name mantraos-web --region <REGION> --nodes 2 --node-type t3.medium
```

4. **Install AWS Load Balancer Controller (for Ingress)**:

• See upstream docs; required for ALB-backed Ingress.

5. **Set up DNS (Route53) once ALB is created.**

## Deploy (manifests)

```bash
kubectl apply -f k8s/namespace.yaml
kubectl -n mantraos apply -f k8s/deployment.yaml
kubectl -n mantraos apply -f k8s/service.yaml
kubectl -n mantraos apply -f k8s/ingress.yaml
```

## Scale / Rollout

```bash
kubectl -n mantraos set image deploy/mantraos-site mantraos-site=<ECR>/mantraos/site:<new-tag>
kubectl -n mantraos rollout status deploy/mantraos-site
kubectl -n mantraos get ingress,svc,deploy,pods
```

## Notes
• For NixOS on EKS nodes, see `nixos-notes.md`.
• For Helm usage, see `helm/` folder (values + templates).

---

> **Uddhava Gītā (SB 11.7.41)**  
> *ātmaupamyena bhūteṣu dayāṁ kurvanti sūrayaḥ* [#SB-11.7.41]  
> **Translation (ISKCON):** "Saintly persons extend mercy to all living beings, seeing them as equal to themselves."
