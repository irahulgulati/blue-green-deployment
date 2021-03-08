module "my_blue_vpc" {
  source   = "../modules/vpc"
  vpc_cidr = var.vpc_cidr
  name     = "Blue_Green_VPC"
}

module "my_peering_vpc" {
  source   = "../modules/vpc"
  vpc_cidr = var.vpc2_cidr
  name     = "vpc2"
}


module "Blue_Green_Gateway" {
  source = "../modules/internet_gateway"
  vpc_id = module.my_blue_vpc.vpc.id
  name   = "Blue_Green_Gateway"
}


module "vpc2_private_subnet" {
  source            = "../modules/subnet"
  name              = "vpc2_private_subnet"
  vpc_id            = module.my_peering_vpc.vpc.id
  subnet_cidr       = var.vpc2_private_subnet_cidr
  availability_zone = "ap-southeast-1a"
}

module "nginx_private_subnet_1" {
  source            = "../modules/subnet"
  name              = "nginx_private_subnet_1"
  vpc_id            = module.my_blue_vpc.vpc.id
  subnet_cidr       = var.nginx_private_subnet_1_cidr
  availability_zone = "ap-southeast-1a"
}

module "nginx_private_subnet_2" {
  source            = "../modules/subnet"
  name              = "nginx_private_subnet_2"
  vpc_id            = module.my_blue_vpc.vpc.id
  subnet_cidr       = var.nginx_private_subnet_2_cidr
  availability_zone = "ap-southeast-1b"
}


module "app_server_subnet_1" {
  source            = "../modules/subnet"
  name              = "app_server_subnet_1"
  vpc_id            = module.my_blue_vpc.vpc.id
  subnet_cidr       = var.app_server_subnet_1_cidr
  availability_zone = "ap-southeast-1a"
}

module "app_server_subnet_2" {
  source            = "../modules/subnet"
  name              = "app_server_subnet_2"
  vpc_id            = module.my_blue_vpc.vpc.id
  subnet_cidr       = var.app_server_subnet_2_cidr
  availability_zone = "ap-southeast-1b"
}


module "public_subnet_1" {
  source            = "../modules/subnet"
  name              = "public_subnet_1"
  vpc_id            = module.my_blue_vpc.vpc.id
  subnet_cidr       = var.public_subnet_1_cidr
  availability_zone = "ap-southeast-1a"
}

module "public_subnet_2" {
  source            = "../modules/subnet"
  name              = "public_subnet_2"
  vpc_id            = module.my_blue_vpc.vpc.id
  subnet_cidr       = var.public_subnet_2_cidr
  availability_zone = "ap-southeast-1b"
}

module "public_route_table_for_lb_1" {
  source = "../modules/route_table"
  name   = "public_route_table_for_lb_1"
  vpc_id = module.my_blue_vpc.vpc.id
  route = [
    {
      "cidr_block" : var.default_cidr,
      "egress_only_gateway_id" : null,
      "gateway_id" : module.Blue_Green_Gateway.ig.id,
      "instance_id" : null,
      "ipv6_cidr_block" : null,
      "local_gateway_id" : null,
      "nat_gateway_id" : null,
      "network_interface_id" : null,
      "transit_gateway_id" : null,
      "vpc_endpoint_id" : null,
      "vpc_peering_connection_id" : null
    }
  ]
}

module "private_route_table_for_peering_connection" {
  source = "../modules/route_table"
  name   = "private_route_table_for_peering_connection"
  vpc_id = module.my_blue_vpc.vpc.id
  route = [
    {
      "cidr_block" : var.vpc2_cidr,
      "egress_only_gateway_id" : null,
      "gateway_id" : module.Blue_Green_Gateway.ig.id,
      "instance_id" : null,
      "ipv6_cidr_block" : null,
      "local_gateway_id" : null,
      "nat_gateway_id" : null,
      "network_interface_id" : null,
      "transit_gateway_id" : null,
      "vpc_endpoint_id" : null,
      "vpc_peering_connection_id" : module.vpc1_vpc2_peering_connection.peering_connection.id
    }
  ]
}

resource "aws_route_table_association" "route_table_public_subnet_1_association" {
  subnet_id      = module.public_subnet_1.subnet.id
  route_table_id = module.public_route_table_for_lb_1.rt.id
}

resource "aws_route_table_association" "route_table_peering_connection_subnet_assoctiaion" {
  subnet_id      = module.app_server_subnet_1.subnet.id
  route_table_id = module.private_route_table_for_peering_connection.rt.id
}

resource "aws_route_table_association" "route_table_peering_connection_subnet_assoctiaion_2" {
  subnet_id      = module.app_server_subnet_1.subnet.id
  route_table_id = module.private_route_table_for_peering_connection.rt.id
}

module "public_lb_blue" {
  source                     = "../modules/load_balancer"
  name                       = "public-lb-blue"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [module.public_lb_blue_sg.sg.id]
  subnet_id                 = [module.public_subnet_1.subnet.id, module.public_subnet_2.subnet.id]
  enable_deletion_protection = false

  Environment = "dev"
}

module "public_lb_blue_tg" {
  source   = "../modules/target_groups"
  name     = "public-lb-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_blue_vpc.vpc.id
}

resource "aws_lb_listener" "public_lb_blue_endpoint" {
  load_balancer_arn = module.public_lb_blue.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.public_lb_blue_tg.tg.arn
  }
}

module "private_lb" {
  source                     = "../modules/load_balancer"
  name                       = "private-lb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [module.private_lb_sg.sg.id]
  subnet_id                 = [module.app_server_subnet_1.subnet.id, module.app_server_subnet_2.subnet.id]
  enable_deletion_protection = false

  Environment = "dev"
}

