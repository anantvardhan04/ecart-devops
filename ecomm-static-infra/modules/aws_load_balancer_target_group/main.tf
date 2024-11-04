locals {
  open_port     = var.public_security_group_port
  target_groups = ["primary", "secondary"]
  hosts_name    = ["*.yourdomain.com"] #example : fill your information
}

resource "aws_lb" "load_balancer" {
  name               = "${var.env}-${var.application_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = [for subnet in var.aws_public_subnet_id : subnet]

  enable_deletion_protection = false

  tags = {
    Environment = "${var.env}"
  }
}


resource "aws_lb_target_group" "this" {
  count = length(local.target_groups)
  name  = "${var.env}-${var.application_name}-tg-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_id
  target_type = "ip"

  health_check {
    path                = "/product/health-check/"
    enabled             = true
    healthy_threshold   = 2
    interval            = 5
    timeout             = 2
    unhealthy_threshold = 3
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.0.arn
  }
}