variable "account_id" {
  type        = string
  description = "Cloudflare account ID."
  nullable    = false
  }
}

variable "name" {
  type        = string
  description = "Access app name."
  nullable    = false
}

variable "domain" {
  type        = string
  description = "Application domain."
  nullable    = false
}

variable "session_duration" {
  type        = string
  description = "Session duration string (e.g., 4h, 24h)."
  nullable    = false
  default     = "8h"
}

variable "allowed_idps" {
  type        = list(string)
  description = "Allowed IdP IDs."
  nullable    = false
  default     = []
}

