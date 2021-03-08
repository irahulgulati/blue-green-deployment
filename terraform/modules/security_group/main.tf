resource "aws_security_group" "tf_practice_instance_sg_1" {
    name = var.name
    vpc_id = var.vpc_id
    ingress = var.ingress_routes
    egress = var.egress_routes
    tags = {
        "Name" = var.name
    }
}