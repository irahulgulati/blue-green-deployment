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
module "vpc" {
  source   = "../../modules/vpc"
  vpc_cidr = var.vpc_cidr

  tags = local.common_tags
}

# module "vpc2" {
#   source   = "../../modules/vpc"
#   vpc_cidr = var.vpc_cidr_2

#   tags = local.common_tags
# }

/*
  module that creates two
  internet gateway with
  given name in tag
*/
module "internet_gateway" {
  source = "../../modules/internet_gateway"
  vpc_id = module.vpc.vpc.id
  name   = "vpc1_ig"
}

/*
  * module that subnet
  * with given subnet cidr,
  * attach it to given vpc
  * and given name in tag
*/
# module "vpc2_private_subnet" {
#   source            = "../../modules/subnet"
#   vpc_id            = module.vpc2.vpc.id
#   name              = "vpc2_private_subnet"
#   subnet_cidr       = var.vpc2_private_subnet
#   availability_zone = "ap-northeast-1a"

#   tags = merge(local.common_tags, {Type = "PeeringSubnet"})
# }

module "lb_public_subnet_1" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "tf_public_subnet"
  subnet_cidr       = var.lb_public_subnet_1_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {LB_Type = "External", Count = "1"})
}

module "nginx_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "nginx_private_subnet"
  subnet_cidr       = var.nginx_private_subnet_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {Type = "NginxServers", Count = "1"})
}

module "lb_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "lb_private_subnet"
  subnet_cidr       = var.lb_private_subnet_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {LB_Type = "Internal", Count = "1"})
}

module "app_server_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "app_server_private_subnet"
  subnet_cidr       = var.app_server_private_subnet_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {Type = "AppServers", Count = "1"})
}

module "lb_public_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "lb_public_subnet_2"
  subnet_cidr       = var.lb_public_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {LB_Type = "External", Count = "2"})
}

module "nginx_private_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "nginx_private_subnet_2"
  subnet_cidr       = var.nginx_private_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {Type = "NginxServers", Count = "2"})
}

module "lb_private_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "lb_private_subnet_2"
  subnet_cidr       = var.lb_private_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {LB_Type = "Internal", Count = "2"})
}

module "app_server_private_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "app_server_private_subnet_2"
  subnet_cidr       = var.app_server_private_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {Type = "AppServers", Count = "2"})
}
/*
  module that route table
  with given list of routes,
  attach it to given vpc
  and given name in tag
*/
module "public_route_table" {
  source = "../../modules/route_table"
  vpc_id = module.vpc.vpc.id
  name   = "tf_practice_public_rt"
  route = [
    {
      "cidr_block" : var.default_cidr,
      "egress_only_gateway_id" : null,
      "gateway_id" : module.internet_gateway.ig.id,
      "instance_id" : null,
      "ipv6_cidr_block" : null,
      "local_gateway_id" : null,
      "nat_gateway_id" : null,
      "network_interface_id" : null,
      "transit_gateway_id" : null,
      "vpc_endpoint_id" : null,
      "vpc_peering_connection_id" : null
    },
    # {
    #   "cidr_block" : var.vpc_cidr_2,
    #   "egress_only_gateway_id" : null,
    #   "gateway_id" : null,
    #   "instance_id" : null,
    #   "ipv6_cidr_block" : null,
    #   "local_gateway_id" : null,
    #   "nat_gateway_id" : null,
    #   "network_interface_id" : null,
    #   "transit_gateway_id" : null,
    #   "vpc_endpoint_id" : null,
    #   "vpc_peering_connection_id" : module.vpc1_vpc2_peering_connection.peering_connection.id
    # }
  ]
}

