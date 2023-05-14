data "aws_default_tags" "aws" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = [
      local.basename
    ]
  }
  depends_on = [module.vpc]
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:subnet-type"
    values = ["private"]
  }
  depends_on = [module.vpc]
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:subnet-type"
    values = ["public"]
  }
  depends_on = [module.vpc]
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "eks_readonly_policy" {
  statement {
    actions = [
      "eks:ListFargateProfiles",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:DescribeFargateProfile",
      "eks:ListTagsForResource",
      "eks:ListUpdates",
      "eks:DescribeUpdate",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:AccessKubernetesApi",
      "eks:GetParameter"
    ]
    resources = ["*"]
  }
}
data "aws_iam_policy_document" "eks_admin_policy" {
  statement {
    actions = [
      "eks:*",
    ]
    resources = ["*"]
  }
}
