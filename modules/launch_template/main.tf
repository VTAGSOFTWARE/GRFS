locals {
  name_prefix = "${var.project_name}-${var.environment}"

  ecs_user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
EOF
}

data "aws_ami" "this" {
  most_recent = true
  owners      = [var.compute_mode == "ecs" ? "amazon" : var.ami_owner]

  filter {
    name   = "name"
    values = var.compute_mode == "ecs" ? ["amzn2-ami-ecs-hvm-*-x86_64-ebs"] : [var.ami_name_filter]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id != null ? var.ami_id : data.aws_ami.this.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    security_groups = [var.security_group_id]
  }

  user_data = base64encode(
    var.compute_mode == "ecs" ? local.ecs_user_data : var.user_data_extra
  )

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }
}
