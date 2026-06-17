output "ecs_sg_id" {
  description = "App Security Group ID"
  value       = module.ecs_sg.id
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = module.alb_sg.id
}

output "rds_sg_id" {
  description = "ALB Security Group ID"
  value       = module.rds_sg.id
}
