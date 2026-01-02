# General
variable "project" {
  description = "Project tag prefix"
  type        = string
  default     = "k8s-Arsenal"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where instances will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID (public or private with NAT as needed)"
  type        = string
}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
}

# AMI and instance types
variable "ami_id" {
  description = "RHEL 9 AMI ID"
  type        = string
  default     = "ami-0a1b2c3d4e5f67890" # Replace with actual RHEL AMI
}


variable "master_instance_type" {
  description = "Instance type for master"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "Instance type for workers"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

# Security group CIDR allowlists (tighten for production)
variable "ssh_cidr_allowlist" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "k8s_api_cidr_allowlist" {
  description = "CIDR blocks allowed to access K8s API 6443"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nodeport_cidr_allowlist" {
  description = "CIDR blocks allowed for NodePort range"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
