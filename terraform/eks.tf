# EKS configuration for AWS Academy/Learner Lab
# Uses existing LabRole to avoid IAM permission issues

# Use existing LabRole (common in AWS Academy environments)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.lab_role.arn
  version  = "1.28"
  
  vpc_config {
    subnet_ids              = aws_subnet.public[*].id  # Use public subnets only
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

# EKS Node Group (optimized for cost and AWS Academy compatibility)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = aws_subnet.public[*].id  # Use public subnets
  
  scaling_config {
    desired_size = 1  # Start with 1 node for cost savings
    max_size     = 2
    min_size     = 1
  }
  
  instance_types = ["t3.medium"]  # Smaller instance type
  capacity_type  = "ON_DEMAND"    # More reliable in AWS Academy than SPOT
  
  # Node group configuration
  ami_type       = "AL2_x86_64"
  disk_size      = 20  # Minimal disk size for cost savings
  
  # Enable remote access (optional, for troubleshooting)
  # remote_access {
  #   ec2_ssh_key = var.key_pair_name  # Add if you have a key pair
  # }
}

# OIDC Identity Provider (conditional for AWS Academy)
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Only create OIDC provider if variable allows (disabled by default for Academy)
resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.create_oidc_provider ? 1 : 0
  
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  
  tags = {
    Name = "${var.cluster_name}-oidc-provider"
  }
}
