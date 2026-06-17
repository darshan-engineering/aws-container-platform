variable "route53_zone_id" {
  description = "Route 53 Zone ID. Created using Bootstrap dir"
  type        = string
}

variable "rds_db_password" {
  description = "RDS master password — provide via terraform.tfvars or TF_VAR_db_password (never commit)"
  type        = string
  sensitive   = true
}
