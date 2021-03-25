# terraform {
#   backend "s3" {
#     bucket = "pro-bros-terraform"
#     key = "dev/tfstate.tfstate"
#     region = ""
#     encrypt = true
#   }
# }


provider "aws" {
  region  = "ap-northeast-1"
}


locals {
  common_tags = {
    Application = "Blue"
  }
}


// /*
//   vpc module that creates
//   vpc with given name as 
//   argument in tag
// */

module "public_lb_tg" {
  source   = "../../modules/target_groups"
  name     = "public-lb-1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc.id
}

module "public_lb_1" {
  source             = "../../modules/load_balancer"
  name               = "public-lb-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.lb_public_sg_1.sg.id]
  subnet_id          = [module.lb_public_subnet_1.subnet.id, module.lb_public_subnet_2.subnet.id]

  enable_deletion_protection = false

  Environment = "dev"
}

resource "aws_lb_listener" "lb_endpoint_1" {
  load_balancer_arn = module.public_lb_1.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.public_lb_tg.tg.arn
  }
}

module "private_lb_tg" {
  source   = "../../modules/target_groups"
  name     = "private-lb-1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc.id
}

module "private_lb_1" {
  source             = "../../modules/load_balancer"
  name               = "private-lb-1"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.lb_private_sg_1.sg.id]
  subnet_id          = [module.lb_private_subnet.subnet.id, module.lb_private_subnet_2.subnet.id]

  enable_deletion_protection = false

  Environment = "dev"
}

resource "aws_lb_listener" "lb_endpoint_2" {
  load_balancer_arn = module.private_lb_1.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.private_lb_tg.tg.arn
  }
}

data "aws_ami" "nginx_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packerAMI"]
  }

  owners = ["345117372609"]
}

data "aws_ami" "app_server_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packerApacheAMI"]
  }

  owners = ["345117372609"]
}

module "nginx_public_launch_template" {
  source             = "../../modules/launch_template"
  name               = "nginx_public_launch_template"
  ami                = data.aws_ami.nginx_ami.id
  instance_type      = "t2.micro"
  shutdown_behavior  = "terminate"
  key_name           = "tf-practice-aws"
  security_groups_id = [module.webserver_private_sg_1.sg.id]
  depends_on = [
    module.private_lb_1
  ]
  user_data = base64encode(templatefile("../../templates/update_private_lb_dns_name.tpl", {
    lb_dns_name : module.private_lb_1.lb.dns_name
    }
  ))
}

module "nginx-private_asg-1" {
  source             = "../../modules/auto_scaling_group"
  name               = "nginx-private_asg-1"
  max_size           = 2
  min_size           = 2
  health_check_type  = "ELB"
  desired_capacity   = 2
  force_delete       = true
  subnet_ids         = [module.nginx_private_subnet.subnet.id, module.nginx_private_subnet_2.subnet.id]
  target_group_arns  = [module.public_lb_tg.tg.arn]
  launch_template_id = module.nginx_public_launch_template.lt.id
}

module "app_private_launch_template" {
  source             = "../../modules/launch_template"
  name               = "app_private_launch_template"
  ami                = data.aws_ami.app_server_ami.id
  instance_type      = "t2.micro"
  shutdown_behavior  = "terminate"
  key_name           = "tf-practice-aws"
  security_groups_id = [module.appserver_private_sg_1.sg.id]
}

module "app-private_asg-1" {
  source             = "../../modules/auto_scaling_group"
  name               = "app-private_asg-1"
  max_size           = 2
  min_size           = 2
  health_check_type  = "ELB"
  desired_capacity   = 2
  force_delete       = true
  subnet_ids         = [module.app_server_private_subnet.subnet.id, module.app_server_private_subnet_2.subnet.id]
  target_group_arns  = [module.private_lb_tg.tg.arn]
  launch_template_id = module.app_private_launch_template.lt.id
}


# module "vpc2_efs_sg" {
#   source = "../../modules/security_group"
#   vpc_id = module.vpc2.vpc.id
#   ingress_routes = [
#     {
#       "cidr_blocks" : null,
#       "description" : "allow from vpc1 public servers",
#       "from_port" : 2049,
#       "ipv6_cidr_blocks" : null,
#       "prefix_list_ids" : null,
#       "protocol" : "tcp",
#       "security_groups" : [module.webserver_private_sg_1.sg.id],
#       "self" : null,
#       "to_port" : 2049
#     }
#   ]
#   egress_routes = [
#     {
#       "cidr_blocks" : [var.default_cidr],
#       "description" : "Allow all",
#       "from_port" : 0,
#       "ipv6_cidr_blocks" : null,
#       "prefix_list_ids" : null,
#       "protocol" : "-1",
#       "security_groups" : null,
#       "self" : null,
#       "to_port" : 0
#     }
#   ]
#   name = "vpc2_efs_sg"

#   tags = merge(local.common_tags, {Type = "EFS"})
# }

# module "vpc2_efs" {
#   source          = "../../modules/efs"
#   efs_token       = "nugen-efs"
#   subnet_id       = module.vpc2_private_subnet.subnet.id
#   security_groups = [module.vpc2_efs_sg.sg.id]
# }

module "route53_record" {
    source = "../../modules/route53_record"

    zone_id = var.zone_id
    record_name = var.record_name
    record_type = var.record_type
    ttl = var.ttl
    weight = var.weight
    record_identifier_id = var.record_identifier_id
    lb_dns_name = module.public_lb_1.lb.dns_name
}
