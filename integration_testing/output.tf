output "EC2_Instances" {
  value = module.EC2.instances
}
output "web_app_LB_dns_name" {
  value = module.VPC.web_app_LB_dns_name
}