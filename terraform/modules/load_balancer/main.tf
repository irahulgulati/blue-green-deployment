resource "aws_lb" "lb" {
  name = var.name
  internal =  var.internal
  load_balancer_type = var.load_balancer_type
  security_groups = var.security_groups
  subnets =  var.subnet_id

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Environment = var.Environment
  }
}