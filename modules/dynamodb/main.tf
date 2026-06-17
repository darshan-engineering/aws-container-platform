module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.0"

  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "user_id"

  attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]

  tags = var.tags
}
