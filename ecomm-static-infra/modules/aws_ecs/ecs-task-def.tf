resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env}-${var.application_name}-${var.service_name}"
  execution_role_arn       = "${aws_iam_role.execution_role.arn}"
  task_role_arn            = "${aws_iam_role.task_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  container_definitions    = <<DEFINITION
[
   {
      "portMappings": [
        {
          "hostPort": ${var.container_port},
          "protocol": "tcp",
          "containerPort": ${var.container_port}
        }
      ],
      "environment": [
        {
          "name": "PORT",
          "value": "${var.container_port}"
        },
        {
          "name" : "APP_NAME",
          "value": "${var.service_name}"
        },
        {
          "name" : "env",
          "value": "${var.env}"
        },
        {
          "name" : "ELASTIC_SEARCH_DOMAIN",
          "value": "${var.elastic_search_domain}"
        },
        {
          "name" : "ELASTIC_SEARCH_PORT",
          "value": "${var.elastic_search_port}"
        },
        {
          "name" : "ELASTIC_SEARCH_USER_NAME",
          "value": "${var.elastic_search_user_name}"
        },
        {
          "name" : "ELASTIC_SEARCH_PASSWORD",
          "value": "${var.elastic_search_password}"
        },
        {
          "name": "HEALTHCHECK",
          "value": "${var.health_check}"
        }
      ],
      "memoryReservation" : ${var.memory_reserv},
      "cpu": 1536,
      "memory": 3072,
      "image": "${var.docker_image_url}",
      "name": "${var.env}-${var.service_name}",
      "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.env}-${var.service_name}-${var.cloudwatch_prefix}/var/log/docker",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
      }
    }
]
DEFINITION
}
