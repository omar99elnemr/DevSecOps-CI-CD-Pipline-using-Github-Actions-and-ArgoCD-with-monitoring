# Core Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "quizapp-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

# EKS Node Group Variables
variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 1 # Reduced for cost savings
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 2 
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.large" # Reliable x86 instance with good compatibility
}

variable "node_disk_size" {
  description = "Disk size for EKS nodes"
  type        = number
  default     = 20
}

# ECR Repository Names
variable "frontend_ecr_name" {
  description = "ECR repository name for frontend"
  type        = string
  default     = "frontend-js"
}

variable "backend_ecr_name" {
  description = "ECR repository name for backend"
  type        = string
  default     = "backend-api"
}

# Application Credentials
variable "grafana_admin_username" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "git_repository_url" {
  description = "Git repository URL for ArgoCD applications"
  type        = string
  default     = "https://github.com/your-username/your-repo"
}

# VPC and Networking
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Only public subnets for cost savings
}

# Tags
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project     = "quizapp"
    Environment = "development"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

variable "project_name" {
  description = "Name of the project for resource grouping and tagging"
  type        = string
  default     = "quizapp"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "development"
}
