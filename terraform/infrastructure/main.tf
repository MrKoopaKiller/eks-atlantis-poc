/**
 * # eks-atlantis
 *
 * This module creates a VPC, EKS cluster, and deploy atlantis to the cluster.
 */

locals {
  basename   = "${data.aws_default_tags.aws.tags.Project}-${data.aws_default_tags.aws.tags.Environment}"
  account_id = data.aws_caller_identity.current.account_id

  vpc = {
    name = "vpc-${local.basename}"
    azs  = ["eu-central-1a", "eu-central-1b"]
    public_subnet_tags = {
      "subnet-type"                                 = "public"
      "kubernetes.io/role/elb"                      = "1"
      "kubernetes.io/cluster/${local.basename}" = "shared"
    }
    private_subnet_tags = {
      "subnet-type"                                 = "private"
      "kubernetes.io/role/internal-elb"             = "1"
      "kubernetes.io/cluster/${local.basename}" = "shared"
    }
  }
}
