output "ami_id" {
  value = var.use_custom_ami ? data.aws_ami.custom[0].id : data.aws_ami.base.id
}