module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0.0"

  name        = "${var.tags.Project}-${var.tags.Environment}-ecs-sg"
  description = "Security group for ${var.tags.Project}-${var.tags.Environment} EC2 app instances"
  vpc_id      = var.vpc_id

  ingress_rules = {
    # test = {
    #   from_port   = var.container_port
    #   to_port     = var.container_port
    #   ip_protocol = "tcp"
    #   cidr_ipv4   = "0.0.0.0/0"
    #   description = "HTTP from ALB Only"
    # }

    http = {
      from_port                    = var.container_port
      to_port                      = var.container_port
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb_sg.id # only allow traffic from the ALB security group
      description                  = "HTTP from ALB Only"
    }

    self-all = {
      ip_protocol                  = "-1" # -1 means all protocols
      referenced_security_group_id = "self"
      description                  = "All traffic from members of this SG"
    }
  }

  egress_rules = {
    # Egress Output to Anywhere
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = var.tags
}


module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0.0"

  name        = "${var.tags.Project}-${var.tags.Environment}-alb-sg"
  description = "Security group for ${var.tags.Project}-${var.tags.Environment} EC2 app instances"
  vpc_id      = var.vpc_id


  ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }

    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  egress_rules = {
    # Egress Output to Anywhere
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = var.tags
}


module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0.0"

  name        = "${var.tags.Project}-${var.tags.Environment}-rds-sg"
  description = "Security group for ${var.tags.Project}-${var.tags.Environment} RDS instances"
  vpc_id      = var.vpc_id


  ingress_rules = {
    http = {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.ecs_sg.id # only allow traffic from the app security group
      description                  = "HTTP from Apps Only"
    }

    self-all = {
      ip_protocol                  = "-1" # -1 means all protocols
      referenced_security_group_id = "self"
      description                  = "All traffic from members of this SG"
    }
  }

  egress_rules = {
    # Egress Output to Anywhere
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = var.tags
}
