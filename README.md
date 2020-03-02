# terraform-aws-terraform-enterprise

## Overview

This repository holds a module for AWS that provides a Terraform Enterprise deployment.

The module consumes the following helpers in the [`modules/`](./modules) directory:

- `license`: Stateful storage of Terraform Enterprise license
- `compute`: EC2 instances supporting the Terraform Enterprise frontend app
- `alb`: ALB configuration to load balance ingress towards frontend instances


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| database\_endpoint | The database endpoint used by this module during runtime | `string` | n/a | yes |
| database\_password | The password for a `aws\_db\_instance` resource | `string` | n/a | yes |
| environment | The environment this module will run in | `string` | n/a | yes |
| private\_cidr\_blocks | The private CIDR blocks available to this module | `list(string)` | n/a | yes |
| private\_subnet\_ids | The private subnet IDs applicable to this module | `list(string)` | n/a | yes |
| public\_cidr\_blocks | The public CIDR blocks available to this module | `list(string)` | n/a | yes |
| public\_subnet\_ids | The public subnet IDs applicable to this module | `list(string)` | n/a | yes |
| region | The region this module will run in | `string` | n/a | yes |
| vpc\_id | The VPC this module will run in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_alb\_dns\_name | The DNS name for the ALB this module creates |
| license\_s3\_bucket\_id | The bucket the application license is stored in |
| private\_hostnames | Hostnames of instances running in private subnets |
| private\_key\_filename | Path to private key used for SSH access to instances |
| public\_hostnames | Hostnames of instances running in public subnets |


## Usage

```hcl
module "terraform_enterprise" {
  source = "github.com/github/terraform-aws-terraform-enterprise?ref=v0.0.1"

  # Service
  environment = var.environment
  region      = var.region

  # Platform
  database_endpoint = module.database.aws_rds_cluster.endpoint
  database_password = random_string.database_password.result

  # Foundation
  vpc_id      = module.foundation.vpc_id
  cidr_blocks = module.foundation.private_cidr_blocks
  subnet_ids  = module.foundation.private_subnet_ids

}
```

Check out the [examples](../examples) for fully-working sample code that the [tests](../test) exercise. Paved path testing patterns are documented [here](https://github.com/github/terraform-enterprise/blob/master/docs/modules.md#testing).

---

This repo has the following folder structure:

* root folder: The root folder contains a single, standalone, reusable, production-grade module.
* [modules](./modules): This folder may contain supporting modules to the root module.
* [examples](./examples): This folder shows examples of different ways to configure the root module and is typically exercised by tests.
* [test](./test): Automated tests for the modules and examples.

See the [official docs](https://www.terraform.io/docs/modules/index.html) for further details.

---

This repository was initialized with an Issue Template.
[See here](https://github.com/github/terraform-aws-terraform-enterprise/issues/new/choose).
