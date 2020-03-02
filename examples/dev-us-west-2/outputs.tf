output "aws_alb_dns_name" {
  description = "The DNS name for the ALB this module creates"
  value       = module.terraform_enterprise.aws_alb_dns_name
}

output "public_hostnames" {
  description = "Hostnames of instances running in public subnets"
  value       = module.terraform_enterprise.public_hostnames
}

output "private_hostnames" {
  description = "Hostnames of instances running in private subnets"
  value       = module.terraform_enterprise.private_hostnames
}

output "private_key_filename" {
  description = "Path to private key used for SSH access to instances"
  value       = module.terraform_enterprise.private_key_filename
}

output "license_s3_bucket_id" {
  description = "The bucket the application license is stored in"
  value       = module.terraform_enterprise.license_s3_bucket_id
}

output "bastion_command" {
  description = "Runnable command to obtain a shell on a bastion host"
  value       = module.terraform_enterprise.bastion_command
}

output "iact_command" {
  description = "Runnable command to obtain the IACT from a frontend host"
  value       = module.terraform_enterprise.iact_command
}

output "initial_admin_user_password" {
  description = "Initial `admin` user password usable for recovery situations"
  value       = random_string.initial_admin_user_password.result
}
