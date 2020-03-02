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

variable "vpc_id" {
  description = "The VPC this module will run in"
  type        = string
}

variable "environment" {
  description = "The environment this module will run in"
  type        = string
}

variable "region" {
  description = "The region this module will run in"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs the underlying `aws_alb` resource uses"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------
