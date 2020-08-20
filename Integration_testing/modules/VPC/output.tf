output "subnet" {
  description = "The subnet that will be referenced for the instance creation."
  value       = aws_subnet.terraform_subnet.id
}

output "instance_security_group" {
  description = "The security group that will be rereferenced for the instance creation."
  value       = aws_security_group.terraform_instance_security_group.id
}

output "web_app_LB" {
  description = "The load balancer id that will be used to add the instances within the pool of instances within the LB."
  value       = aws_elb.web_app_load_balancer.id
}

output "web_app_LB_dns_name" {
  description = "The load balancer name that the user will be able to browse to."
  value       = aws_elb.web_app_load_balancer.dns_name
}