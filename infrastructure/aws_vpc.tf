module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name                    = local.basename
  cidr                    = var.vpc["cidr"]
  azs                     = local.vpc["azs"]
  private_subnets         = var.vpc["private_subnets"]
  public_subnets          = var.vpc["public_subnets"]
  enable_nat_gateway      = var.vpc["enable_nat_gateway"]
  public_subnet_tags      = local.vpc.public_subnet_tags
  private_subnet_tags     = local.vpc.private_subnet_tags
  map_public_ip_on_launch = var.vpc["map_public_ip_on_launch"]
}
