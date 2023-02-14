data "aws_ami" "amazon-linux-2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_key_pair" "main-key" {
  include_public_key = true

  filter {
    name   = "tag:Name"
    values = ["main-key"]
  }
}


resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.main-key.key_name

  network_interface {
    network_interface_id = aws_network_interface.primary_network_interface.id
    device_index         = 0
  }

  user_data = <<EOF
		#!/bin/bash
		yum update -y
        yum install git -y

        # install docker
        yum install docker -y
        systemctl enable docker.service
        systemctl start docker.service

        # install docker-compose
        wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
        mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
        chmod -v +x /usr/local/bin/docker-compose
        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

        git clone https://github.com/ducluanxutrieu/docker-compose-setup.git
        cd docker-compose-setup
        docker-compose -f docker-compose-jenkins up -d

		# yum install -y httpd.x86_64
        # yum install ec2-instance-connect
		# systemctl start httpd.service
		# systemctl enable httpd.service
		# echo ?Hello World from $(hostname -f)? > /var/www/html/index.html
	EOF

  tags = {
    Name = "Jenkins Master"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["14.173.102.161/32"]
    # ipv6_cidr_blocks = [aws_vpc.main_vpc.ipv6_cidr_block]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["14.173.102.161/32"]
    # ipv6_cidr_blocks = [aws_vpc.main_vpc.ipv6_cidr_block]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["14.173.102.161/32"]
    # ipv6_cidr_blocks = [aws_vpc.main_vpc.ipv6_cidr_block]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.173.102.161/32"]
    # ipv6_cidr_blocks = [aws_vpc.main_vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = module.aws_vpc.vpc_id

  tags = {
    Name = "main"
  }
}

resource "aws_network_interface" "primary_network_interface" {
  subnet_id       = module.aws_vpc.public_subnet
  private_ips     = ["173.16.12.140"]
  security_groups = [aws_security_group.allow_tls.id]

  tags = {
    Name = "primary_network_interface"
  }
}

module "aws_vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "173.16.12.0/24"
}