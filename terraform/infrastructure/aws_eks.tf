module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = local.basename
  cluster_version = var.eks_k8s_version

  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.public.ids

  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    spot = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      username = "eks-admin"
      rolearn  = aws_iam_role.eks_admin.arn
      groups = [
        "system:masters"
      ]
    },
    {
      username = "eks-readonly"
      rolearn  = aws_iam_role.eks_readonly.arn
      groups = [
        "system:readonly"
      ]
    },
  ]
}