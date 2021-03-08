resource "aws_route_table" "tf_practice_public_rt" {
    vpc_id = var.vpc_id
    route = var.route

    tags = {
        "Name" = var.name
    }
}