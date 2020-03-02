resource "random_string" "id" {
  length  = 6
  upper   = false
  number  = false
  special = false
}

# ------------------------------------------------------------------------------
# LICENSE
# ------------------------------------------------------------------------------

module "license" {
  source = "./modules/license"

  environment = var.environment
  region      = var.region
}

# ------------------------------------------------------------------------------
# INGRESS
# ------------------------------------------------------------------------------

module "alb" {
  source = "./modules/alb"

  environment = var.environment
  region      = var.region

  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids
}

# ------------------------------------------------------------------------------
# COMPUTE
# ------------------------------------------------------------------------------

module "compute" {
  source = "./modules/compute"

  environment                 = var.environment
  region                      = var.region
  enc_password                = var.enc_password
  initial_admin_user_password = var.initial_admin_user_password

  alb_security_group_id = module.alb.security_group_id
  alb_target_group_arn  = module.alb.target_group_arn
  license_s3_bucket_id  = module.license.license_s3_bucket_id

  # Platform
  database_endpoint = var.database_endpoint
  database_password = var.database_password

  # Foundation
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  private_cidr_blocks = var.private_cidr_blocks
  public_subnet_ids   = var.public_subnet_ids
  public_cidr_blocks  = var.public_cidr_blocks

}

# ------------------------------------------------------------------------------
# OBSERVABILITY
# ------------------------------------------------------------------------------

module "observability" {
  source = "./modules/observability"

  environment = var.environment
  region      = var.region

}
