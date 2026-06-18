data "aws_availability_zones" "available" {}

locals {
  # ── Identity ──────────────────────────────────────────────────────────────
  project     = "my-demo-proj"
  environment = "dev"
  aws_region  = "ap-south-1"

  domain_name = "atkaridarshan.online"

  vpc_cidr       = "10.0.0.0/16"
  azs            = slice(data.aws_availability_zones.available.names, 0, 2)
  container_port = 80

  ecr_repository_name = "infra-validator-app"

  ecs_cluster_name         = "${local.project}-${local.environment}-ecs-cluster"
  container_image          = "${module.ecr.repository_url}:latest"
  desired                  = 2 # Keep desired '0' at  first run, push image to `ecr` then do it '2' and again `terraform apply`
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 4
  cpu                      = 256
  memory                   = 512
  enable_execute_command   = true

  db_instance_class   = local.environment == "dev" ? "db.t4g.micro" : "db.t4g.large"
  rds_db_name         = "${local.project}-${local.environment}-mysql"
  dynamodb_table_name = "${local.project}-${local.environment}-dynamodb"

  tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    Owner       = "Darshan Atkari"
  }
}