module "public_route_table_2" {
  source = "../../modules/route_table"
  vpc_id = module.vpc.vpc.id
  name   = "lb_public_rt_2"
  route = [
    {
      "cidr_block" : var.default_cidr,
      "egress_only_gateway_id" : null,
      "gateway_id" : module.internet_gateway.ig.id,
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

/*
  creating route table
  association with subnet
*/
resource "aws_route_table_association" "tf_practice_rt_subnet_as" {
  subnet_id      = module.lb_public_subnet_1.subnet.id
  route_table_id = module.public_route_table.rt.id

}

resource "aws_route_table_association" "lb_public_rt_subnet_as" {
  subnet_id      = module.lb_public_subnet_2.subnet.id
  route_table_id = module.public_route_table_2.rt.id
}

/*
  module that  creates security
  groups with given list of
  ingress routes and egress routes,
  attach it to given vpc
  and given name in tag
*/

module "lb_public_sg_1" {
  source = "../../modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : [var.default_cidr],
      "description" : "allow http from world",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null,
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
  name = "lb_public_sg_1"

  tags = merge(local.common_tags, {LB_Type = "External"})
}

module "webserver_private_sg_1" {
  source = "../../modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : [var.lb_public_subnet_2_cidr],
      "description" : "allow http from world",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : null,
      "self" : null,
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
  name = "webserver_private_sg_1"

  tags = merge(local.common_tags, {Type = "NginxServers", Count = "1"})
}

module "lb_private_sg_1" {
  source = "../../modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : null,
      "description" : "allow http from nignx servers",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : [module.webserver_private_sg_1.sg.id],
      "self" : null,
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
  name = "lb_private_sg_1"

  tags = merge(local.common_tags, {LB_Type = "Internal"})
}

module "appserver_private_sg_1" {
  source = "../../modules/security_group"
  vpc_id = module.vpc.vpc.id
  ingress_routes = [
    {
      "cidr_blocks" : null,
      "description" : "allow http from world",
      "from_port" : 80,
      "ipv6_cidr_blocks" : null,
      "prefix_list_ids" : null,
      "protocol" : "tcp",
      "security_groups" : [module.lb_private_sg_1.sg.id],
      "self" : null,
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
  name = "appserver_private_sg_1"

  tags = merge(local.common_tags, {Type = "AppServers"})
}

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

# module "vpc1_vpc2_peering_connection" {
#   source        = "../../modules/vpc_peering_connection"
#   peer_owner_id = "271886995284"
#   other_vpc_id  = module.vpc2.vpc.id
#   own_vpc_id    = module.vpc.vpc.id
#   peer_region   = null
#   auto_accept   = true
#   name          = "vpc1_vpc2_peering_connection"
# }

# module "vpc2_private_route_table" {
#   source = "../../modules/route_table"
#   vpc_id = module.vpc2.vpc.id
#   name   = "tf_practice_public_rt"
#   route = [
#     {
#       "cidr_block" : var.vpc_cidr,
#       "egress_only_gateway_id" : null,
#       "gateway_id" : null,
#       "instance_id" : null,
#       "ipv6_cidr_block" : null,
#       "local_gateway_id" : null,
#       "nat_gateway_id" : null,
#       "network_interface_id" : null,
#       "transit_gateway_id" : null,
#       "vpc_endpoint_id" : null,
#       "vpc_peering_connection_id" : module.vpc1_vpc2_peering_connection.peering_connection.id
#     }
#   ]
# }

# module "vpc2_instance_sg" {
#   source = "../../modules/security_group"
#   vpc_id = module.vpc2.vpc.id
#   ingress_routes = [
#     {
#       "cidr_blocks" : [var.default_cidr],
#       "description" : "allow http from world",
#       "from_port" : 22,
#       "ipv6_cidr_blocks" : null,
#       "prefix_list_ids" : null,
#       "protocol" : "tcp",
#       "security_groups" : null,
#       "self" : null,
#       "to_port" : 22
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
#   name = "vpc2_instance_sg"

#   tags = merge(local.common_tags, {Type = "PeeringServer"})
# }

# resource "aws_route_table_association" "vpc2_practice_rt_subnet_as" {
#   subnet_id      = module.vpc2_private_subnet.subnet.id
#   route_table_id = module.vpc2_private_route_table.rt.id

# }

# module "instance_in_vpc2" {
#   source                 = "../../modules/instance"
#   ami_id                 = "ami-047a51fa27710816e"
#   instance_type          = "t2.micro"
#   associate_public_ip    = false
#   subnet_id              = module.vpc2_private_subnet.subnet.id
#   tf_instance_ip_address = var.vpc2_instance_private_ip
#   security_groups        = [module.vpc2_instance_sg.sg.id]
#   key_name               = "tf-practice-aws"
# }


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
