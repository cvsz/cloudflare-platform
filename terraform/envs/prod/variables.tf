variable "cloudflare_bootstrap_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
  nullable    = false

}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account"
  nullable    = false

  }
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone"
  nullable    = false

  }
}

variable "plan_tier" {
  type        = string
  description = "Free|Pro|Business|Enterprise"
  default     = "Free"
  nullable    = false

}
