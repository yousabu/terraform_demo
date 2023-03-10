provider "aws" {
    region = "us-east-1"
  
} 



variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}


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


resource "aws_default_security_group" "default-sg" {

    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
    }
  tags = {
    "Name" = "${var.env_prefix}-default-sg"
  }

}

# EC2 Instance

# Get The Latest Amazon AMI
data "aws_ami" "latest-amazon-linx-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = [ "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2" ]
    }
    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
}


output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linx-image
}




# resource "aws_key_pair" "ssh-key" {
#   key_name = "myapp-key"
#   public_key = "${file("location of the file")}"
# }


resource "aws_instance" "my-app-server" {
    ami = data.aws_ami.latest-amazon-linx-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address =  true

    key_name = "aws_admin_key" # Ref the key name

    # user_data = file("entry-script.sh")

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file("/home/youssef/Downloads/aws_admin_key.pem")
    }

    # provisioner "file" {
    #   source = "entry-script.sh"
    #   destination = "/home/ec2-user/entry-on-script.sh"
    # }

    # provisioner "remote-exec" {
    #   inline = [
    #     file("entry-on-script.sh")
    #   ]
    # }

    # provisioner "local-exec" {
    #   command = "echo ${self.public_ip} > output.txt"
    # }
                  
    tags = {
      "Name" = "${var.env_prefix}-server"
    }

}



output "ec2_public_ip" {
    value = aws_instance.my-app-server.public_ip
}