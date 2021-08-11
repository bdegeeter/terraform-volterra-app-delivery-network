resource "volterra_origin_pool" "this" {
  name                   = format("%s-server", var.adn_name)
  namespace              = local.namespace
  description            = format("Origin pool pointing to frontend k8s service running on RE's")
  loadbalancer_algorithm = "ROUND ROBIN"
  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = format("frontend.%s", local.namespace)
      site_locator {
        virtual_site {
          name      = "ves-io-all-res"
          namespace = "shared"
          tenant    = "ves-io"
        }
      }
    }
  }
  port               = 80
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
  depends_on = [time_sleep.waiting]
}

resource "volterra_waf" "this" {
  name        = format("%s-waf", var.adn_name)
  description = format("WAF in block mode for %s", var.adn_name)
  namespace   = local.namespace
  app_profile {
    cms       = []
    language  = []
    webserver = []
  }
  mode = "BLOCK"
  lifecycle {
    ignore_changes = [
      app_profile
    ]
  }
  depends_on = [time_sleep.waiting]
}

resource "volterra_http_loadbalancer" "this" {
  name                            = format("%s-lb", var.adn_name)
  namespace                       = local.namespace
  description                     = format("HTTPS loadbalancer object for %s origin server", var.adn_name)
  domains                         = [var.app_domain]
  advertise_on_public_default_vip = true
  default_route_pools {
    pool {
      name      = volterra_origin_pool.this.name
      namespace = local.namespace
    }
  }
  https_auto_cert {
    add_hsts      = var.enable_hsts
    http_redirect = var.enable_redirect
    no_mtls       = true
  }
  waf {
    name      = volterra_waf.this.name
    namespace = local.namespace
  }
  disable_waf                     = false
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = var.disable_js_challenge
  dynamic "js_challenge" {
    for_each = local.js_delay_list
    content {
      js_script_delay = js_challenge.value["js_script_delay"]
      cookie_expiry   = js_challenge.value["cookie_expiry"]
    }
  }
  depends_on = [time_sleep.waiting]
}
