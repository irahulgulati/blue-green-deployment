variable "name" {
    type = string
}

variable "ingress_routes" {
    type = list(any)
}

variable "egress_routes" {
    type = list(any)
}

variable "vpc_id" {
    type = string
}