terraform {
  required_version = ">= 1.7.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.30"
    }
  }

provider "cloudflare" {
  api_token = var.cloudflare_bootstrap_token
}

provider "cloudflare" {
  api_token = var.cloudflare_bootstrap_token
}
  alias     = "dns"

provider "cloudflare" {
  api_token = var.cloudflare_bootstrap_token
}
  alias     = "waf"
