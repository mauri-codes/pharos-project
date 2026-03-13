variable "admin_group_name" {
  type        = string
  default     = "administrators"
}

variable "admin_user_name" {
  type        = string
  default     = "admin"
}

variable "bootstrap_pgp_key" {
  description = "Required PGP public key or keybase reference used to encrypt the generated console password and access key secret."
  type        = string
}
