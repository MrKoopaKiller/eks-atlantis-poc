terraform {
  required_version = "~> 1.4.0"

  # Last providers update: May 10, 2023
  ## Provider configurations in main.tf
  required_providers {
    aws        = "~> 4.66.1"
    helm       = "~> 2.9.0"
    kubernetes = "~> 2.20.0"
  }
}
