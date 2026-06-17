output "db_secret_arn" {
  value = module.mysql.db_instance_master_user_secret_arn
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.mysql.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.mysql.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.mysql.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.mysql.db_instance_endpoint
}

output "db_instance_engine" {
  description = "The database engine"
  value       = module.mysql.db_instance_engine
}

output "db_instance_engine_version_actual" {
  description = "The running version of the database"
  value       = module.mysql.db_instance_engine_version_actual
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.mysql.db_instance_hosted_zone_id
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = module.mysql.db_instance_identifier
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.mysql.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.mysql.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = module.mysql.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.mysql.db_instance_username
  sensitive   = true
}

output "db_instance_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.mysql.db_instance_cloudwatch_log_groups
}

# output "db_instance_master_user_secret_arn" {
#   description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
#   value       = module.mysql.db_instance_master_user_secret_arn
# }

# output "db_instance_upgrade_rollout_order" {
#   description = "Order in which the instances are upgraded (first, second, last)"
#   value       = module.mysql.db_instance_upgrade_rollout_order
# }
