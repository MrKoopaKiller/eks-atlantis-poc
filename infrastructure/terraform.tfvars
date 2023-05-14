# EKS cluster configuration
eks_k8s_version = "1.26"

vpc = {
  cidr = "10.10.0.0/20"
  private_subnets = [
    "10.10.0.0/22",
    "10.10.4.0/22",
  ]
  public_subnets = [
    "10.10.12.0/24",
    "10.10.13.0/24",
  ]
  enable_nat_gateway      = false
  map_public_ip_on_launch = true
}
