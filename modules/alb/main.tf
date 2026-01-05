resource "aws_lb" "alb" {
  name               = "service-qa-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [var.alb_security_group_id]
  subnets         = var.public_subnet_ids

  tags = merge(var.tags, { Name = "service-qa-alb"})
}

resource "aws_lb_target_group" "api" {
  name        = "service-qa-api-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "service-qa-api-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
