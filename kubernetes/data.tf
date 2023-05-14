
# Local terraform infrastrucutrure state
data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../infrastructure/terraform.tfstate"
  }
}

data "aws_default_tags" "aws" {}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.infra.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.infra.outputs.cluster_id
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy" "admin" {
  name = "AdministratorAccess" # Don't do this in production :)
}

data "aws_kms_secrets" "this" {
  secret {
    name    = "atlantis"
    payload = var.atlantis_encrypted_secrets
  }
}
