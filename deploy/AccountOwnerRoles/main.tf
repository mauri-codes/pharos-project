data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowTrustedAccountAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.trusted_account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "account_owner" {
  statement {
    sid    = "OrganizationsRead"
    effect = "Allow"

    actions = [
      "organizations:DescribeOrganization",
      "organizations:DescribeAccount",
      "organizations:DescribeCreateAccountStatus",
      "organizations:DescribeOrganizationalUnit",
      "organizations:ListAccounts",
      "organizations:ListAccountsForParent",
      "organizations:ListChildren",
      "organizations:ListParents",
      "organizations:ListRoots",
      "organizations:ListTagsForResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "OrganizationsManageOuAndAccounts"
    effect = "Allow"

    actions = [
      "organizations:CreateOrganizationalUnit",
      "organizations:UpdateOrganizationalUnit",
      "organizations:DeleteOrganizationalUnit",
      "organizations:CreateAccount",
      "organizations:MoveAccount",
      "organizations:TagResource",
      "organizations:UntagResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "OrganizationsOptionalAccountClosure"
    effect = "Allow"

    actions   = ["organizations:CloseAccount"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudFormationStackSetReadWrite"
    effect = "Allow"

    actions = [
      "cloudformation:CreateStackSet",
      "cloudformation:UpdateStackSet",
      "cloudformation:DeleteStackSet",
      "cloudformation:DescribeStackSet",
      "cloudformation:ListStackSets",
      "cloudformation:CreateStackInstances",
      "cloudformation:DeleteStackInstances",
      "cloudformation:UpdateStackInstances",
      "cloudformation:DescribeStackInstance",
      "cloudformation:ListStackInstances",
      "cloudformation:ListStackSetOperations",
      "cloudformation:DescribeStackSetOperation",
      "cloudformation:StopStackSetOperation",
      "cloudformation:DetectStackSetDrift",
      "cloudformation:DetectStackResourceDrift",
      "cloudformation:ListStackSetAutoDeploymentTargets",
      "cloudformation:ListStackInstanceResourceDrifts",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudFormationOrgTrustedAccess"
    effect = "Allow"

    actions = [
      "cloudformation:ActivateOrganizationsAccess",
      "cloudformation:DeactivateOrganizationsAccess",
      "cloudformation:DescribeOrganizationsAccess",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "OrganizationsTrustedAccessForStackSets"
    effect = "Allow"

    actions = [
      "organizations:EnableAWSServiceAccess",
      "organizations:DisableAWSServiceAccess",
      "organizations:ListAWSServiceAccessForOrganization",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "organizations:ServicePrincipal"
      values   = ["member.org.stacksets.cloudformation.amazonaws.com"]
    }
  }

  statement {
    sid    = "ServiceLinkedRoleForStackSets"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetRole",
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values = [
        "member.org.stacksets.cloudformation.amazonaws.com",
        "stacksets.cloudformation.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "account_owner" {
  name               = var.role_name
  path               = var.role_path
  description        = var.role_description
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_policy" "account_owner" {
  name        = var.policy_name
  path        = var.policy_path
  description = var.policy_description
  policy      = data.aws_iam_policy_document.account_owner.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "account_owner" {
  role       = aws_iam_role.account_owner.name
  policy_arn = aws_iam_policy.account_owner.arn
}
