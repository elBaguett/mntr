resource "aws_lb" "argocd_alb" {
  name               = "argocd-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets_id 
  security_groups    = var.vpc_security_group_ids
}

resource "aws_lb_target_group" "argocd" {
  name        = "argocd-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.argocd_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd.arn
  }
}

