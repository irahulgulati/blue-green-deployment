resource "aws_route53_record" "Route53_record" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = var.record_type
  ttl     = var.ttl

  weighted_routing_policy {
    weight = var.weight
  }

  set_identifier = var.dns_record_identifier
  records        = [var.lb_dns_name]
}