### KEY PAIR
## Reaspm for using keys is really only beacause I like the idea of writting the code so it can be expanded.
# Note that the key must be unique (per region)
resource "aws_key_pair" "terraform_access_key" {
  key_name   = "terraform_usecase_key"
  public_key = file(var.public_key)
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


### EC2 INSTANCE
resource "aws_instance" "web_app_instances" {
  ami                         = data.aws_ami.instance_ami.id 
  instance_type               = var.instance_type
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [var.instance_security_group]
  key_name                    = aws_key_pair.terraform_access_key.key_name
  count                       = var.instance_count

  associate_public_ip_address = true
  
  provisioner "file" {
    source      = "../../files/scripts/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "sudo sed -i -e 's/\r$//' /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }

# Could use user data here - only reason I have not is because I would want to build on this more. If I am
# only going to run the 1 script. User data is better.


  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key)
  }

  tags = {
    Name  = "Terraform_Usecase_instance_${count.index + 1}"
    Owner = "Martyn"
    Role  = "INSTANCE_TERRAFORM_USECASE"   
  }
}

# Create a new load balancer attachment
resource "aws_elb_attachment" "web_elb_attach" {
  count = length(aws_instance.web_app_instances)
  
  elb      = var.web_app_LB
  instance = aws_instance.web_app_instances[count.index].id
}
