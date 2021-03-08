terraform {
    required_version = ">= 0.14.5"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = var.name
  }
}