module "private_lb_blue_tg" {
  source   = "../modules/target_groups"
  name     = "private-lb-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_blue_vpc.vpc.id
}

resource "aws_lb_listener" "private_lb_endpoint" {
  load_balancer_arn = module.private_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.private_lb_blue_tg.tg.arn
  }
}

module "public_lb_blue_sg" {
  source = "../modules/security_group"
  name   = "public_lb_blue_sg"
  vpc_id = module.my_blue_vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : [var.default_cidr],
      "description" : "allow from vpc1 public servers",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null
      "to_port" : 80

    }
  ]
  egress_routes = [
      {
      "cidr_blocks" : [var.default_cidr],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
}

module "private_nginx_sg" {
  source = "../modules/security_group"
  name   = "private_nginx_sg"
  vpc_id = module.my_blue_vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : null,
      "description" : "allow traffic from public lb only",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : [module.public_lb_blue_sg.sg.id],
      "self" : null
      "to_port" : 80

    }
  ]
  egress_routes = [
      {
      "cidr_blocks" : [var.default_cidr],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
}

module "private_lb_sg" {
  source = "../modules/security_group"
  name   = "private_lb_sg"
  vpc_id = module.my_blue_vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : null,
      "description" : "allow traffic from nginx servers only",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : [module.private_nginx_sg.sg.id],
      "self" : null
      "to_port" : 80

    }
  ]
  egress_routes = [
      {
      "cidr_blocks" : [var.default_cidr],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
}

module "app_server_sg" {
  source = "../modules/security_group"
  name   = "app_server_sg"
  vpc_id = module.my_blue_vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : null,
      "description" : "allow traffic from nginx servers only",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : [module.private_lb_sg.sg.id],
      "self" : null
      "to_port" : 80

    }
  ]
  egress_routes = [
      {
      "cidr_blocks" : [var.default_cidr],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
}

data "aws_ami" "nginx_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["nginxAMI"]
  }

  owners = [var.owner_account_id]
}

data "aws_ami" "app_server_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["appServerAMI"]
  }

  owners = [var.owner_account_id]
}

module "nginx_launch_template" {
  source             = "../modules/launch_template"
  name               = "nginx_launch_template"
  ami                = data.aws_ami.nginx_ami.id
  instance_type      = "t2.micro"
  shutdown_behavior  = "terminate"
  key_name           = "tf-practice-aws"
  security_groups_id = [module.private_nginx_sg.sg.id]
  depends_on = [
    module.public_lb_blue
  ]
#   user_data = base64encode(templatefile("../templates/update_private_lb_dns_name.tpl", {
#     lb_dns_name : module.public_lb_blue.lb.dns_name
#     }
#   ))
}

module "nginx_private_asg" {
  source             = "../modules/auto_scaling_group"
  name               = "nginx_private_asg"
  max_size           = 2
  min_size           = 2
  health_check_type  = "ELB"
  desired_capacity   = 2
  force_delete       = true
  subnet_ids         = [module.nginx_private_subnet_1.subnet.id, module.nginx_private_subnet_2.subnet.id]
  target_group_arns  = [module.public_lb_blue_tg.tg.arn]
  launch_template_id = module.nginx_launch_template.lt.id
}

module "app_server_launch_template" {
  source             = "../modules/launch_template"
  name               = "app_launch_template"
  ami                = data.aws_ami.app_server_ami.id
  instance_type      = "t2.micro"
  shutdown_behavior  = "terminate"
  key_name           = "tf-practice-aws"
  security_groups_id = [module.app_server_sg.sg.id]

  depends_on = [
    module.private_lb
  ]

#   user_data = base64encode(templatefile("../templates/update_private_lb_dns_name.tpl", {
#     lb_dns_name : module.private_lb.lb.dns_name
#     }
#   ))
}

module "app_server_asg" {
  source             = "../modules/auto_scaling_group"
  name               = "app_private_asg"
  max_size           = 2
  min_size           = 2
  health_check_type  = "ELB"
  desired_capacity   = 2
  force_delete       = true
  subnet_ids         = [module.app_server_subnet_1.subnet.id, module.app_server_subnet_2.subnet.id]
  target_group_arns  = [module.private_lb_blue_tg.tg.arn]
  launch_template_id = module.app_server_launch_template.lt.id
}

module "vpc1_vpc2_peering_connection" {
  source        = "../modules/vpc_peering_connection"
  peer_owner_id = var.owner_account_id
  other_vpc_id  = module.my_peering_vpc.vpc.id
  own_vpc_id    = module.my_blue_vpc.vpc.id
  peer_region   = null
  auto_accept   = true
  name          = "vpc1_vpc2_peering_connection"
}

module "route53_blue_record" {
  source                = "../modules/route53"
  zone_id               = var.zone_id
  domain_name           = var.domain_name
  record_type           = var.record_type
  ttl                   = var.ttl
  weight                = var.weight
  dns_record_identifier = var.dns_record_identifier
  lb_dns_name           = module.public_lb_blue.lb.dns_name
}

module "vpc2_efs_sg" {
  source = "../modules/security_group"
  vpc_id = module.my_peering_vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : null,
      "description" : "allow from vpc1 public servers",
      "from_port" : 2049,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : [module.app_server_sg.sg.id],
      "self" : null,
      "to_port" : 2049
    }
  ]
  egress_routes = [
    {
      "cidr_blocks" : [var.default_cidr],
      "description" : "Allow all",
      "from_port" : 0,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "-1",
      "security_groups" : null,
      "self" : null,
      "to_port" : 0
    }
  ]
  name = "vpc2_efs_sg"
}

module "vpc2_efs" {
  source          = "../modules/efs"
  efs_token       = "nugen-efs"
  subnet_id       = module.vpc2_private_subnet.subnet.id
  security_groups = [module.vpc2_efs_sg.sg.id]
}