terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region = var.region
}

# Latest Ubuntu 22.04 LTS (Jammy) AMD64
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "tailnet" {
  name        = "${var.name}-sg"
  description = "Allow SSH and optional web ingress for Tailscale Funnel"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  dynamic "ingress" {
    for_each = var.enable_web_ingress ? [1] : []
    content {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.enable_web_ingress ? [1] : []
    content {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

# Optional key pair if you want AWS SSH in addition to Tailscale SSH
resource "aws_key_pair" "this" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "${var.name}-key"
  public_key = var.public_key
}

locals {
  user_data = templatefile("${path.module}/user_data.tmpl", {
    HOSTNAME             = var.name
    TAILSCALE_AUTH_KEY   = var.tailscale_auth_key
    ADVERTISE_EXIT_NODE  = var.advertise_exit_node ? "--advertise-exit-node" : ""
    ADVERTISE_ROUTES     = var.advertise_routes != "" ? "--advertise-routes=${var.advertise_routes}" : ""
  })
}

resource "aws_instance" "tailnet" {
  ami                         = data.aws_ami.ubuntu_jammy.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.tailnet.id]
  key_name                    = var.public_key != "" ? aws_key_pair.this[0].key_name : null
  user_data                   = local.user_data
  source_dest_check           = false  # required for routing/exit-node NAT

  tags = {
    Name = var.name
  }
}

# Elastic IP for a stable public IP (useful when acting as an exit node)
resource "aws_eip" "this" {
  domain   = "vpc"
  instance = aws_instance.tailnet.id

  tags = {
    Name = "${var.name}-eip"
  }
}

output "instance_id" {
  value = aws_instance.tailnet.id
}

output "public_ip" {
  value = aws_eip.this.public_ip
}

output "public_dns" {
  value = aws_instance.tailnet.public_dns
}

output "private_ip" {
  value = aws_instance.tailnet.private_ip
}
