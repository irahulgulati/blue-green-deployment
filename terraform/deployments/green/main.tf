provider "aws" {
  region  = "ap-northeast-1"
}

data "aws_vpc" "vpc" {
    tags = {
        Application = "Blue"
    }
}

data "aws_subnet" "public_lb_subnets_1" {
  tags = {
      Application = "Blue"
      LB_Type     = "External"
      Count       = "1"
  }
}

data "aws_subnet" "public_lb_subnets_2" {
  tags = {
      Application = "Blue"
      LB_Type     = "External"
      Count       = "2"
  }
}

data "aws_security_group" "public_lb_sg" {

    tags = {
        Application = "Blue"
        LB_Type     = "External"
    }
}

module "public_lb_1" {
  source             = "../../modules/load_balancer"
  name        = "public-lb-green"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.public_lb_sg.id]
  subnet_id          = [data.aws_subnet.public_lb_subnets_1.id, data.aws_subnet.public_lb_subnets_2.id]

  enable_deletion_protection = false

  Environment = "dev"
}

module "public_lb_tg" {
  source   = "../../modules/target_groups"
  name = "public-lb-tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id
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


data "aws_subnet" "private_lb_subnets_1" {
    tags = {
        Application = "Blue"
        LB_Type     = "Internal"
        Count       = "1"
    }
}

data "aws_subnet" "private_lb_subnets_2" {
    tags = {
        Application = "Blue"
        LB_Type     = "Internal"
        Count       = "2"
    }
}

data "aws_security_group" "private_lb_sg" {
    tags = {
        Application = "Blue"
        LB_Type     = "Internal"
    }
}

module "private_lb_tg" {
  source   = "../../modules/target_groups"
  name = "private-lb-tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id
}

module "private_lb_1" {
  source             = "../../modules/load_balancer"
  name       = "private-lb-green"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.private_lb_sg.id]
  subnet_id          = [data.aws_subnet.private_lb_subnets_1.id, data.aws_subnet.private_lb_subnets_2.id]

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
    values = ["packerApacheGreenAMI"]
  }

  owners = ["345117372609"]
}

data "aws_security_group" "nginx_servers_sg" {
  count = 1
    tags = {
        Application = "Blue"
        Type      = "NginxServers",
        Count       = "1"
    }
}


module "nginx_public_launch_template" {
  source             = "../../modules/launch_template"
  name        = "nginx_public_launch_template_green"
  ami                = data.aws_ami.nginx_ami.id
  instance_type      = "t2.micro"
  shutdown_behavior  = "terminate"
  key_name           = "tf-practice-aws"
  security_groups_id = [data.aws_security_group.nginx_servers_sg[0].id]
  depends_on = [
    module.private_lb_1
  ]
  user_data = base64encode(templatefile("../../templates/update_private_lb_dns_name.tpl", {
    lb_dns_name : module.private_lb_1.lb.dns_name
    }
  ))
}

data "aws_subnet" "nginx_servers_subnets_1" {
    tags = {
        Application = "Blue"
        Type     = "NginxServers"
        Count     = "1"
    }
}

data "aws_subnet" "nginx_servers_subnets_2" {
    tags = {
        Application = "Blue"
        Type     = "NginxServers"
        Count     = "2"
    }
}

module "nginx-private_asg-1" {
  source             = "../../modules/auto_scaling_group"
  name        = "nginx-private_asg-green"
  max_size           = 2
  min_size           = 2
  health_check_type  = "ELB"
  desired_capacity   = 2
  force_delete       = true
  subnet_ids         = [data.aws_subnet.nginx_servers_subnets_1.id, data.aws_subnet.nginx_servers_subnets_2.id]
  target_group_arns  = [module.public_lb_tg.tg.arn]
  launch_template_id = module.nginx_public_launch_template.lt.id
}

data "aws_security_group" "app_servers_sg" {
    tags = {
        Application = "Blue"
        "Type"      = "AppServers"
    }
}

module "app_private_launch_template" {
  source             = "../../modules/launch_template"
  name        = "app_private_launch_template_green"
  ami                = data.aws_ami.app_server_ami.id
  instance_type      = "t2.micro"
  shutdown_behavior  = "terminate"
  key_name           = "tf-practice-aws"
  security_groups_id = [data.aws_security_group.app_servers_sg.id]
}

data "aws_subnet" "app_servers_subnets_1" {
    tags = {
        Application = "Blue"
        Type     = "AppServers"
        Count     = "1"
    }
}

data "aws_subnet" "app_servers_subnets_2" {
    tags = {
        Application = "Blue"
        Type     = "AppServers"
        Count     = "2"
    }
}

module "app-private_asg-1" {
  source             = "../../modules/auto_scaling_group"
  
  name        = "app-private_asg-green"
  max_size           = 2
  min_size           = 2
  health_check_type  = "ELB"
  desired_capacity   = 2
  force_delete       = true
  subnet_ids         = [data.aws_subnet.app_servers_subnets_1.id, data.aws_subnet.app_servers_subnets_2.id]
  target_group_arns  = [module.private_lb_tg.tg.arn]
  launch_template_id = module.app_private_launch_template.lt.id
}

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

# data "aws_lb" "lb" {
#   name = var.lb_name
# }