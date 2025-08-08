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
  
  timeout = 900
  wait    = true
  
  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
        extraArgs = ["--insecure"]
      }
      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt(var.argocd_admin_password)
        }
      }
    })
  ]
  
  depends_on = [
    kubernetes_namespace.argocd,
    aws_eks_node_group.main,
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
  
  timeout = 1200
  wait    = true
  
  values = [
    yamlencode({
      prometheus = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
        prometheusSpec = {
          retention = "2d"
          storageSpec = {}  # No persistent storage - ephemeral only
        }
      }
      grafana = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
        adminUser = var.grafana_admin_username
        adminPassword = var.grafana_admin_password
        persistence = {
          enabled = false  # No storage needed for short-term use
        }
      }
      alertmanager = {
        service = {
          type = "ClusterIP"
        }
        alertmanagerSpec = {
          storage = {}  # No persistent storage
        }
      }
    })
  ]
  
  depends_on = [
    kubernetes_namespace.monitoring,
    aws_eks_node_group.main,
    helm_release.aws_load_balancer_controller
  ]
}
