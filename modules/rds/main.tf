# Create a dedicated subnet group in public subnets when testing with public access
resource "aws_db_subnet_group" "public" {
  count       = length(var.public_subnet_ids) > 0 ? 1 : 0
  name        = "${var.rds_db_name}-public-subnet-group"
  subnet_ids  = var.public_subnet_ids
  description = "Public subnet group for RDS testing"
  tags        = var.tags
}

module "mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0.0"


  identifier = var.rds_db_name

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  publicly_accessible = var.publicly_accessible

  db_name  = "mydb"
  username = "myuser"
  port     = 3306

  manage_master_user_password = true
  password_wo                 = var.rds_db_password
  password_wo_version         = 1

  multi_az = var.tags.Environment == "dev" ? false : true
  db_subnet_group_name = length(var.public_subnet_ids) > 0 ? aws_db_subnet_group.public[0].name : var.database_subnet_group
  vpc_security_group_ids = [var.db_sg_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true

  skip_final_snapshot = true
  deletion_protection = false # true in production

  create_monitoring_role = true
  monitoring_interval    = 60

  tags = var.tags
  db_instance_tags = {
    "Sensitive" = "high"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
  cloudwatch_log_group_tags = {
    "Sensitive" = "high"
  }
}
