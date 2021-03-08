variable "name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
  default =  null
}