terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Security group (basic SSH + Kubernetes)
resource "aws_security_group" "k8s_sg" {
  name        = "${var.project}-k8s-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_allowlist
  }

  # API server (optional external access; tighten for production)
  ingress {
    description = "K8s API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.k8s_api_cidr_allowlist
  }

  # Node ports (optional; adapt to your CNI and exposure strategy)
  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = var.nodeport_cidr_allowlist
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
  }
}

# Master node
resource "aws_instance" "master" {
  ami                         = var.ami_id
  instance_type               = var.master_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project}-master"
    Project = var.project
    Role    = "Master"
  }

  user_data = file("${path.module}/cloud-init-master.sh")
}

# Worker nodes
resource "aws_instance" "workers" {
  count                       = var.worker_count
  ami                         = var.ami_id
  instance_type               = var.worker_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project}-worker-${count.index + 1}"
    Project = var.project
    Role    = "Worker"
  }

  user_data = file("${path.module}/cloud-init-worker.sh")
}
