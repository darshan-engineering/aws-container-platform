module "vpc" {
  source   = "../../modules/vpc"
  vpc_cidr = local.vpc_cidr
  azs      = local.azs
  tags     = local.tags
}

module "sg" {
  source         = "../../modules/sg"
  vpc_id         = module.vpc.vpc_id
  container_port = local.container_port
  tags           = local.tags
}

module "acm" {
  source          = "../../modules/acm"
  domain_name     = local.domain_name
  route53_zone_id = var.route53_zone_id
  tags            = local.tags
}

module "alb" {
  source              = "../../modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  alb_sg_id           = [module.sg.alb_sg_id]
  container_port      = local.container_port
  acm_certificate_arn = module.acm.certificate_arn
  tags                = local.tags
}

module "ecr" {
  source              = "../../modules/ecr"
  ecr_repository_name = local.ecr_repository_name
  tags                = local.tags
}

module "ecs" {
  source                   = "../../modules/ecs"
  name                     = local.ecs_cluster_name
  vpc_id                   = module.vpc.vpc_id
  private_subnets          = module.vpc.private_subnets
  container_image          = local.container_image
  container_port           = local.container_port
  ecs_security_group_id    = module.sg.ecs_sg_id
  autoscaling_max_capacity = local.autoscaling_max_capacity
  autoscaling_min_capacity = local.autoscaling_min_capacity
  desired_count            = local.desired
  memory                   = local.memory
  cpu                      = local.cpu
  enable_execute_command   = local.enable_execute_command
  target_group_arn         = module.alb.target_groups["app"].arn
  ecs_task_role_arn        = module.iam.ecs_task_role_arn

  rds_secret_arn      = module.rds.db_secret_arn
  rds_db_host         = module.rds.db_instance_address
  rds_db_name         = "mydb"
  rds_db_user         = "myuser"
  aws_region          = local.aws_region
  dynamodb_table_name = local.dynamodb_table_name

  tags = local.tags
}

module "route53" {
  source          = "../../modules/route53"
  domain_name     = local.domain_name
  route53_zone_id = var.route53_zone_id
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
  tags            = local.tags
}

module "waf" {
  source  = "../../modules/waf"
  name    = "${local.tags.Project}-${local.tags.Environment}"
  alb_arn = module.alb.alb_arn
  tags    = local.tags
}

module "iam" {
  source             = "../../modules/iam"
  db_secret_arn      = module.rds.db_secret_arn
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  tags               = local.tags
}

module "rds" {
  source                = "../../modules/rds"
  rds_db_name           = local.rds_db_name
  rds_db_password       = var.rds_db_password
  db_instance_class     = local.db_instance_class
  database_subnet_group = module.vpc.database_subnet_group
  db_sg_id              = module.sg.rds_sg_id
  tags                  = local.tags
  publicly_accessible   = false
}

module "dynamodb" {
  source              = "../../modules/dynamodb"
  dynamodb_table_name = local.dynamodb_table_name
  tags                = local.tags
}
