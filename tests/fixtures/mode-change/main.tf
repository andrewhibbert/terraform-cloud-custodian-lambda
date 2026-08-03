data "aws_caller_identity" "current" {}

locals {
  region     = "eu-west-1"
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "custodian-dev-"
  role_name  = "${local.prefix}mode-change-lambda"
  role_arn   = "arn:aws:iam::${local.account_id}:role/${local.role_name}"

  mode_trigger = {
    periodic = {
      schedule = "rate(5 minutes)"
    }
    cloudtrail = {
      events = [
        {
          source = "ec2.amazonaws.com"
          event  = "CreateImage"
          ids    = "responseElements.imageId"
        }
      ]
    }
  }
}

resource "aws_iam_role" "custodian" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

module "cloud_custodian_lambda" {
  source = "../../../"

  regions           = [local.region]
  execution_options = {}

  policies = jsonencode({
    policies = [
      {
        name     = var.policy_name
        resource = "ami"
        filters = [
          {
            type = "image-age"
            days = 7
          }
        ]
        mode = merge({
          type              = var.mode_type
          "function-prefix" = local.prefix
          role              = local.role_arn
          timeout           = 300
          memory            = 256
        }, local.mode_trigger[var.mode_type])
      }
    ]
  })

  depends_on = [
    aws_iam_role.custodian
  ]
}
