output "cluster_id" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "kms_key_id" {
  value = aws_kms_key.this.key_id
}

output "eks-readonly-role-arn" {
  value = aws_iam_role.eks_readonly.arn
}

output "eks-admin-role-arn" {
  value = aws_iam_role.eks_admin.arn
}