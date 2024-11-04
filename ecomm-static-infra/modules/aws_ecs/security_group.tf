resource "aws_security_group" "ecs" {
  name   = "${var.env}-${var.service_name}-allow-ecs"
  vpc_id = "${var.aws_vpc_id}"

  ingress {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    security_groups = ["${var.load_balancer_security_group_id}"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
