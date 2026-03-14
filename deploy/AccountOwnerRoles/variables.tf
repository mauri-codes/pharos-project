variable "trusted_account_id" {
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.trusted_account_id))
    error_message = "trusted_account_id must be a 12-digit AWS account ID."
  }
}

variable "role_name" {
  type        = string
  default     = "PharosOrganizationManager"
}

variable "role_path" {
  type        = string
  default     = "/pharos/"
}

variable "role_description" {
  type        = string
  default     = "Role for AWS Organizations management from pharos."
}

variable "policy_name" {
  type        = string
  default     = "PharosOrganizationManagerPolicy"
}

variable "policy_path" {
  type        = string
  default     = "/pharos/"
}

variable "policy_description" {
  type        = string
  default     = "Permissions for AWS Organizations and StackSets administration."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the created IAM resources."
  default     = {
    Project     = "Pharos"
    Module      = "Bootstrap"
    CreatedBy   = "TerraformScript"
  }
}
