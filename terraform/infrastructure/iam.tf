# eks-admin
resource "aws_iam_policy" "eks_admin_policy" {
  name        = "eks-admin-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.eks_admin_policy.json
}

resource "aws_iam_role" "eks_admin" {
  name = "eks-admin"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin_policy.arn
}

# eks-readonly
resource "aws_iam_policy" "eks_readonly_policy" {
  name        = "eks-readonly-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.eks_readonly_policy.json
}

resource "aws_iam_role" "eks_readonly" {
  name = "eks-readonly"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_readonly" {
  role       = aws_iam_role.eks_readonly.name
  policy_arn = aws_iam_policy.eks_readonly_policy.arn
}