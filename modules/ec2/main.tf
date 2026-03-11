locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Get Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 Instance
resource "aws_instance" "this" {

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = var.iam_instance_profile

  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-backend"
  })
}
