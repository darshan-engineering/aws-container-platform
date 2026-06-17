output "ecs_task_role_arn" {
  value       = module.ecs_task_role.arn
  description = "ARN of ECS Task Role"
}

output "ecs_task_policy_arn" {
  value       = module.ecs_task_policy.arn
  description = "ARN of ECS Task Policy"
}
