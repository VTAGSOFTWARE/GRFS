resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Lambda security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = try(ingress.value.description, null)
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol

      cidr_blocks     = try(ingress.value.cidr_blocks, null)
      security_groups = try(ingress.value.security_group_ids, null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidrs
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-lambda-sg" })
}
