terraform {
    required_version = ">= 0.14.5"
}

resource "aws_instance" "tf_practice_instance_1" {
    ami = var.ami_id
    instance_type = var.instance_type
    associate_public_ip_address = var.associate_public_ip
    subnet_id = var.subnet_id
    private_ip = var.tf_instance_ip_address
    security_groups = var.security_groups
    key_name = var.key_name
}