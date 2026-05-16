variable "account_id" {
  type        = string
  description = "Cloudflare account ID."
  nullable    = false
}

variable "name" {
  type        = string
  description = "Identity provider name."
  nullable    = false
}

variable "provider_type" {
  type        = string
  description = "Identity provider type: saml or oidc."
  nullable    = false
  default     = "saml"
}

variable "metadata_url" {
  type        = string
  description = "SAML metadata URL (https only)."
  nullable    = false
}

variable "attributes" {
  type        = list(string)
  description = "User attributes."
  nullable    = false
  default     = ["email"]
}

variable "oidc_issuer_url" {
  type        = string
  nullable    = true
  default     = null
  description = "OIDC issuer URL when provider_type=oidc."
}

variable "oidc_client_id" {
  type        = string
  nullable    = true
  default     = null
  description = "OIDC client ID."
}

variable "oidc_client_secret" {
  type        = string
  nullable    = true
  default     = null
  sensitive   = true
  description = "OIDC client secret."
}
