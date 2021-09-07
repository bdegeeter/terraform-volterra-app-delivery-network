terraform {
  required_version = ">= 0.13.1"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.10.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.3.0"
    }
    local = ">= 2.0"
    null  = ">= 3.0"
  }
}
