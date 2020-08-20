### AWS KEYS
### Key vaules are stored within terraform.tfvars file which should be in your gitignore.

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

### VPC RELATED VARIABLES
variable "region" {
  default     = "eu-west-1"
  description = "region that the VPC and other network components should be deployed into."
}

variable "main_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR vaule that will be used within the main vpc config"
}


## This can be dynamic using data sources.
variable "availability_zone" {
  default     = "eu-west-1c"
  description = "availability_zone that should be used within the subnet component."
}
### INSTANCE RELATED VARIABLES

variable "public_key" {
  default     = "/home/ms/.ssh/aws_key.pub"
  description = "The public key path."
}

variable "private_key" {
  default     = "/home/ms/.ssh/aws_key"
  description = "The private key path."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The instance type that will be used when creating the EC2 instances."
}

variable "instance_count" {
  default     = 2
  description = "The number of EC2 instances to be created."
}
