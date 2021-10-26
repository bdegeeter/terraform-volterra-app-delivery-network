data "volterra_namespace" "this" {
  count = var.volterra_namespace_exists ? 1 : 0
  name  = var.volterra_namespace
}

resource "volterra_namespace" "this" {
  count = var.volterra_namespace_exists ? 0 : 1
  name  = var.volterra_namespace
}

resource "time_sleep" "waiting" {
  depends_on = [volterra_namespace.this]

  create_duration = "10s"
}

resource "volterra_virtual_k8s" "this" {
  name      = format("%s-vk8s", var.adn_name)
  namespace = local.namespace

  vsite_refs {
    name      = "ves-io-all-res"
    namespace = "shared"
    tenant    = "ves-io"
  }

  provisioner "local-exec" {
    command = "sleep 100s"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 20s"
  }
  depends_on = [time_sleep.waiting]
}

resource "local_file" "hipster_manifest" {
  content  = local.hipster_manifest_content
  filename = format("%s/_output/hipster-adn.yaml", path.root)
}
