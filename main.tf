data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "userdata" {
  template = file("${abspath(path.module)}/userdata.sh")
  vars = {
    server_name = var.server_name
  }
}

resource "aws_instance" "tf_my_ec2" {
  ami                    = data.aws_ami.amazon-linux-2
  instance_type          = var.instance_type
  count                  = var.num_of_instance
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  user_data              = data.template_file.userdata
  tags = {
    Name = var.tag
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name        = "$(var.tag)-terraform-sec-grp"
  description = "Allow 22, 80, 8080 inbound traffic"

  tags = {
    Name = var.tag
  }

  dynamic "ingress" {
    for_each = var.docker_instance_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}