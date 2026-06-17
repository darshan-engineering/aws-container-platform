variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the DB password"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table the EC2 instances can access for health-check"
  type        = string
}
