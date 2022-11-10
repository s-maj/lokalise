resource "aws_ecs_service" "service" {
  for_each = var.deployments

  name            = "${var.name}-${each.key}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task[each.key].arn
  desired_count   = var.desired_count
  tags            = var.tags

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
    base              = null
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group[each.key].arn
    container_name   = var.name
    container_port   = 8000
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.fargate.id]
  }
}

resource "aws_ecs_task_definition" "task" {
  for_each = var.deployments

  family                   = "${var.name}-${each.key}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task.arn
  tags                     = var.tags

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = each.value
      essential = true
      logConfiguration : {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${var.name}-${each.key}"
          awslogs-region        = var.region,
          awslogs-stream-prefix = aws_ecs_cluster.cluster.name
        }
      },
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ],
      environment = [
        {
          name  = "DEPLOYMENT_TYPE",
          value = each.key
        },
      ],
    }
  ])
}

resource "aws_lb_target_group" "target_group" {
  for_each = var.deployments

  name                 = "${var.name}-${each.key}"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 20
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.listener_http.arn

  action {
    type = "forward"

    forward {
      stickiness {
        enabled  = true
        duration = 3
      }

      dynamic "target_group" {
        for_each = var.deployments

        content {
          arn    = aws_lb_target_group.target_group[target_group.key].arn
          weight = target_group.key == var.active_deployment ? 100 : 0
        }
      }
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}