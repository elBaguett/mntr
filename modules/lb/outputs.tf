output "dns_name" {
  value = aws_lb.argocd_alb.dns_name
}

output "zone_id" {
  value = aws_lb.argocd_alb.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.argocd.arn
}
