output "load_balancer_security_group_id" {
  value = aws_security_group.alb.id
//  value = { for p in sort(keys(aws_instance.aws_ec_2.*.id)) : p => module.elb_http[p].this_elb_dns_name }
}
output "target_group_arn" {
  value = aws_lb_target_group.this.*.arn
//  value = { for p in sort(keys(aws_instance.aws_ec_2.*.id)) : p => module.elb_http[p].this_elb_dns_name }
}
output "target_groups_name" {
  value = aws_lb_target_group.this.*.name
//  value = { for p in sort(keys(aws_instance.aws_ec_2.*.id)) : p => module.elb_http[p].this_elb_dns_name }
}
output "load_balancer_dns_name" {
  value = aws_lb.load_balancer.dns_name
}
output "load_balancer_listener_arn" {
  value = aws_lb_listener.this.arn
}