variable "lb_dns_name" {
    type  = string
}

variable "domain_name"{
    type = string
}

variable "zone_id" {
    type = string
}

variable  "ttl" {
    type = number
}

variable "weight"{
    type = number
}

variable "record_type"{
    type = string
}

variable "dns_record_identifier"{
    type = string
}