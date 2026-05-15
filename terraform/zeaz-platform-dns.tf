# Zeaz application DNS records.
# These records point public hostnames to the active Cloudflare Tunnel.
#
# Required variables are intentionally generic so this file can be used from
# the root module or copied into an environment root.

variable "cf_zone_id" {
  description = "Cloudflare zone ID for zeaz.dev."
  type        = string
}

variable "zeaz_tunnel_cname_target" {
  description = "Cloudflare Tunnel CNAME target, for example <tunnel-id>.cfargotunnel.com."
  type        = string
}

locals {
  zeaz_platform_dns_records = {
    "zveo" = {
      name    = "zveo"
      comment = "ZVEO dashboard"
    }
    "api-zveo" = {
      name    = "api.zveo"
      comment = "ZVEO API gateway"
    }
    "app" = {
      name    = "app"
      comment = "zWallet frontend"
    }
    "admin-wallet" = {
      name    = "admin-wallet"
      comment = "zWallet admin API"
    }
  }
}

resource "cloudflare_record" "zeaz_platform_apps" {
  for_each = local.zeaz_platform_dns_records

  zone_id = var.cf_zone_id
  name    = each.value.name
  type    = "CNAME"
  value   = var.zeaz_tunnel_cname_target
  proxied = true
  comment = each.value.comment
}
