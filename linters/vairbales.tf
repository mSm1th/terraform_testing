variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "region" {
  default     = "eu-west-1"
  description = "region that the VPC and other network components should be deployed into."
}