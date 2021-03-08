/*
//   variables to set vpc networking
// */
variable "owner_account_id" {
  default = "345117372609"
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "vpc2_cidr" {
  default = "172.31.0.0/16"
}


variable "default_cidr" {
  default = "0.0.0.0/0"
}

variable "vpc2_private_subnet_cidr" {
    default = "172.31.0.0/24"
}

variable "public_subnet_1_cidr" {
  default = "10.0.1.0/24"
}
variable "public_subnet_2_cidr" {
  default = "10.0.2.0/24"
}


variable "nginx_private_subnet_1_cidr" {
  default = "10.0.3.0/24"
}
variable "nginx_private_subnet_2_cidr" {
  default = "10.0.4.0/24"
}


variable "app_server_subnet_1_cidr" {
  default = "10.0.5.0/24"
}
variable "app_server_subnet_2_cidr" {
  default = "10.0.6.0/24"
}


variable "zone_id" {
  default = "Z069937830WDWNR81YFNM"
}
variable "domain_name" {
  default = "astf.cloudeq.com"
}
variable "record_type" {
  default = "CNAME"
}
variable "ttl" {
  default = 300
}
variable "weight" {
  default = 100
}
variable "dns_record_identifier" {
    default = "bluedns"
}