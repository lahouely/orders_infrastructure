resource "local_file" "tf_vars_for_ansible" {
  filename = "../../tf_ansible_vars_file.yml"
  content  = <<-DOC
    tf_domain_name_label: ${var.domain_name_label}
    tf_location: ${var.location}
    tf_email: ${var.cloudflare_email}
    tf_orders_webapp_service_lb_ip: ${kubernetes_service.orders-webapp-service.status.0.load_balancer.0.ingress.0.ip}
    DOC
}