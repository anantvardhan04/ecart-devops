output "aws_ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}
output "aws_ecs_task_role" {
  value = (length(aws_iam_role.task_role) > 0 ? aws_iam_role.task_role.arn : "")
}
output "aws_ecs_role" {
  value = (length(aws_iam_role.execution_role) > 0 ? aws_iam_role.execution_role.name : "")
}
output "aws_ecs_task_definition_arn" {
  value = (length(aws_ecs_task_definition.this) > 0 ? aws_ecs_task_definition.this.arn : "")
}