#-------------------------------------------------------------------------------
# CLOUDWATCH METRIC ALARMS
#-------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb" {
  alarm_name                = "alb_target_connection_error_count"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "TargetConnectionErrorCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "0"
  alarm_description         = "ALB target connection error count"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "compute" {
  alarm_name                = "compute_saturated"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}
