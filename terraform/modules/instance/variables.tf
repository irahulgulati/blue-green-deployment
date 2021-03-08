variable "instance_type" {
    type = string
}
variable "ami_id"{
    type = string
}

variable "associate_public_ip" {
    type = string
}

variable "tf_instance_ip_address"{
    type = string
}

variable "security_groups"{
    type = list(string)
}

variable "subnet_id" {
    type = string
}

variable "key_name" {
    type = string
}