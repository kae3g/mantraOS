output "region"            { value = var.region }
output "eks_cluster_name"  { value = module.eks.cluster_name }
output "ecr_url"           { value = aws_ecr_repository.site.repository_url }
output "vpc_id"            { value = module.vpc.vpc_id }
output "private_subnets"   { value = module.vpc.private_subnets }
output "public_subnets"    { value = module.vpc.public_subnets }
output "route53_zone_id" {
  value       = length(var.domain_name) > 0 ? (var.hosted_zone_id != "" ?
  data.aws_route53_zone.existing[0].zone_id : aws_route53_zone.this[0].zone_id)
  : ""
  description = "If DNS is enabled, the public hosted zone ID"
}
