resource "aws_lb" "main" {
  name               = "${var.namespace}-${var.project_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.main.id
  ]
  subnets = [for subnet in aws_subnet.main : subnet.id]
}
