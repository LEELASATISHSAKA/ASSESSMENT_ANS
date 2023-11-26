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
  access_key = "AKIAW4R3L46LJD57VLQN"
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
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.asgvpc.cidr_block]
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
  }
}



# Create AWS nginxkey

resource "aws_key_pair" "ASGkey" {
  key_name   = "ASGkey"
  public_key = file("ASGkey.pem.pub") # Path to the public key file
}

# Create AWS Instance
resource "aws_instance" "ASGnginx" {
  ami           = "ami-02a2af70a66af6dfb"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ASGkey.key_name  # Reference the key pair created
  subnet_id     = aws_subnet.asgpublicsubnet.id # Place the instance in one of the subnets
  associate_public_ip_address = true  # Add this line to assign a public IP to the instance
  tags = {
    Name = "ASGnginx_ins"
  }

  user_data = <<-EOF
    #! /bin/sh
    yum update -y
    yum install docker -y
    service docker start
    docker pull nginx:alpine
    docker run -it -d --name nginxcont -p 80:80 nginx:alpine
 EOF
}

output "public_ip" {
  value = aws_instance.ASGnginx.public_ip
}


