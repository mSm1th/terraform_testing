module "VPC" {
  source            = "./modules/VPC"
  region            = var.region
  main_cidr         = var.main_cidr
  availability_zone = var.availability_zone
}

module "EC2" {
  source                  = "./modules/EC2"
  public_key              = var.public_key
  private_key             = var.private_key
  instance_type           = var.instance_type
  instance_count          = var.instance_count
  subnet                  = module.VPC.subnet
  instance_security_group = module.VPC.instance_security_group
  web_app_LB              = module.VPC.web_app_LB
}