### AWS KEYS
### Key vaules are stored within terraform.tfvars file which should be in your gitignore.

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

### VPC RELATED VARIABLES
variable "region" {
  default     = "eu-west-1"
  description = "region that the VPC and other network components should be deployed into."
}
