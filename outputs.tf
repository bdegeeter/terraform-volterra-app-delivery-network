output "app_url" {
  description = "Domain VIP to access the application, running on ADN"
  value       = format("https://%s", var.app_domain)
}

output "adn_app_namespace" {
  value       = var.volterra_namespace
}

output "adn_app_name" {
  value       = format("%s-vk8s", var.adn_name)
}

output "boutique_deployment_manifest" {
  value = local_file.hipster_manifest.filename
}
