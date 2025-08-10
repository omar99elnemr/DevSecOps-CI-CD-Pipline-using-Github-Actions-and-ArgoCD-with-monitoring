# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [aws_eks_node_group.main]
}

# Monitoring Namespace  
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
  depends_on = [aws_eks_node_group.main]
}

# ArgoCD Installation
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.46.8"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "classic"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password
  }

  depends_on = [
    aws_eks_node_group.main,
    kubernetes_namespace.argocd,
    helm_release.aws_load_balancer_controller
  ]
}

# Prometheus and Grafana Installation
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "55.5.0"

  set {
    name  = "prometheus.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "prometheus.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "prometheus.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "classic"
  }

  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "grafana.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "grafana.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "classic"
  }

  set {
    name  = "grafana.adminUser"
    value = var.grafana_admin_username
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  # Disable AlertManager to save costs
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    aws_eks_node_group.main,
    helm_release.aws_load_balancer_controller
  ]
}
