# license

This is a helper module that suppports the root module.  An `s3` bucket is created and loaded with the license file in this directory.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | The environment this module will run in | `string` | n/a | yes |
| region | The region this module will run in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| license\_s3\_bucket\_id | The bucket the application license is stored in |

## Usage

```
module "license" {
  source = "./modules/license"

  environment = var.environment
  region      = var.region
}
```
