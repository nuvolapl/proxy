resource "aws_ecr_repository" "proxy" {
    name = "nuvola-proxy"
}

resource "aws_ecs_task_definition" "proxy" {
    family                   = "nuvola-proxy"

    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"

    cpu                      = "256"
    memory                   = "512"

    execution_role_arn       = "${var.iam-role-ecs-td-arn}"
    task_role_arn            = "${var.iam-role-ecs-td-arn}"

    container_definitions    = <<JSON
[
  {
    "name": "proxy",
    "image": "${aws_ecr_repository.proxy.repository_url}",
    "portMappings": [
      {
        "containerPort": 8888,
        "hostPort": 8888
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${var.cloudwatch-log-group-name}",
        "awslogs-stream-prefix": "proxy"
      }
    }
  }
]
JSON
}

data "aws_ecs_task_definition" "proxy" {
    task_definition = "${aws_ecs_task_definition.proxy.family}"
}

resource "aws_ecs_service" "proxy" {
    name            = "nuvola-proxy"
    cluster         = "${var.ecs-cluster-id}"

    launch_type     = "FARGATE"
    desired_count   = 1

    task_definition = "${aws_ecs_task_definition.proxy.family}:${max("${aws_ecs_task_definition.proxy.revision}", "${data.aws_ecs_task_definition.proxy.revision}")}"

    network_configuration {
        security_groups  = ["${aws_security_group.proxy.id}"]
        subnets          = ["${var.vpc-private-subnets}"]
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = "${aws_alb_target_group.proxy.arn}"
        container_name   = "proxy"
        container_port   = 8888
    }
}
