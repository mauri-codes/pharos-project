output "admin_group_name" {
  value = aws_iam_group.admin.name
}

output "admin_user_name" {
  value = aws_iam_user.admin.name
}

output "initial_console_password" {
  value     = random_password.initial_console_password.result
  sensitive = true
}

output "access_key_id" {
  value = aws_iam_access_key.admin.id
}

output "access_key_secret" {
  value     = aws_iam_access_key.admin.secret
  sensitive = true
}
