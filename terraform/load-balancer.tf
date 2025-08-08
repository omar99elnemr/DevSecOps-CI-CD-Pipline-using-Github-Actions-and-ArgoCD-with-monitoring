# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Use existing LabRole instead of creating new IAM role
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Use existing IAM policy instead of creating new one
data "aws_iam_policy" "aws_load_balancer_controller" {
  name = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
}
# Install AWS Load Balancer Controller via Helm using existing LabRole
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2"
  
  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.lab_role.arn
  }
  
  set {
    name  = "region"
    value = var.aws_region
  }
  
  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }
  
  # Disable cert manager webhook (not needed for basic functionality)
  set {
    name  = "enableCertManager"
    value = "false"
  }
  
  depends_on = [
    aws_eks_node_group.main
  ]
}

# Output Load Balancer Controller information
output "load_balancer_controller_info" {
  description = "AWS Load Balancer Controller deployment information"
  value = {
    status = "Deployed using existing LabRole and existing policy"
    service_account = "aws-load-balancer-controller"
    role_arn = data.aws_iam_role.lab_role.arn
    policy_arn = data.aws_iam_policy.aws_load_balancer_controller.arn
    namespace = "kube-system"
    note = "ALB and NLB ingress resources can now be created"
  }
}
