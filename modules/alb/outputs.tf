output "aws_alb_dns_name" {
  description = "The DNS name for the ALB this module creates"
  value       = aws_alb.tfe_alb.dns_name
}

output "target_group_arn" {
  description = "The ARN of a target group attached to the ALB this module creates"
  value       = aws_alb_target_group.tfe.arn
}

output "security_group_id" {
  description = "The ID of the security group attached to the ALB this module creates"
  value       = aws_security_group.tfe_alb.id
}
