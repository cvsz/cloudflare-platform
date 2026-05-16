variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID"
  nullable    = false

  }
}

variable "managed_waf_packages" {
  type        = set(string)
  description = "Managed WAF package IDs"
  nullable    = false
  default     = ["efb7b8c949ac4650a09736fc376e9aee"]
}

variable "redirect_host" {
  type        = string
  description = "Primary hostname for canonical redirect target"
  nullable    = false

}

variable "enable_zone_settings_override" {
  type        = bool
  description = "Whether to manage zone settings override (requires Zone Settings Write permission)."
  nullable    = false
  default     = false
}

