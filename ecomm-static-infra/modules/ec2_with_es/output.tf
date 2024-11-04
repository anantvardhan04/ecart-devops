output "private_ip_ec2_es" {
  description = "Public DNS names of the load balancers for each project"
  value = aws_instance.ecs-elasticsearch[0].private_ip
}
output "elastic_search_user_name" {
  value = "elastic"
}
output "elastic_search_password" {
  value = "asdf"
}
output "public_ip_ec2_es" {
  description = "Public DNS names of the load balancers for each project"
  value = aws_instance.ecs-elasticsearch[0].public_ip
}