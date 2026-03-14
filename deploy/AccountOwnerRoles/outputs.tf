output "role_name" {
  description = "Name of the created IAM role."
  value       = aws_iam_role.account_owner.name
}

output "role_arn" {
  description = "ARN of the created IAM role."
  value       = aws_iam_role.account_owner.arn
}

output "policy_name" {
  description = "Name of the created IAM policy."
  value       = aws_iam_policy.account_owner.name
}

output "policy_arn" {
  description = "ARN of the created IAM policy."
  value       = aws_iam_policy.account_owner.arn
}
