/*resource "kubernetes_secret" "orders-storage-account-secret" {
  metadata {
    name = "orders-storage-account-secret"
  }

  type = "Opaque"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
}

resource "kubernetes_persistent_volume" "orders-sessions-pv" {
  metadata {
    name = "orders-sessions-pv"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      azure_file {
        //read_only = false
        secret_name = 
        //secret_namespace =
        share_name = azurerm_storage_share.orders-storage-sessions-share.name
      }
    }
  }
}*/

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
          image = "lahouely/orders_webserver:0.1.2"
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
        }
      }
    }
  }
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
}
