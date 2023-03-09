provider "aws" {
    region = "us-east-1"

} 



variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable env_prefix {}


resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = { 
      Name: "${var.env_prefix}-vpc"

    }
}


resource "aws_subnet" "myapp-subnet1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
     tags = {
      Name: "${var.env_prefix}-subnet-1"
    }

}



resource "aws_internet_gateway" "myapp_igw" {
    vpc_id = aws_vpc.myapp-vpc.id
      tags = {
    "Name" = "${var.env_prefix}-rtb"
  }
}

###### To Create New One #######
# resource "aws_route_table" "myapp-route-table" {
#     vpc_id = aws_vpc.myapp-vpc.id

#     route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp_igw.id
#     }
#     tags = {
#       "Name" = "${var.env_prefix}-rtb"
#     }
# }

# resource "aws_route_table_association" "a-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet1.id
#     route_table_id = aws_route_table.myapp-route-table.id
  
# }

resource "aws_default_route_table" "main_route_table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
    }
    tags = {
      "Name" = "${var.env_prefix}-main-rtb"
  }
}


resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.my_ip]
    }
}