output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb_table.dynamodb_table_arn
}

output "dynamodb_table_replica_stream_arns" {
  description = "Map of the Table replicas stream ARNs"
  value       = module.dynamodb_table.dynamodb_table_replica_stream_arns
}
