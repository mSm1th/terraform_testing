output "instances" {
  description = "A list of all of the AWS EC2 instances that have been created."
  value       = aws_instance.web_app_instances[*].public_ip
}