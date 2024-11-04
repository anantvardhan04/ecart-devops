resource "aws_security_group" "ec2_es" {
  name   = "${var.env}-${var.application_name}-${var.service_name}-allow-es"
  vpc_id = "${var.vpc_id}"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}