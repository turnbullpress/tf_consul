# AWS Consul service module for Terraform

A lightweight Consul service module for The Terraform Book.

## Usage

```hcl
variable "token" {}

variable "encryption_key" {}

module "consul" {
  source            = "github.com/turnbullpublishing/tf_consul"
  environment       = "${var.environment}"
  token             = "${var.token}"
  encryption_key    = "${var.encryption_key}"
  vpc_id            = "${module.vpc.vpc_id}"
  public_subnet_id  = "${var.public_subnet_id}"
  region            = "${var.region}"
  key_name          = "${var.key_name}"
}

output "consul_server_address" {
  value = ["${module.consul.dns_address}"]
}

output "consul_host_addresses" {
  value = ["${module.consul.host_addresses}"]
}
```

Assumes you're building your Consul service inside a VPC created from [this
module](https://github.com/turnbullpublishing/tf_vpc).

See `interface.tf` for additional configurable variables.

## License

MIT

