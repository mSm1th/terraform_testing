variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "region" {
  default     = "eu-west-1"
  description = "region that the VPC and other network components should be deployed into."
}

variable "testing" {
  default     = "PASSWORD*"
  description = "A default password used for testing"
}

variable "main_cidr" {
  description = "CIDR vaule that will be used within the vpc `cidr_block` field."
  default     = "0.0.0.0/32"
}

variable "availability_zone" {
  description = "availability_zone that should be used within the subnet component."
}