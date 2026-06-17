variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "rds_db_name" {
  description = "Unique identifier for the RDS instance"
  type        = string
}

variable "db_sg_id" {
  description = "Security group ID to attach to the RDS instance"
  type        = string
}

variable "database_subnet_group" {
  description = "Name of the DB subnet group to deploy the RDS instance into"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs — used to create a public DB subnet group for testing"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Whether RDS should be publicly accessible (testing only)"
  type        = bool
  default     = false
}

variable "rds_db_password" {
  description = "RDS master password (sourced from Secrets Manager; never stored in state plaintext)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for Database"
  type        = string
}
