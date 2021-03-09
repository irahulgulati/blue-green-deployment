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

module "lb_public_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "lb_public_subnet_2"
  subnet_cidr       = var.lb_public_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {LB_Type = "External", Count = "2"})
}

module "nginx_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "nginx_private_subnet"
  subnet_cidr       = var.nginx_private_subnet_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {Type = "NginxServers", Count = "1"})
}

module "nginx_private_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "nginx_private_subnet_2"
  subnet_cidr       = var.nginx_private_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {Type = "NginxServers", Count = "2"})
}

module "lb_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "lb_private_subnet"
  subnet_cidr       = var.lb_private_subnet_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {LB_Type = "Internal", Count = "1"})
}

module "lb_private_subnet_2" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "lb_private_subnet_2"
  subnet_cidr       = var.lb_private_subnet_2_cidr
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {LB_Type = "Internal", Count = "2"})
}

module "app_server_private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc.id
  name              = "app_server_private_subnet"
  subnet_cidr       = var.app_server_private_subnet_cidr
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {Type = "AppServers", Count = "1"})
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
  route_table_id = module.public_route_table.rt.id
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