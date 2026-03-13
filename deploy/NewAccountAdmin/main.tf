terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
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

resource "random_password" "initial_console_password" {
  length           = 24
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "!@#%^*-_=+?"
}

resource "null_resource" "login_profile" {
  triggers = {
    admin_user_name = aws_iam_user.admin.name
    password        = random_password.initial_console_password.result
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      if aws iam get-login-profile --user-name '${self.triggers.admin_user_name}' >/dev/null 2>&1; then
        aws iam update-login-profile \
          --user-name '${self.triggers.admin_user_name}' \
          --password '${self.triggers.password}' \
          --password-reset-required
      else
        aws iam create-login-profile \
          --user-name '${self.triggers.admin_user_name}' \
          --password '${self.triggers.password}' \
          --password-reset-required
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [aws_iam_user_group_membership.admin]
}

resource "aws_iam_access_key" "admin" {
  user = aws_iam_user.admin.name
}
