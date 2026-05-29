terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
variable "cloudflare_api_token" { type = string }
variable "zone_id" { type = string }
variable "account_id" { type = string }
variable "tunnel_cname" { type = string }
