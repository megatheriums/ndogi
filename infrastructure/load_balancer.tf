resource "aws_lb" "main" {
  name               = substr("${var.namespace}-${var.project_name}-${var.environment}", 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.main.id
  ]
  subnets = [for subnet in aws_subnet.main : subnet.id]
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name        = substr("${var.namespace}-${var.project_name}-${var.environment}", 0, 32)
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
}
