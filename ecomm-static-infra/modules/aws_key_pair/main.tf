resource "aws_key_pair" "developer_terraform_key" {
  key_name   = "${var.env}_ssh_key"
  public_key = file(var.public_file_name)
}