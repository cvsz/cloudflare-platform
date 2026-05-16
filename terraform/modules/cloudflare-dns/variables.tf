variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID"
  nullable    = false

  }
}

variable "records" {
  type = map(object({
    name            = string
    type            = string
    value           = string
    ttl             = number
    proxied         = bool
    target_from     = optional(string)
    origin_host_key = optional(string)
    comment         = optional(string)
    priority        = optional(number)
  }))
  description = "DNS records keyed by unique logical ID."
  nullable    = false

}

variable "origin_hosts" {
  type        = map(string)
  description = "Optional map of origin host key to IP/FQDN. Required when using A/AAAA from ORIGIN_HOSTS."
  nullable    = false
  default     = {}
}
