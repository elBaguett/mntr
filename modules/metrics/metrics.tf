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
  metric_name         = "pod_status_failed"
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
  metric_name         = "node_status_condition_ready"
  comparison_operator = "LessThanThreshold"
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
  alarm_description   = "5xx от целевых серверов argocd-alb"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "k8s_dashboard" {
  dashboard_name = "${var.cluster_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "region": "eu-west-1", 
          "view": "timeSeries",
          "title": "K8s Nodes NotReady",
          "metrics": [
            [ "ContainerInsights", "node_status", "ClusterName", var.cluster_name, "NodeStatus", "NotReady" ]
          ],
          "period": 60,
          "stat": "Sum",
          "annotations": {}
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 6,
        "width": 12,
        "height": 6,
        "properties": {
          "region": "eu-west-1",
          "view": "timeSeries",
          "title": "K8s CrashLoopBackOff Pods",
          "metrics": [
            [ "ContainerInsights", "pod_status", "ClusterName", var.cluster_name, "PodStatus", "CrashLoopBackOff" ]
          ],
          "period": 60,
          "stat": "Sum",
          "annotations": {}
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 12,
        "width": 12,
        "height": 6,
        "properties": {
          "region": "eu-west-1",
          "view": "timeSeries",
          "title": "API Server Latency (s)",
          "metrics": [
            [ "ContainerInsights", "api_server_latency", "ClusterName", var.cluster_name ]
          ],
          "period": 60,
          "stat": "Average",
          "annotations": {}
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 18,
        "width": 12,
        "height": 6,
        "properties": {
          "region": "eu-west-1",
          "view": "timeSeries",
          "title": "Frontend 5xx errors",
          "metrics": [
            [ "ContainerInsights", "http_status_code", "ClusterName", var.cluster_name, "Namespace", "frontend", "code", "5xx" ]
          ],
          "period": 60,
          "stat": "Sum",
          "annotations": {}
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