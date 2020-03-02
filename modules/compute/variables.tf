# ------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "environment" {
  description = "The environment this module will run in"
  type        = string
}

variable "region" {
  description = "The region this module will run in"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC compute instances will reside within"
  type        = string
}

variable "public_subnet_ids" {
  description = "The public subnet IDs applicable to this module"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The private subnet IDs applicable to this module"
  type        = list(string)
}

variable "public_cidr_blocks" {
  description = "The public CIDR blocks available to this module"
  type        = list(string)
}

variable "private_cidr_blocks" {
  description = "The private CIDR blocks available to this module"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The security group ID of the ALB supporting this module"
  type        = string
}

variable "alb_target_group_arn" {
  description = "The target group associated with the ALB supporting this module"
  type        = string
}

variable "license_s3_bucket_id" {
  description = "Bucket ID where the Terraform Enterprise license is stashed"
  type        = string
}

variable "database_endpoint" {
  description = "The database endpoint used by this module during runtime"
  type        = string
}

variable "database_password" {
  description = "The password for a `aws_db_instance` resource"
  type        = string
}

variable "enc_password" {
  # https://www.terraform.io/docs/enterprise/install/encryption-password.html
  description = "Password used to encrypt sensitive information at rest"
  type        = string
}

variable "initial_admin_user_password" {
  description = "Initial `admin` user password usable for recovery situations"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_instance_ami" {
  description = "The instance AMI this module leverages when creating instances"
  type        = string
  # FIXME: Use an AMI built from the existing pipeline instead of a public one
  default = "ami-08328006475c2574b"
}

variable "aws_instance_type" {
  description = "The instance type this module leverages when creating instances"
  type        = string
  default     = "m5.large"
}

variable "aws_instance_count" {
  description = "The number of AWS instances supporting this module"
  type        = number
  default     = 1
}

variable "enable_bastion" {
  description = "Boolean to enable provisioning a bastion host"
  type        = bool
  default     = true
}
