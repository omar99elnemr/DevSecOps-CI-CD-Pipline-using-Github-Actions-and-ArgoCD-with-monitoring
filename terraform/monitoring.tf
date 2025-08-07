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
        extraArgs = [
          "--insecure"
        ]
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
    helm_release.aws_load_balancer_controller
  ]
}

# Prometheus and Grafana Installation
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
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
          retention = "7d"  # Reduce retention for cost savings
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"  # Reduced storage size
                  }
                }
              }
            }
          }
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
          enabled = true
          storageClassName = "gp2"
          size = "3Gi"  # Reduced Grafana storage
        }
      }
      alertmanager = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
  
  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.aws_load_balancer_controller
  ]
}
