variable "aws_region" {
  default = "eu-west-2"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "public_cidr" {
  type    = list(any)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "db_cidr" {
  default = "10.20.23.0/24"
}
