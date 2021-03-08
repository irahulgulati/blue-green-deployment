variable "name" {
    type = string
}

variable "ami" {
    type = string
}

variable "shutdown_behavior" {
    type = string
}

variable "instance_type"{
    type = string
}

variable "key_name" {
    type = string
}

variable "security_groups_id" {
    type = list(string)
}

variable "user_data" {
    default = null
}
