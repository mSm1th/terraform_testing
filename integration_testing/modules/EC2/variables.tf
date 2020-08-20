variable "region" {
  description = "region that the VPC and other network components should be deployed into."
}

variable "public_key" {
  description = "The SSH key name."
}

variable "private_key" {
  description = "The private key name."
}

variable "instance_type" {
  description = "The instance type that will be used when creating the EC2 instances."
}

variable "instance_count" {
  description = "The number of EC2 to be created."
}

## INPUT VARIABLES REFERENCED VPC MODULES
variable "subnet" {
  description = "The subnet that will be referenced for the instance creation."
}

variable "instance_security_group" {
  description = "The security group that will be rereferenced for the instance creation."
}

variable "web_app_LB" {
  description = "The load balancer id that will be used to add the instances within the pool of instances within the LB."
}