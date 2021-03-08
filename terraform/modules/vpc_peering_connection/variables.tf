variable "name" {
    type = string
}

variable "peer_owner_id" {
    type = string
}

variable "other_vpc_id" {
    type = string
}

variable "own_vpc_id" {
    type = string
}

variable "peer_region" {
    type =  string
    default =  "us-east-1"
}

variable "auto_accept" {
    type = bool
    default = false
}

variable "allow_accepter_dns"{
    type = bool
    default = false
}

variable "allow_requester_dns" {
    type = bool
    default =  false
}