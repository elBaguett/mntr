resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "pod_crashloop" {
  alarm_name          = "${var.cluster_name}-pod-restarts"
  namespace           = "ContainerInsights"
  metric_name         = "pod_number_of_container_restarts" 
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  threshold           = 3
  alarm_description   = "High number of container restarts in ${var.cluster_name}"
  dimensions = {
    ClusterName = var.cluster_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "node_not_ready" {
  alarm_name          = "${var.cluster_name}-node-failed"
  namespace           = "ContainerInsights"
  metric_name         = "node_number_of_running_pods" 
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "SampleCount" 
  threshold           = 1
  alarm_description   = "Node failure detected in ${var.cluster_name}"
  dimensions = {
    ClusterName = var.cluster_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "node_failed" {
  alarm_name          = "${var.cluster_name}-nodes-failed"
  namespace           = "ContainerInsights"
  metric_name         = "cluster_failed_node_count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Node failed ${var.cluster_name}"
  dimensions = { ClusterName = var.cluster_name }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_server_latency" {
  alarm_name          = "${var.cluster_name}-api-high-latency"
  namespace           = "ContainerInsights"
  metric_name         = "api_server_latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  threshold           = 0.5
  alarm_description   = "API server latency > 500ms"
  dimensions = {
    ClusterName = var.cluster_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "argocd_alb_5xx" {
  alarm_name          = "argocd-alb-5xx"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  dimensions = {
    LoadBalancer = var.argocd_alb_arn_suffix 
  }
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_dashboard" "k8s_dashboard" {
  dashboard_name = "${var.cluster_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            [ "ContainerInsights", "pod_number_of_container_restarts", "ClusterName", var.cluster_name ]
          ],
          "period": 300,
          "stat": "Sum",
          "region": "eu-west-1",
          "title": "Pod Restarts (Potential CrashLoop)"
        }
      },
      {
        "type": "metric",
        "properties": {
          "metrics": [
            [ "ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name ]
          ],
          "period": 60,
          "stat": "Average",
          "region": "eu-west-1",
          "title": "Node CPU Utilization"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "alb_dashboard" {
  dashboard_name = "argocd-alb-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "region": "eu-west-1",
          "title": "argocd-alb Target 5XX Errors",
          "view": "timeSeries",
          "annotations": {},
          "metrics": [
            [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer",   var.argocd_alb_arn_suffix ]
          ],
          "stat": "Sum",
          "period": 60
        }
      },
      {
        "type": "metric",
        "x": 0, "y": 6, "width": 12, "height": 6,
        "properties": {
          "region": "eu-west-1",
          "title": "argocd-alb Target Response Time (p95)",
          "view": "timeSeries",
          "annotations": {},
          "metrics": [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer",  var.argocd_alb_arn_suffix, { "stat": "p95" } ]
          ],
          "stat": "p95",
          "period": 60
        }
      }
    ]
  })
}