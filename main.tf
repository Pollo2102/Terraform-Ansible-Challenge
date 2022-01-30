terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "ec2_instance" {

    ami = "ami-08d70e59c07c61a3a"  
    instance_type = "t2.micro" 
    key_name = aws_key_pair.key_pair.key_name
    subnet_id = aws_subnet.publicsubnets.id
    vpc_security_group_ids = [aws_security_group.main.id]

    associate_public_ip_address = true

  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("${aws_key_pair.key_pair.key_name}.pem")
      timeout     = "4m"
   }
}

resource "aws_instance" "ec2_instance2" {

    ami = "ami-08d70e59c07c61a3a"  
    instance_type = "t2.micro" 
    key_name = aws_key_pair.key_pair.key_name
    subnet_id = aws_subnet.publicsubnets2.id
    vpc_security_group_ids = [aws_security_group.main.id]

    associate_public_ip_address = true

  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("${aws_key_pair.key_pair.key_name}.pem")
      timeout     = "4m"
   }
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.vpc1.id
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      from_port        = 0
      protocol         = "-1"
      self             = false
      to_port          = 0
    }
  ]
 ingress = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     security_groups  = []
     from_port        = 22
     protocol         = "tcp"
     self             = false
     to_port          = 22
   }
  ]
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  filename          = "ssh-key.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ssh-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_vpc" "vpc1" {                # Creating VPC here
   cidr_block       = var.vpc1_cidr
   instance_tenancy = "default"
 }

resource "aws_internet_gateway" "IGW" {
    vpc_id =  aws_vpc.vpc1.id
}

resource "aws_subnet" "publicsubnets" {
  availability_zone = "us-west-2a"
  vpc_id =  aws_vpc.vpc1.id
  cidr_block = "${var.public_subnets}"
}

resource "aws_subnet" "publicsubnets2" {
  availability_zone = "us-west-2b"
  vpc_id =  aws_vpc.vpc1.id
  cidr_block = "${var.public_subnets2}"
}

resource "aws_subnet" "privatesubnets" {
  availability_zone = "us-west-2a"
  vpc_id =  aws_vpc.vpc1.id
  cidr_block = "${var.private_subnets}"
}

resource "aws_route_table" "PuRT" {
    vpc_id =  aws_vpc.vpc1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }   
}

resource "aws_route_table" "PrRT" {
   vpc_id = aws_vpc.vpc1.id
   route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.NATgw.id
   }   
}

resource "aws_route_table_association" "PuRTAssoc" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PuRT.id
}

resource "aws_route_table_association" "PuRT2Assoc" {
    subnet_id = aws_subnet.publicsubnets2.id
    route_table_id = aws_route_table.PuRT.id
}

resource "aws_route_table_association" "PrRTAssoc" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrRT.id
}

resource "aws_eip" "nateIP" {
   vpc   = true
}

resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
}