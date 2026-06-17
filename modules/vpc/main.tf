module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  name = "${var.tags.Project}-${var.tags.Environment}-vpc"
  cidr = var.vpc_cidr

  azs              = var.azs
  private_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 8)]

  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
  # public_subnet_names omitted to show default name generation for all 2 subnets
  database_subnet_names = ["DB Subnet One", "DB Subnet Two"]

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_nat_gateway = false
  # single_nat_gateway = true

  enable_vpn_gateway = false

  tags = var.tags
}
