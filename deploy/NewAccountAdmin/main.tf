terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

resource "aws_iam_group" "admin" {
  name = var.admin_group_name
}

resource "aws_iam_group_policy_attachment" "administrator_access" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "admin" {
  name          = var.admin_user_name
  force_destroy = true

  tags = {
    ManagedBy = "Terraform"
    Project   = "NewAccountAdmin"
  }
}

resource "aws_iam_user_group_membership" "admin" {
  user   = aws_iam_user.admin.name
  groups = [aws_iam_group.admin.name]
}

resource "aws_iam_user_login_profile" "admin" {
  user                    = aws_iam_user.admin.name
  password_reset_required = true
  pgp_key                 = var.bootstrap_pgp_key
}

resource "aws_iam_access_key" "admin" {
  user    = aws_iam_user.admin.name
  pgp_key = var.bootstrap_pgp_key
}
