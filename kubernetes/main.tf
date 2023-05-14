locals {
  basename         = "${data.aws_default_tags.aws.tags.Project}-${data.aws_default_tags.aws.tags.Environment}"
  atlantis_secrets = jsondecode(data.aws_kms_secrets.this.plaintext["atlantis"])
}

resource "helm_release" "atlantis" {
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"

  namespace        = "atlantis"
  create_namespace = true
  values = [templatefile(
    "${path.module}/templates/atlantis_values.yaml.tpl",
    {
      gh_user                       = local.atlantis_secrets.gh_user,
      gh_token                      = local.atlantis_secrets.gh_token,
      gh_webhook_secret             = local.atlantis_secrets.gh_webhook_secret,
      org_allowlist                 = local.atlantis_secrets.org_allowlist,
      atlantis_service_account_name = module.irsa_atlantis.iam_role_name,
      atlantis_irsa_role_arn        = module.irsa_atlantis.iam_role_arn,
      atlantis_basic_auth_password  = local.atlantis_secrets.atlantis_basic_auth_password
    }
  )]
}
# Install the EBS CSI driver.
module "ebs-csi-driver" {
  source   = "DrFaust92/ebs-csi-driver/kubernetes"
  version  = "3.7.0"
  oidc_url = "https://${data.terraform_remote_state.infra.outputs.oidc_provider_url}"
}
# Install the AWS Loadbalancer controller.
module "lb-controller" {
  source            = "SPHTech-Platform/lb-controller/aws"
  version           = "0.5.1"
  cluster_name      = data.terraform_remote_state.infra.outputs.cluster_id
  oidc_provider_arn = data.terraform_remote_state.infra.outputs.oidc_provider_arn
}
