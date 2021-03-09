resource "aws_route53_record" "route53_record" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  weighted_routing_policy {
    weight = var.weight
  }

  set_identifier = var.record_identifier_id
  records        = [var.lb_dns_name]
}