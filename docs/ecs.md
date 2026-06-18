# ECS — Elastic Container Service

This module provisions an ECS cluster and a Fargate service using [`terraform-aws-modules/ecs/aws`](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest) (v7). It covers the cluster, task definition, service, IAM roles, ALB integration, and auto-scaling.

---

## Cluster & Capacity Providers

```hcl
cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

default_capacity_provider_strategy = {
  FARGATE = { weight = 100 }
}
```

The cluster supports both `FARGATE` (on-demand) and `FARGATE_SPOT` (interruptible, ~70% cheaper). The default strategy sends 100% of tasks to on-demand Fargate. To split traffic and reduce cost, adjust weights:

```hcl
FARGATE      = { weight = 2 }   # 2 out of 3 tasks on-demand
FARGATE_SPOT = { weight = 1 }   # 1 out of 3 on spot
```

---

## IAM Roles

Two IAM roles are involved in every ECS task.

### Task Execution Role (auto-created by the module)

Used by the **ECS agent** — not your application code — to:
- Pull the container image from ECR
- Write logs to CloudWatch Logs
- **Fetch secrets from Secrets Manager** at container startup

The module creates this role automatically and attaches `AmazonECSTaskExecutionRolePolicy`. Additional permissions (like Secrets Manager access) are injected via `task_exec_iam_statements`:

```hcl
task_exec_iam_statements = [
  {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.rds_secret_arn]
  }
]
```

> This is required when using the `secrets` block in container definitions. Without it, tasks fail at startup with `AccessDeniedException` before any logs are written.

### Task Role (custom, passed via `tasks_iam_role_arn`)

Used by your **running application code** for AWS API calls at runtime (DynamoDB, Secrets Manager reads from the app, etc.).

Since the module always creates its own task role by default, you must explicitly disable that and pass your own:

```hcl
create_tasks_iam_role = false
tasks_iam_role_arn    = var.ecs_task_role_arn
```

Without `create_tasks_iam_role = false`, the module ignores `tasks_iam_role_arn` and uses its auto-generated role, which only has SSM exec permissions — your app will get `AccessDeniedException` on DynamoDB and Secrets Manager calls.

The task role policy (defined in the `iam` module) grants:
- `secretsmanager:GetSecretValue` — read the RDS password secret
- `dynamodb:DescribeTable`, `GetItem`, `PutItem`, `UpdateItem`, `DeleteItem`, `Query`, `Scan` — full table access

---

## Secrets Manager Integration

The RDS master password is managed by AWS Secrets Manager (see [rds.md](./rds.md)). It is injected into the container as an environment variable at task startup:

```hcl
secrets = [
  {
    name      = "DB_PASSWORD"
    valueFrom = "${var.rds_secret_arn}:password::"
  }
]
```

The `:password::` suffix extracts only the `password` field from the Secrets Manager JSON blob (`{"username":"...","password":"..."}`). Without the suffix, the entire JSON string would be set as the environment variable value.

The ECS agent (task execution role) fetches the secret before the container starts. The application reads it as a normal env var — no AWS SDK calls needed from the app for the password.

---

## Task Definition

```hcl
container_definitions = {
  app = {
    cpu    = var.cpu       # 256 vCPU units
    memory = var.memory    # 512 MiB
    image  = var.container_image   # ECR image URI
    essential = true

    portMappings = [{ containerPort = 80, protocol = "tcp" }]

    environment = [
      { name = "DB_HOST",         value = var.rds_db_host },
      { name = "DB_NAME",         value = var.rds_db_name },
      { name = "DB_USER",         value = var.rds_db_user },
      { name = "DYNAMODB_TABLE",  value = var.dynamodb_table_name },
      { name = "AWS_REGION",      value = var.aws_region },
      ...
    ]

    secrets = [
      { name = "DB_PASSWORD", valueFrom = "${var.rds_secret_arn}:password::" }
    ]

    enable_cloudwatch_logging = true
    readonlyRootFilesystem    = false
  }
}
```

Key points:
- **`essential = true`** — if this container exits, the entire task is stopped and replaced.
- **`portMappings`** uses camelCase keys because the ECS module passes these directly to the AWS task definition JSON spec.
- **`enable_cloudwatch_logging = true`** — the module automatically creates a CloudWatch log group and configures the `awslogs` driver. No manual log configuration needed.
- **CPU/memory** are set at both task and container level. For a single-container task they must match.

### Valid Fargate CPU / Memory combinations

| CPU (units) | Memory options (MiB) |
|---|---|
| 256 | 512, 1024, 2048 |
| 512 | 1024 – 4096 (in 1024 increments) |
| 1024 | 2048 – 8192 (in 1024 increments) |
| 2048 | 4096 – 16384 (in 1024 increments) |
| 4096 | 8192 – 30720 (in 1024 increments) |

---

## How ECS Tasks Connect to the ALB

### Target Group — `target_type = "ip"`

```hcl
target_groups = {
  app = {
    target_type       = "ip"
    create_attachment = false
  }
}
```

Fargate tasks must use `ip` target type — each task gets its own ENI and private IP directly in the subnet, with no EC2 instance backing it. `create_attachment = false` tells the ALB module not to attach anything; the ECS service registers tasks automatically.

### ECS Service — `load_balancer` block

```hcl
load_balancer = {
  service = {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = var.container_port
  }
}
```

When a task starts, ECS registers its container IP + port with the target group. When it stops, ECS deregisters it.

### Health Check Grace Period

```hcl
health_check_grace_period_seconds = 60
```

Prevents ECS from killing tasks before the application finishes starting up. Without this, the ALB may mark a task unhealthy during initialization and trigger a restart loop.

---

## Networking

```hcl
subnet_ids         = var.private_subnets
assign_public_ip   = false
security_group_ids = [var.ecs_security_group_id]
```

Tasks run in **private subnets** with no public IP. Inbound traffic arrives only through the ALB. The ECS security group allows inbound on `container_port` only from the ALB security group. Outbound internet access (ECR pulls, CloudWatch, Secrets Manager) routes through the NAT Gateway.

---

## Auto-scaling

```hcl
autoscaling_min_capacity = 1
autoscaling_max_capacity = 4
```

| Policy | Metric | Target |
|---|---|---|
| `cpu` | `ECSServiceAverageCPUUtilization` | 70% |
| `memory` | `ECSServiceAverageMemoryUtilization` | 80% |

Target tracking scales out when the metric exceeds the target and scales in conservatively (with a cooldown) when it drops.

---

## ECS Exec

```hcl
enable_execute_command = true
```

Opens an interactive shell into a running container without SSH:

```bash
aws ecs execute-command \
  --cluster <cluster-name> \
  --task <task-id> \
  --container app \
  --interactive \
  --command "/bin/sh"
```

Requires `ssmmessages` permissions on the task role, which the module adds automatically when `enable_execute_command = true`.

---

## Deploying a New Image

ECS does **not** automatically detect when a new image is pushed to ECR. Running tasks keep using the image they pulled at startup. After pushing a new image, force a redeployment:

```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service app \
  --force-new-deployment \
  --region ap-south-1
```

This performs a rolling replacement — new tasks are started with the latest image, old tasks are drained and stopped.

> In future releases this will be automated via a CI/CD pipeline (GitHub Actions) that builds, pushes, and triggers the redeployment on every merge to `main`.
