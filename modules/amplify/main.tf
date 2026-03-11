resource "aws_amplify_app" "this" {
  name       = var.app_name
  repository = var.repository_url

  # For GitHub/GitLab/Bitbucket, Amplify needs a token to connect.
  oauth_token = var.oauth_token

  enable_branch_auto_build = var.enable_auto_build

  environment_variables = var.environment_variables

  # Optional: for SPA routing (React)
  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "200"
  }

  tags = var.tags
}

resource "aws_amplify_branch" "this" {
  app_id      = aws_amplify_app.this.id
  branch_name = var.branch_name

  framework = var.framework
  stage     = var.stage

  enable_auto_build = var.enable_auto_build

  environment_variables = var.branch_environment_variables

  tags = var.tags
}