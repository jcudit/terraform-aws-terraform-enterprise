# alb

This is a helper module that suppports the root module. Notable resources created by this module are:

- `aws_acm_certificate`: used for securing ingress traffic
- `aws_alb` / `aws_alb_target_group`: used for load balancing ingress traffic

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | The environment this module will run in | `string` | n/a | yes |
| region | The region this module will run in | `string` | n/a | yes |
| subnet\_ids | The subnet IDs the underlying `aws\_alb` resource uses | `list(string)` | n/a | yes |
| vpc\_id | The VPC this module will run in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_alb\_dns\_name | The DNS name for the ALB this module creates |
| security\_group\_id | The ID of the security group attached to the ALB this module creates |
| target\_group\_arn | The ARN of a target group attached to the ALB this module creates |

## Usage

```
module "alb" {
  source = "./modules/alb"

  environment = var.environment
  hostname    = "terraform-${var.environment}.example.com"

  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids
  sg_ids       = var.sg_ids
  instance_ids = module.compute.instance_ids
}
```
