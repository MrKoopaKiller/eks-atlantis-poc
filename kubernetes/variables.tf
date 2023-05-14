## Global variables
variable "profile" {
  description = "AWS profile name"
  type        = string
  default     = "default"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "atlantis_encrypted_secrets" {
  description = "Atlantis encrypted secrets"
  type        = string
}
