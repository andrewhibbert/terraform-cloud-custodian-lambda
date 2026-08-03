moved {
  from = aws_cloudwatch_event_rule.periodic
  to   = aws_cloudwatch_event_rule.cloudwatch_event
}

moved {
  from = aws_cloudwatch_event_rule.cloudwatch_event
  to   = aws_cloudwatch_event_rule.eventbridge_rule
}

moved {
  from = aws_cloudwatch_event_target.periodic
  to   = aws_cloudwatch_event_target.cloudwatch_event
}

moved {
  from = aws_cloudwatch_event_target.cloudwatch_event
  to   = aws_cloudwatch_event_target.eventbridge_rule
}

moved {
  from = aws_lambda_permission.periodic
  to   = aws_lambda_permission.schedule
}

moved {
  from = aws_lambda_permission.schedule
  to   = aws_lambda_permission.cloudwatch_event
}

moved {
  from = aws_lambda_permission.cloudwatch_event
  to   = aws_lambda_permission.config_rule
}

moved {
  from = aws_lambda_permission.config_rule
  to   = aws_lambda_permission.custodian
}
