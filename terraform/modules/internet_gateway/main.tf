resource "aws_internet_gateway" "tf_practice_ig" {
    vpc_id = var.vpc_id

    tags = {
        Name = var.name
    }
}