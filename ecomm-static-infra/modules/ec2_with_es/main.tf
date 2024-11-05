
# User data template that specifies how to bootstrap each instance
data "template_file" "user_data" {
  template = file("${path.module}/user-data.tpl")
}

resource "aws_eip" "ec2-eip" {
  instance = aws_instance.ecs-elasticsearch.0.id
  domain   = "vpc"
}

resource "aws_instance" "ecs-elasticsearch" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  count = var.instance_count

  availability_zone      = element(split(",", var.availability_zones), count.index)
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = ["${aws_security_group.ec2_es.id}"]

  user_data = data.template_file.user_data.rendered
  key_name  = var.key_name
  tags = {
    Name = "${var.env}-${var.application_name}-${var.service_name}"
  }
  root_block_device {
    volume_size = 20
  }
}
