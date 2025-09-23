locals {
  use_dns = length(var.domain_name) > 0
}

resource "aws_route53_zone" "this" {
  count = local.use_dns && var.hosted_zone_id == "" ? 1 : 0
  name  = var.domain_name
  tags  = local.tags
}

data "aws_route53_zone" "existing" {
  count  = local.use_dns && var.hosted_zone_id != "" ? 1 : 0
  zone_id = var.hosted_zone_id
}

locals {
  zone_id = local.use_dns ? (
    var.hosted_zone_id != "" ? data.aws_route53_zone.existing[0].zone_id :
    aws_route53_zone.this[0].zone_id
  ) : ""
}

# Placeholder A record (fill after ALB exists)
resource "aws_route53_record" "site" {
  count   = local.use_dns ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = "REPLACE-ALB-DNS-NAME"
    zone_id                = "REPLACE-ALB-HOSTED-ZONE-ID"
    evaluate_target_health = false
  }
}