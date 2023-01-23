resource "kubernetes_deployment" "orders-webapp-deployment" {
  metadata {
    name = "orders-webapp-deployment"
    labels = {
      app = "webapp"
    }
  }

  spec {
    replicas = 2
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
          image = "lahouely/orders_webserver:latest"
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
      service.beta.kubernetes.io / azure-load-balancer-internal = "true"
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
