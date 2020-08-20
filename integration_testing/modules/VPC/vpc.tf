## GET public IP of host and use within egree rules. (Unfortunatly)
## Could also try - "http://ifconfig.io/ip"

data "http" "user_pub_id" {
  url = "http://ipv4.icanhazip.com"

  request_headers = {
    Accept = "text/*"
  }
}

### VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = var.main_cidr
  instance_tenancy = "default"

  tags = {
    Name  = "Terraform_Usecase_VPC"
    Owner = "Martyn"
    Role  = "VPC_TERRAFORM_USECASE"   
  }       
}
### GATEWAY
resource "aws_internet_gateway" "terraform_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id
  
  tags = {
    Name  = "Terraform_Usecase_Gateway"
    Owner = "Martyn"
    Role  = "GATEWAY_TERRAFORM_USECASE"   
  }
}

### SUBNET
resource "aws_subnet" "terraform_subnet" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = var.main_cidr
  availability_zone = var.availability_zone

  tags = {
    Name  = "Terraform_Usecase_Subnet"
    Owner = "Martyn"
    Role  = "SUBNET_TERRAFORM_USECASE"   
  }
}

# Create a new classic load balancer
resource "aws_elb" "web_app_load_balancer" {
  name            = "terraform-usecase"
  #an only have AZ or subnets (not both)
  
  security_groups = [aws_security_group.terraform_lb_security_group.id]
  subnets         = [aws_subnet.terraform_subnet.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name  = "Terraform_Usecase_LB"
    Owner = "Martyn"
    Role  = "NETORK_LB_TERRAFORM_USECASE"   
  }
}


## INSTANCE SEC GROUP
resource "aws_security_group" "terraform_instance_security_group" {
  vpc_id      = aws_vpc.terraform_vpc.id
  name        = "terraform_instance_security_group"
  description = "Security group for ec2 instances."


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform_lb_security_group.id]
    cidr_blocks      = ["${chomp(data.http.user_pub_id.body)}/32"]
  }

## So the host can ssh if needed.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.user_pub_id.body)}/32"]
  }


  tags = {
    Name  = "Terraform_Usecase_Sec_Group_Instance"
    Owner = "Martyn"
    Role  = "SEC_GROUP_INSTANCE_TERRAFORM_USECASE"   
  }
}

## LB  SEC GROUP
resource "aws_security_group" "terraform_lb_security_group" {
  vpc_id      = aws_vpc.terraform_vpc.id
  name        = "terraform_lb_security_group"
  description = "Security group for the load balancer."

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TCP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.user_pub_id.body)}/32"]
  }

  tags = {
    Name  = "Terraform_Usecase_Sec_Group_LB"
    Owner = "Martyn"
    Role  = "SEC_GROUP_LB_TERRAFORM_USECASE"   
  }
}


### ROUTING TABLE
resource "aws_route_table" "terraform_RT" {
  vpc_id = aws_vpc.terraform_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_gateway.id
  }

  tags = {
    Name  = "Terraform_Usecase_routing_table"
    Owner = "Martyn"
    Role  = "RT_TERRAFORM_USECASE"   
  }
}

### Route table assoociation
resource "aws_route_table_association" "Terraform_RT_Assoc" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_RT.id
}
