provider "aws" {
  region  = var.region
  default_tags {
    tags = {
      CostCenter  = "DEVOPS"
      Environment = "dev"
      Owner       = "raphael.rabello"
      Project     = "atlantis"
      Terraform   = "true"
    }
  }
}