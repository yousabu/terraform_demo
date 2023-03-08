provider "aws" {
    region = "us-east-1"
    access_key = "AKIATMS2FVNAFIXY3MSR"
    secret_key = "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"
} 



variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable "en" {
  
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
      Name: var.cidr_block[0].name

    }
}


resource "aws_subnet" "myapp-subnet1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
     tags = {
      Name: "tera_sub2"
    }

}

