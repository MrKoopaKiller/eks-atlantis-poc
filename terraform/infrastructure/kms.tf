# Create KMS key and alias to be used to encrypt the secrets for atlantis
resource "aws_kms_key" "this" {}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.basename}-secrets"
  target_key_id = aws_kms_key.this.key_id
}