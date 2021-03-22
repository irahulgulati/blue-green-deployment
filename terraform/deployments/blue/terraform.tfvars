vpc_cidr                         = "10.0.0.0/16"
tf_instance_ip_address           = "10.0.0.10"
default_cidr                     = "0.0.0.0/0"
lb_public_subnet_1_cidr          = "10.0.0.0/24"
nginx_private_subnet_cidr        = "10.0.1.0/24"
lb_private_subnet_cidr           = "10.0.2.0/24"
app_server_private_subnet_cidr   = "10.0.3.0/24"
lb_public_subnet_2_cidr          = "10.0.4.0/24"
nginx_private_subnet_2_cidr      = "10.0.5.0/24"
lb_private_subnet_2_cidr         = "10.0.6.0/24"
app_server_private_subnet_2_cidr = "10.0.7.0/24"
vpc_cidr_2                       = "172.31.0.0/16"
vpc2_private_subnet              = "172.31.0.0/24"
vpc2_instance_private_ip         = "172.31.0.22"

zone_id = "Z069937830WDWNR81YFNM"
record_name = "astf.cloudeq.com"
record_type = "CNAME"
ttl = 60
weight = 0
record_identifier_id = "asceqtf"