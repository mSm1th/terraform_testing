data "http" "user_pub_id" {
  url = "http://ipv4.icanhazip.com"

  request_headers = {
    Accept = "text/*"
  }
}


data "aws_ami" "instance_ami" {
  most_recent      = true
  owners           = ["099720109477"] 
  # Canonical owner ID - Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.??-*"]
  } 

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  # Run an Ubuntu 18.04 AMI on the EC2 instance.
  ami                    = data.aws_ami.instance_ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  # When the instance boots, start a web server on port 8080 that responds with "Hello, World!".
  user_data = <<EOF
#!/bin/bash
echo "Hello, World!" > index.html
nohup busybox httpd -f -p 8080 &
EOF
}

# Allow the instance to receive requests on port 8080.
resource "aws_security_group" "instance" {
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.user_pub_id.body)}/32"]
  }
}

# Output the instance's public IP address.
output "public_ip" {
  value = aws_instance.example.public_ip
}

