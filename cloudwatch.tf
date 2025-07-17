# create a loggroup with less retention of 7 days
# create a cloudwatch alaram with no actions enabled


resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/misconfigured/finding-${random_string.random_name.result}"
  retention_in_days = 3
}


resource "aws_cloudwatch_log_metric_filter" "nonawsip" {
  depends_on = [
    aws_cloudwatch_log_group.example
  ]
  name           = "misconfigured"
  pattern        = "{ ($.userIdentity.type = \"AssumedRole\" )  }"
  log_group_name = aws_cloudwatch_log_group.example.name
  metric_transformation {
    name      = "misconfigured-finding"
    namespace = "steampipe"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "sshec2fail" {
  depends_on = [
    aws_cloudwatch_log_group.example, aws_cloudwatch_log_metric_filter.nonawsip
  ]
  alarm_name                = "misconfigured-finding-${random_string.random_name.result}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "misconfigured-finding"
  namespace                 = "steampipe"
  period                    = "900"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors misconfigured findings"
  insufficient_data_actions = []
}
