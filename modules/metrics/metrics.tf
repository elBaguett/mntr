resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "pod_crashloop" {
  alarm_name          = "${var.cluster_name}-pod-crashloop"
  namespace           = "ContainerInsights"
  metric_name         = "pod_status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Pod CrashLoopBackOff detected in ${var.cluster_name}"
  dimensions = {
    ClusterName = var.cluster_name
    PodStatus   = "CrashLoopBackOff"
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "node_not_ready" {
  alarm_name          = "${var.cluster_name}-node-not-ready"
  namespace           = "ContainerInsights"
  metric_name         = "node_status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Node NotReady in ${var.cluster_name}"
  dimensions = {
    ClusterName = var.cluster_name
    NodeStatus  = "NotReady"
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "${var.cluster_name}-api-high-latency"
  namespace           = "ContainerInsights"
  metric_name         = "api_server_latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  threshold           = 0.5
  alarm_description   = "High apiserver latency detected in ${var.cluster_name}"
  dimensions = {
    ClusterName = var.cluster_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_http_errors" {
  alarm_name          = "frontend-http-5xx-${var.cluster_name}"
  namespace           = "ContainerInsights"
  metric_name         = "http_status_code"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = "frontend"
    code        = "5xx"
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}