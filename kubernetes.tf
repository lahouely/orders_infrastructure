resource "kubernetes_deployment" "orders-webapp-deployment" {
  metadata {
    name = "orders-webapp-deployment"
    labels = {
      app = "webapp"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app  = "webapp"
        type = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "webapp"
          type = "frontend"
        }
      }
      spec {
        container {
          image = "lahouely/orders_webserver:0.1.5"
          name  = "webapp"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          volume_mount {
            mount_path = "/tmp/sessions"
            name       = kubernetes_persistent_volume_claim.orders-nfs-pvc-sessions.metadata.0.name
          }

          volume_mount {
            mount_path = "/var/www/html/cv"
            name       = kubernetes_persistent_volume_claim.orders-nfs-pvc-resumes.metadata.0.name
          }
        }

        volume {
          name = kubernetes_persistent_volume_claim.orders-nfs-pvc-sessions.metadata.0.name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.orders-nfs-pvc-sessions.metadata.0.name
          }
        }

        volume {
          name = kubernetes_persistent_volume_claim.orders-nfs-pvc-resumes.metadata.0.name
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.orders-nfs-pvc-resumes.metadata.0.name
          }
        }
      }
    }
  }
  depends_on = [
    azurerm_kubernetes_cluster.orders-k8s,
    kubernetes_persistent_volume_claim.orders-nfs-pvc-sessions,
    kubernetes_persistent_volume_claim.orders-nfs-pvc-resumes
  ]
}

resource "kubernetes_service" "orders-webapp-service" {
  metadata {
    name = "orders-webapp-service"
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.orders-webapp-deployment.spec.0.template.0.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
  depends_on = [
    azurerm_kubernetes_cluster.orders-k8s,
    kubernetes_deployment.orders-webapp-deployment
  ]
}
