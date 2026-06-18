# ---------- VPC / SG -------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}


# ---------- ACM -------------
output "acm_certificate_status" {
  description = "Status of ACM Certificate"
  value       = module.acm.acm_certificate_status
}

output "acm_validation_route53_record_fqdns" {
  description = "Validation Route53 Record FQDNs"
  value       = module.acm.acm_validation_route53_record_fqdns
}


# ---------- ALB -------------

output "alb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

# -----------------------
# Target Group(s)

# output "target_groups" {
#   description = "Map of target groups created and their attributes"
#   value       = module.alb.target_groups
# }


# ---------- ECR -------------
output "repository_url" {
  value       = module.ecr.repository_url
  description = "The absolute URL pointing directly to the remote registry instance. (Format: [account_id].dkr.ecr.[region].amazonaws.com/[repo_name]). Use this value to direct your local `docker push/pull` commands."
}


# ---------- ECS -------------
output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

# output "service_name" {
#   description = "Name of the ECS service."
#   value       = module.ecs.service_name
# }

output "task_execution_role_arn" {
  description = "Task Execution Role ARN"
  value       = module.ecs.task_execution_role_arn
}


# ---------- Route53 -----------
output "route53_record_name" {
  value = module.route53.route53_record_name
}


# ---------- WAF -----------
output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.waf.web_acl_arn
}

# ---------- RDS -----------
output "db_instance_address" {
  description = "DB Connection Host"
  value       = module.rds.db_instance_address
}


# ---------- DynamoDB -----------
output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_arn
}
