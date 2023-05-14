# IRSA for atlantis
# namespace: atlantis, role: atlantis
#
module "irsa_atlantis" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.18.0"
  role_name = "atlantis"
  role_policy_arns = {
    policy = data.aws_iam_policy.admin.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = data.terraform_remote_state.infra.outputs.oidc_provider_arn
      namespace_service_accounts = ["atlantis:atlantis"]
    }
  }
}
