provider "aws" {
  region = "ap-southeast-1"
  assume_role {
    role_arn = "arn:aws:iam::345117372609:role/tf-bluegreen"
  }
}