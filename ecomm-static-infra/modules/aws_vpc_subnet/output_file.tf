output "vpc_id" {
  description = "Vpc id of this project"
  value = aws_vpc.this.id
}
output "public_subnet_id" {
  description = "Public Subnet ids"
  value = aws_subnet.public.*.id
}

output "private_subnet_id" {
  description = "Private Subnet Id"
  value = aws_subnet.private.*.id
}