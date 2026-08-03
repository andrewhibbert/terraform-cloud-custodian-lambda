output "mode_type" {
  description = "The type of Cloud Custodian mode (periodic, cloudtrail, config-rule, etc.)"
  value       = module.cloud_custodian_lambda.mode_type
}

output "lambda_function_name" {
  description = "The name of the lambda function"
  value       = try(module.cloud_custodian_lambda.lambda_function_name[local.region], "")
}

output "lambda_function_arn" {
  description = "The ARN of the lambda function"
  value       = try(module.cloud_custodian_lambda.lambda_function_arn[local.region], "")
}

output "periodic_event_rule_name" {
  description = "The name of the CloudWatch Event Rule for periodic mode"
  value       = try(module.cloud_custodian_lambda.periodic_event_rule_name[local.region], "")
}

output "periodic_event_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule for periodic mode"
  value       = try(module.cloud_custodian_lambda.periodic_event_rule_arn[local.region], "")
}

output "periodic_schedule_expression" {
  description = "The schedule expression for periodic mode"
  value       = try(module.cloud_custodian_lambda.periodic_schedule_expression[local.region], "")
}

output "cloudwatch_event_rule_name" {
  description = "The name of the CloudWatch Event Rule for event mode"
  value       = try(module.cloud_custodian_lambda.cloudwatch_event_rule_name[local.region], "")
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch Event Rule for event mode"
  value       = try(module.cloud_custodian_lambda.cloudwatch_event_rule_arn[local.region], "")
}

output "cloudwatch_event_pattern" {
  description = "The event pattern for event mode"
  value       = try(module.cloud_custodian_lambda.cloudwatch_event_pattern[local.region], "")
}
