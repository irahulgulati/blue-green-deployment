resource "aws_efs_file_system" "efs" {
  creation_token = var.efs_token
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_id
  security_groups = var.security_groups
}


