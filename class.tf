#Terraform setup
terraform {
  required_providers {
     aws = {
      source  = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
  access_key = "AKIAXYXPM6SLM3SEEVNM"
  secret_key = "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"
}



# 1. Create VPC
resource "aws_vpc" "juicy_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "juicy_vpc"
  }
}

# 2. Create a private subnet

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.juicy_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet"
  }
}
# 3. Create an s3 bucket
resource "aws_s3_bucket" "b" {
  bucket = "my-juicy-terraform-bucket39"
  acl    = "private"

  tags = {
    Name        = "my-juicy-terraform-bucket39"
    Environment = "Dev"
  }
}

# 4. Create an EC2 and install docker (use the user_data)

resource "aws_instance" "jaye_instance" {
  ami           = "ami-01aab85a5e4a5a0fe" # us-east-2
  instance_type = "t2.micro"
  availability_zone = "us-east-2a"
  subnet_id = aws_subnet.main.id

  user_data = <<-EOF
		#!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo yum install docker git python3 -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    EOF

  tags = { 
    Name = "jaye_terraform_ec2"
}  

}


