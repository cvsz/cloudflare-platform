variable "cf_dns_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare DNS Token"
}

variable "cf_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "cf_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}
