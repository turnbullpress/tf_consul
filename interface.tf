variable "region" {
  description = "The AWS region."
}

variable "environment" {
  description = "The name of our environment, i.e. development."
}

variable "key_name" {
  description = "The AWS key pair to use for resources."
}

variable "ami" {
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
  }

  description = "The AMIs to use for consul instances."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The instance type to launch "
}

variable "vpc_id" {
  description = "The VPC ID to launch in"
}

variable "public_subnet_id" {
  description = "The public subnet ID available to launch in"
}

variable "servers" {
  description = "Number of servers in the Consul cluster"
  default     = "3"
}

variable "token" {
  description = "Consul ACL master token"
}

variable "encryption_key" {
  description = "Consul cluster encryption key"
}

output "consul_dns_address" {
  value = "${aws_instance.server.0.public_dns}"
}

output "consul_host_addresses" {
  value = ["${aws_instance.server.*.private_ip}"]
}

output "consul_datacenter" {
  value = "${data.template_file.master.vars.environment}"
}
