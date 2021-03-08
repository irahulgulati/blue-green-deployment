resource "aws_launch_template" "lt" {
  name = var.name
  image_id = var.ami
  instance_initiated_shutdown_behavior = var.shutdown_behavior
  instance_type = var.instance_type
  key_name = var.key_name

  vpc_security_group_ids = var.security_groups_id

  user_data = var.user_data

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.name
    }
  }
}