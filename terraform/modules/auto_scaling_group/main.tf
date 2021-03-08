resource "aws_autoscaling_group" "asg" {
  name                      = var.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = var.health_check_type
  desired_capacity          = var.desired_capacity
  force_delete              = var.force_delete
  launch_template {
    id = var.launch_template_id
    version = "$Latest"
  }

//   availability_zones = var.availability_zones
  vpc_zone_identifier  = var.subnet_ids
  target_group_arns = var.target_group_arns

  timeouts {
    delete = "15m"
  }
}
