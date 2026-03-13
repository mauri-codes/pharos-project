output "admin_group_name" {
  value = aws_iam_group.admin.name
}

output "admin_user_name" {
  value = aws_iam_user.admin.name
}

output "encrypted_initial_console_password" {
  value     = aws_iam_user_login_profile.admin.encrypted_password
  sensitive = true
}

output "access_key_id" {
  value = aws_iam_access_key.admin.id
}

output "encrypted_access_key_secret" {
  value     = aws_iam_access_key.admin.encrypted_secret
  sensitive = true
}

output "pgp_key_fingerprint" {
  value = aws_iam_user_login_profile.admin.key_fingerprint
}
