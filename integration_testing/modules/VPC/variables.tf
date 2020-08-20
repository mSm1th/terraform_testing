variable "main_cidr" {
  description = "CIDR vaule that will be used within the vpc `cidr_block` field."
}

variable "availability_zone" {
  description = "availability_zone that should be used within the subnet component."
}

variable "region" {
  description = "region that the VPC and other network components should be deployed into."
}
