provider "aws" {
    region = "us-east-1"
    access_key = "AKIATMS2FVNAKM4MIY6P"
    secret_key = "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"
} 

variable "subnet_cider_data" {
    type = string
    default = "0.0.0.0/0"
}

resource "aws_vpc" "develpment-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name: "Terraform-VPC"

    }
}

resource "aws_subnet" "dev-sub-1" {
    vpc_id = aws_vpc.develpment-vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name: "tera_sub1"
    }

}

data "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "dev-sub-2" {
    vpc_id = aws_vpc.develpment-vpc.id
    cidr_block = var.subnet_cider_data
    availability_zone = "us-east-1a"
     tags = {
      Name: "tera_sub2"
    }

}

output "vpc-id" {
    value = aws_vpc.develpment-vpc.id
}