variable "project"           { description = "Project name prefix"; type = string }
variable "region"            { description = "AWS region"; type = string; default = "us-west-2" }
variable "cluster_name"      { description = "EKS cluster name"; type = string }
variable "node_instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}
variable "desired_size" { description = "Desired node count"; type = number; default = 2 }
variable "min_size"     { description = "Minimum node count"; type = number; default = 2 }
variable "max_size"     { description = "Maximum node count"; type = number; default = 5 }
variable "domain_name"  { description = "Root domain (optional)"; type = string; default = "" }
variable "hosted_zone_id" { description = "Existing Route53 zone ID (optional)"; type = string; default = "" }
