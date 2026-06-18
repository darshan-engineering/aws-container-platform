variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "name" {
  description = "Base name used for ECS cluster, service and related resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS tasks will run."
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs used by ECS tasks."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks."
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN used by the ECS service."
  type        = string
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 80
}

variable "container_image" {
  description = "ECR image URI used by the ECS task."
  type        = string
}

variable "cpu" {
  description = "Task CPU units. Example: 256, 512, 1024."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Number of running ECS tasks."
  type        = number
  default     = 2
}

variable "enable_execute_command" {
  description = "Enable ECS Exec support."
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  type        = number
  default     = 2
  description = "Minimum number of ECS tasks."
}

variable "autoscaling_max_capacity" {
  type        = number
  default     = 5
  description = "Maximum number of ECS tasks."
}

variable "ecs_task_role_arn" {
  type        = string
  description = "ECS Task Role ARN"
}

variable "aws_region" {
  type = string
}

variable "rds_db_host" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_db_user" {
  type        = string
  description = "ECS Task Role ARN"
}

variable "dynamodb_table_name" {
  type = string
}

variable "rds_secret_arn" {
  description = "RDS Password Secred ARN"
  type = string
}
