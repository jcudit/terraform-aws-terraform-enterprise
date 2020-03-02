output "public_hostnames" {
  description = "Hostnames of instances running in public subnets"
  value       = aws_instance.bastion.*.public_dns
}

output "private_key_filename" {
  description = "Path to private key used for SSH access to instances"
  value       = local.private_key_filename
}

output "private_key_content" {
  description = "Private key used for SSH access to instances"
  value       = local_file.private_key_pem.content
}

output "private_hostnames" {
  description = "Hostnames of instances running in private subnets"
  value       = data.aws_instances.fe.private_ips
}

data "aws_instances" "fe" {
  # Query for ASG-maanged frontend instances
  instance_tags = {
    app  = "tfe"
    role = "fe"
  }

  depends_on = [aws_autoscaling_group.fe]
}
