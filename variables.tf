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
  description = "The VPC this module will run in"
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
