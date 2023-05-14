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

## VPC variable
variable "vpc" {
  description = "VPC configuration"
  type = object({
    cidr                    = string
    private_subnets         = list(string)
    public_subnets          = list(string)
    enable_nat_gateway      = bool
    map_public_ip_on_launch = bool
  })
}

# ## EKS variables
variable "eks_k8s_version" {
  description = "AWS EKS cluster version"
  type        = string
}
