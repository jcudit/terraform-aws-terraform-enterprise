# compute

This is a helper module that suppports the root module. Terraform Enterprise is configured and installed to an EC2 instance with this submodule. An `s3` bucket is also created for runtime use.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alb\_security\_group\_id | The security group ID of the ALB supporting this module | `string` | n/a | yes |
| alb\_target\_group\_arn | The target group associated with the ALB supporting this module | `string` | n/a | yes |
| aws\_instance\_ami | The instance AMI this module leverages when creating instances | `string` | `"ami-08328006475c2574b"` | no |
| aws\_instance\_count | The number of AWS instances supporting this module | `number` | `1` | no |
| aws\_instance\_type | The instance type this module leverages when creating instances | `string` | `"m5.large"` | no |
| database\_endpoint | The database endpoint used by this module during runtime | `string` | n/a | yes |
| database\_password | The password for a `aws\_db\_instance` resource | `string` | n/a | yes |
| enable\_bastion | Boolean to enable provisioning a bastion host | `bool` | `true` | no |
| environment | The environment this module will run in | `string` | n/a | yes |
| license\_s3\_bucket\_id | Bucket ID where the Terraform Enterprise license is stashed | `string` | n/a | yes |
| private\_cidr\_blocks | The private CIDR blocks available to this module | `list(string)` | n/a | yes |
| private\_subnet\_ids | The private subnet IDs applicable to this module | `list(string)` | n/a | yes |
| public\_cidr\_blocks | The public CIDR blocks available to this module | `list(string)` | n/a | yes |
| public\_subnet\_ids | The public subnet IDs applicable to this module | `list(string)` | n/a | yes |
| region | The region this module will run in | `string` | n/a | yes |
| vpc\_id | ID of the VPC compute instances will reside within | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| enc\_password | Password used to encrypt sensitive information at rest |
| private\_hostnames | Hostnames of instances running in private subnets |
| private\_key\_content | Private key used for SSH access to instances |
| private\_key\_filename | Path to private key used for SSH access to instances |
| public\_hostnames | Hostnames of instances running in public subnets |

## Usage

```
module "compute" {
  source = "./modules/compute"

  environment = var.environment
  region      = var.region
  owner       = var.owner

  subnet_ids = var.subnet_ids
  sg_ids     = var.sg_ids

  database_endpoint    = var.database_endpoint
  database_password    = var.database_password
  license_s3_bucket_id = module.license.license_s3_bucket_id
}
```
