terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAW4R3L46LM7EQF4U3"
  secret_key = "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"
}


resource "aws_vpc" "asgvpc" {
  cidr_block       = "99.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "asgvpc"
  }
}

resource "aws_subnet" "asgpublicsubnet" {
  vpc_id     = aws_vpc.asgvpc.id
  cidr_block = "99.0.0.0/24"

  tags = {
    Name = "asgpublic_subnet"
  }
}

resource "aws_internet_gateway" "asgigw" {
  vpc_id = aws_vpc.asgvpc.id

  tags = {
    Name = "asgigw"
  }
}

resource "aws_route_table" "asgrta" {
  vpc_id = aws_vpc.asgvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asgigw.id
  }
}

resource "aws_security_group" "asgsg" {
  name        = "asgsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.asgvpc.id

 ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "asgsg"
