variable "aws_region" {
  description = "AWS region where resources will be created"
  type = string
  default = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type = string
  default = "e-commerce-app"
}

variable "environment" {
  description = "deployment environment"
  type = string
  default = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "availability Zones to use for the VPC"
  type = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "admin_cidr" {
  description = "CIDR block allowed for SSH administrative access"
  type = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "ami_id" {
  description = "AMI ID for Jenkins EC2"
  type = string
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type = string
  default = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type = number
  default = 30
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type = string
  default = "e-commerce-app"
}

variable "migration_ecr_repository_name" {
  description = "migration_ecr_repository_name"
  type    = string
  default = "e-commerce-migration"
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform remote state"
  type = string
  default = "e-commerce-app-terraform-state-07-09-2026"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type = string
  default = "e-commerce-eks"
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version for EKS"
  type = string
  default = "1.33"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type = string
  default = "t3.medium"
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type = number
  default = 2
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type = number
  default = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type = number
  default = 3
}
