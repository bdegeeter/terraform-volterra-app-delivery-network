variable "api_url" {
  #--- UNCOMMENT FOR TEAM OR ORG TENANTS
  # default = "https://<TENANT-NAME>.console.ves.volterra.io/api"
  #--- UNCOMMENT FOR INDIVIDUAL/FREEMIUM
  # default = "https://console.ves.volterra.io/api"
}

# This points the absolute path of the api credentials file you downloaded from Volterra
variable "api_p12_file" {
  default = "path/to/your/api-creds.p12"
}

variable "app_fqdn" {}

variable "namespace" {
  default = ""
}

variable "disable_js_challenge" {
  default = false
}

variable "name" {}

locals {
  namespace = var.namespace != "" ? var.namespace : var.name
}

resource "random_string" "sub_suffix" {
  length  = 5
  upper   = false
  number  = false
  lower   = true
  special = false
}

terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.10.0"
    }
  }
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_url
}

module "app-delivery-network" {
  source               = "../../"
  adn_name             = "${random_string.sub_suffix.id}-${var.name}"
  volterra_namespace   = "${random_string.sub_suffix.id}-${local.namespace}"
  app_domain           = "${random_string.sub_suffix.id}-${var.app_fqdn}"
  disable_js_challenge = var.disable_js_challenge
}
output "adn_app_namespace" {
  value = module.app-delivery-network.adn_app_namespace
}
output "adn_app_name" {
  value = module.app-delivery-network.adn_app_name
}
output "adn_app_url" {
  value = module.app-delivery-network.app_url
}
output "deployment_manifest" {
  value = module.app-delivery-network.boutique_deployment_manifest
}