# RDS — Relational Database Service

This module provisions a MySQL 8.0 RDS instance using [`terraform-aws-modules/rds/aws`](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest) (v7). The master password is fully managed by AWS Secrets Manager — no plaintext passwords are stored in Terraform state.

---

## Instance Configuration

| Setting | Value |
|---|---|
| Engine | MySQL 8.0 |
| Instance class | `db.t4g.micro` (dev) / `db.t4g.large` (prod) |
| Storage | 20 GiB, auto-scales up to 100 GiB |
| Multi-AZ | No (dev) / Yes (prod) |
| Publicly accessible | No |
| Deletion protection | No (dev) — enable in production |

The instance class is selected automatically based on the environment:

```hcl
db_instance_class = local.environment == "dev" ? "db.t4g.micro" : "db.t4g.large"
```

---

## Password Management — AWS Secrets Manager

```hcl
manage_master_user_password = true
password_wo                 = var.rds_db_password
password_wo_version         = 1
```

With `manage_master_user_password = true`, AWS takes full ownership of the master password:

1. RDS generates a strong random password and stores it in **AWS Secrets Manager** automatically.
2. The `password_wo` value you provide is used only as the **initial seed** during creation — it is not stored in Terraform state after that.
3. AWS rotates and manages the secret going forward. The secret ARN is exposed as a Terraform output.

The secret is stored as a JSON blob:

```json
{
  "username": "myuser",
  "password": "<aws-managed-password>",
  "engine": "mysql",
  "host": "<rds-endpoint>",
  "port": 3306,
  "dbInstanceIdentifier": "<identifier>"
}
```

### Retrieving the password locally

```bash
aws secretsmanager get-secret-value \
  --secret-id <secret-arn> \
  --region ap-south-1 \
  --query SecretString \
  --output text
```

The secret ARN is in the Terraform output `db_instance_address` — check `terraform output` after applying.

---

## How ECS Reads the Password

The ECS task definition injects the password directly from Secrets Manager at container startup — no application code changes needed:

```hcl
secrets = [
  {
    name      = "DB_PASSWORD"
    valueFrom = "${module.rds.db_secret_arn}:password::"
  }
]
```

The `:password::` suffix extracts only the `password` field from the JSON blob. The ECS task execution role must have `secretsmanager:GetSecretValue` permission on the secret ARN for this to work (configured in the ECS module via `task_exec_iam_statements`).

The container receives `DB_PASSWORD` as a plain environment variable — the application connects using it normally via PyMySQL.

---

## Networking & Security

```hcl
db_subnet_group_name   = var.database_subnet_group   # dedicated DB subnets
vpc_security_group_ids = [var.db_sg_id]
publicly_accessible    = false
```

- RDS is placed in **dedicated database subnets** (separate from the private app subnets).
- The RDS security group allows inbound on port `3306` **only from the ECS security group** — not from the internet.
- `publicly_accessible = false` ensures no public endpoint is assigned.

---

## Monitoring

```hcl
enabled_cloudwatch_logs_exports = ["general"]
create_cloudwatch_log_group     = true
create_monitoring_role          = true
monitoring_interval             = 60
```

- General query logs are exported to CloudWatch Logs.
- Enhanced Monitoring is enabled at 60-second granularity, providing OS-level metrics (CPU, memory, I/O) beyond what standard CloudWatch provides.

---

## Backup & Maintenance

| Setting | Value |
|---|---|
| Backup window | 03:00–06:00 UTC |
| Maintenance window | Monday 00:00–03:00 UTC |
| Skip final snapshot | Yes (dev) — set to `false` in production |

---

## Outputs

| Output | Description |
|---|---|
| `db_instance_address` | RDS hostname for `DB_HOST` |
| `db_secret_arn` | Secrets Manager ARN passed to ECS |
| `db_instance_endpoint` | Full `host:port` connection string |
