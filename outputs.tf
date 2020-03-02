output "aws_alb_dns_name" {
  description = "The DNS name for the ALB this module creates"
  value       = module.alb.aws_alb_dns_name
}

output "public_hostnames" {
  description = "Hostnames of instances running in public subnets"
  value       = module.compute.public_hostnames
}

output "private_hostnames" {
  description = "Hostnames of instances running in private subnets"
  value       = module.compute.private_hostnames
}

output "private_key_filename" {
  description = "Path to private key used for SSH access to instances"
  value       = module.compute.private_key_filename
}

output "license_s3_bucket_id" {
  description = "The bucket the application license is stored in"
  value       = module.license.license_s3_bucket_id
}

output "bastion_command" {
  description = "Runnable command to obtain a shell on a bastion host"
  value       = "ssh -l admin -i ${module.compute.private_key_filename} ${element(module.compute.public_hostnames, 0)}"
}

output "iact_command" {
  description = "Runnable command to obtain the IACT from a frontend host"
  value       = "ssh -l admin -i ${module.compute.private_key_filename} ${element(module.compute.public_hostnames, 0)} ssh -o StrictHostKeyChecking=no -i ${module.compute.private_key_filename} ${element(module.compute.private_hostnames, 0)} cat /tmp/initial_admin_user_password.json"
}
