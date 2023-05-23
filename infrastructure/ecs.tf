resource "aws_ecs_task_definition" "main" {
  depends_on = [
    null_resource.image
  ]

  family = "${var.namespace}-${var.project_name}-${var.environment}-main"
  cpu    = 1024
  memory = 2048
  requires_compatibilities = [
    "FARGATE"
  ]
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_main.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "main"
      image     = aws_ecr_repository.main.repository_url
      essential = true
      cpu       = 1024
      portMappings = [
        {
          containerPort = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "aws_ecs_service" "main" {
  name            = "main"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name = "main"
    container_port = 3000
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.main.id
    ]
    subnets = [for subnet in aws_subnet.main : subnet.id]
  }
}

resource "aws_iam_role" "ecs_main" {
  name = "${var.namespace}-${var.project_name}-${var.environment}_ecs-main"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_main" {
  name = "${var.namespace}-${var.project_name}-${var.environment}_ecs-main"
  role = aws_iam_role.ecs_main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
