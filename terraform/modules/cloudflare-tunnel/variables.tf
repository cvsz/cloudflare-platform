variable "account_id" {
  type        = string
  description = "Cloudflare account ID"
  nullable    = false

  }
}

variable "name" {
  type        = string
  description = "Tunnel name"
  nullable    = false

}

variable "secret" {
  type        = string
  description = "Base64 tunnel secret passed from runtime secret manager."
  nullable    = false
  sensitive   = true
}

variable "ingress_rules" {
  type = list(object({
    hostname = optional(string)
    service  = string
  }))
  description = "Tunnel ingress rules; include terminal fallback service."
  nullable    = false
  default     = []
}
