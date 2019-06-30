variable "region" {
  type = string
  description = "The AWS region."
}

variable "environment" {
  type = string
  description = "The name of our environment, i.e. development."
}

variable "key_name" {
  type = string
  description = "The AWS key pair to use for resources."
}

variable "private_key_path" {
  type = string
  description = "The path to the private ssh key"
}

variable "ami" {
  type = map(string)
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
  }

  description = "The AMIs to use for consul instances."
}

variable "instance_type" {
  type = string
  default     = "t2.micro"
  description = "The instance type to launch "
}

variable "vpc_id" {
  type = string
  description = "The VPC ID to launch in"
}

variable "public_subnet_id" {
  type = string
  description = "The public subnet ID available to launch in"
}

variable "servers" {
  type = number
  description = "Number of servers in the Consul cluster"
  default     = "3"
}

variable "token" {
  type = string
  description = "Consul ACL master token"
}

variable "encryption_key" {
  type = string
  description = "Consul cluster encryption key"
}

output "consul_dns_addresses" {
  value = aws_instance.server[*].public_dns
}

output "consul_host_addresses" {
  value = aws_instance.server[*].private_ip
}

output "consul_datacenter" {
  value = data.template_file.master.vars.environment
}

