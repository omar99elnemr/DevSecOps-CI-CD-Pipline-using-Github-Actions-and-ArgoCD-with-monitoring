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

variable "argocd_admin_password" {
  description = "ArgoCD admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

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

variable "create_oidc_provider" {
  description = "Whether to create OIDC provider (disable for AWS Academy)"
  type        = bool
  default     = false
}
