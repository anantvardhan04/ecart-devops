resource "aws_security_group" "alb" {
  name   = "${var.application_name}-allow-http"
  vpc_id = "${var.aws_vpc_id}"

  dynamic "ingress" {
    for_each = local.open_port
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.application_name}-allow-http"
  }
}