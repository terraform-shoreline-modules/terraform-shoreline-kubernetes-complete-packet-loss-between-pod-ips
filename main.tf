terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "complete_packet_loss_between_pod_ips" {
  source    = "./modules/complete_packet_loss_between_pod_ips"

  providers = {
    shoreline = shoreline
  }
}