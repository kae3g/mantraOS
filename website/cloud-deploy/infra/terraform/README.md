# 🌥️ MantraOS – Terraform Infra (AWS EKS + ECR + Route53)

> **Uddhava Gītā (SB 11.19.36)**  
> *dayā bhūteṣu santuṣṭiḥ titikṣoparatiḥ śamaḥ* [#SB-11.19.36a]  
> *ahimsā satyam asteyam ity ādīnāṁ samāsataḥ* [#SB-11.19.36b]  
> **Translation (ISKCON):** "Compassion, contentment, tolerance, peace, non-violence, truth and honesty are to be cultivated."

This stack provisions a production-ready base:
- **VPC** (public/private subnets, NAT)
- **EKS** (managed control plane + managed node groups)
- **ECR** (container registry)
- **Route53** (optional; public zone + A/ALIAS record)

## Requirements

- Terraform ≥ 1.5, AWS IAM for EKS/VPC/Route53/ECR, `kubectl`, `awscli`, `helm`

## Remote state (recommended)

Create S3 bucket + DynamoDB table once, then put values into `backend.hcl` and:

```bash
terraform init -backend-config=backend.hcl
```

## Variables

Create `terraform.tfvars`:

```hcl
project      = "mantraos"
region       = "us-west-2"
cluster_name = "mantraos-web"
domain_name  = "mantraos.example.org"  # optional
hosted_zone_id = ""                     # use existing zone or let TF create one
node_instance_types = ["t3.medium"]
desired_size = 2
min_size     = 2
max_size     = 5
```

## Apply

```bash
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region $(terraform output -raw region)
kubectl get nodes -o wide
```

---

> **Uddhava Gītā (SB 11.7.41)**  
> *ātmaupamyena bhūteṣu dayāṁ kurvanti sūrayaḥ* [#SB-11.7.41]  
> **Translation (ISKCON):** "Saintly persons extend mercy to all living beings, seeing them as equal to themselves."
