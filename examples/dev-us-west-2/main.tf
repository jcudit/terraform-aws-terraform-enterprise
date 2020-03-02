# ------------------------------------------------------------------------------
# FOUNDATION
# ------------------------------------------------------------------------------

resource "random_string" "id" {
  length  = 6
  special = false
}

module "foundation" {
  source = "github.com/jcudit/terraform-aws-foundation-minimal?ref=v0.0.1"

  region      = "us-west-2"
  environment = "development"
}

# ------------------------------------------------------------------------------
# PLATFORMS
# ------------------------------------------------------------------------------

resource "random_string" "database_password" {
  length  = 16
  special = false
}

module "database" {

  source = "github.com/jcudit/terraform-aws-rds-postgres?ref=v0.0.1"

  environment = var.environment
  region      = var.region
  service     = "terraform-enterprise"

  database_name   = "ptfe"
  master_username = "ptfe"
  master_password = random_string.database_password.result

  # Foundation
  vpc_id      = module.foundation.vpc_id
  cidr_blocks = module.foundation.private_cidr_blocks
  subnet_ids  = module.foundation.private_subnet_ids

}

# ------------------------------------------------------------------------------
# ROOT MODULE
# ------------------------------------------------------------------------------

resource "random_string" "enc_password" {
  length = 64
}

resource "random_string" "initial_admin_user_password" {
  length = 64
}

module "terraform_enterprise" {
  source = "../../"

  # Service
  environment                 = var.environment
  region                      = var.region
  enc_password                = random_string.enc_password.result
  initial_admin_user_password = random_string.initial_admin_user_password.result

  # Platform
  database_endpoint = module.database.aws_rds_cluster.endpoint
  database_password = random_string.database_password.result

  # Foundation
  vpc_id              = module.foundation.vpc_id
  private_cidr_blocks = module.foundation.private_cidr_blocks
  private_subnet_ids  = module.foundation.private_subnet_ids
  public_cidr_blocks  = module.foundation.public_cidr_blocks
  public_subnet_ids   = module.foundation.public_subnet_ids

}
