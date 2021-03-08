variable "name" {
    type = string
}

variable "internal" {
    type = bool
    default = false
}

variable "load_balancer_type" {
    type = string
    default = "application"
}

variable "security_groups" {
    type =  list(string)
}

variable "subnet_id"{
    type = list(string)
}

variable "enable_deletion_protection" {
    type =  bool
    default = false
}

variable "Environment" {
    type = string
}