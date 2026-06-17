variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}
