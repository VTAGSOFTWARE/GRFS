# Base AMI
# Base Amazon Linux 2023 AMI
data "aws_ami" "base" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "custom" {
  count       = var.use_custom_ami ? 1 : 0
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.name_prefix}-recipe*"]
  }
}

# IAM for Image Builder
resource "aws_iam_role" "image_builder" {
  name = "${var.name_prefix}-image-builder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "image_builder" {
  name = "${var.name_prefix}-image-builder-profile"
  role = aws_iam_role.image_builder.name
}

# Image Builder Component
resource "aws_imagebuilder_component" "custom" {
  name     = "${var.name_prefix}-component"
  platform = "Linux"
  version  = "1.0.0"

  data = <<EOF
name: InstallNodeDockerGit
description: Install Node, Docker, Git
schemaVersion: 1.0

phases:
  - name: build
    steps:
      - name: InstallPackages
        action: ExecuteBash
        inputs:
          commands:
            - dnf update -y
            - dnf install -y nodejs git docker
            - systemctl enable docker
            - systemctl start docker
EOF
}

# Image Recipe
resource "aws_imagebuilder_image_recipe" "this" {
  name         = "${var.name_prefix}-recipe"
  version      = "1.0.0"
  parent_image = data.aws_ami.base.id

  component {
    component_arn = aws_imagebuilder_component.custom.arn
  }
}

# Infrastructure Configuration
resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                          = "${var.name_prefix}-infra"
  instance_profile_name         = aws_iam_instance_profile.image_builder.name
  terminate_instance_on_failure = true

  instance_types = ["t3.medium"]

  subnet_id          = var.subnet_id
  security_group_ids = [var.security_group_id]
}

# Image Pipeline (Manual Trigger)
resource "aws_imagebuilder_image_pipeline" "this" {
  name                             = "${var.name_prefix}-pipeline"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  status                           = "ENABLED"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "secrets_read" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy" "imagebuilder_permissions" {
  name = "${var.name_prefix}-imagebuilder-inline"
  role = aws_iam_role.image_builder.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "imagebuilder:GetComponent",
          "imagebuilder:GetImageRecipe",
          "imagebuilder:GetContainerRecipe",
          "imagebuilder:GetImage"
        ]
        Resource = "*"
      }
    ]
  })
}