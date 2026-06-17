# Infrastructure Validator

Infrastructure Validator is a lightweight FastAPI application designed to validate and demonstrate the functionality of an AWS ECS Reference Architecture.

Rather than implementing business logic, this application focuses on verifying infrastructure integrations and providing visibility into the runtime environment. It serves as a validation layer for services deployed on Amazon ECS Fargate behind an Application Load Balancer (ALB).

The application exposes a web dashboard and API endpoints that validate connectivity with infrastructure services such as:

- Amazon ECS
- Amazon RDS
- Amazon DynamoDB
- Amazon S3
- Amazon EFS
- AWS Secrets Manager (future integration)

---

## Architecture

```text
Internet
   │
   ▼
Application Load Balancer
   │
   ▼
Amazon ECS (Fargate)
   │
   ├── ECS Metadata Endpoint
   ├── Amazon RDS
   ├── Amazon DynamoDB
   ├── Amazon S3
   ├── Amazon EFS
   └── AWS Secrets Manager
```

The application acts as an infrastructure validation dashboard, allowing operators to verify that all supporting AWS services are reachable and correctly configured.

---

## Features

### Infrastructure Dashboard

Provides a browser-based dashboard displaying:

- Application information
- ECS metadata
- ECS task information
- Availability Zone
- Task ARN
- Infrastructure health status
- Service integration status

---

### ECS Metadata Validation

Retrieves metadata from the ECS Task Metadata Endpoint.

Displays:

- Task ARN
- Task Definition Family
- Task Revision
- Availability Zone

Useful for validating:

- ECS deployment
- Task scheduling
- Multi-AZ distribution
- Rolling deployments

---

### Health Monitoring

Provides infrastructure health validation endpoints.

Checks:

- Application health
- Database connectivity
- Storage connectivity
- AWS service accessibility

---

### Amazon RDS Validation

Validates:

- Database reachability
- Authentication
- Network access
- Security Group configuration

Executes:

```sql
SELECT NOW();
```

to confirm successful connectivity.

---

### Amazon DynamoDB Validation

Validates:

- IAM permissions
- Table existence
- AWS SDK access

Checks table availability using:

```python
table.load()
```

---

### Amazon S3 Validation

Validates:

- Bucket accessibility
- IAM permissions
- AWS SDK connectivity

Checks bucket using:

```python
head_bucket()
```

---

### Amazon EFS Validation

Validates:

- EFS mount status
- Read access
- Write access

Creates and reads a test file from the mounted path.

---

## API Endpoints

### Dashboard

```http
GET /
```

Returns the Infrastructure Validation Dashboard.

---

### Health

```http
GET /health
```

Example:

```json
{
  "status": "healthy",
  "rds": {
    "status": "healthy"
  },
  "dynamodb": {
    "status": "healthy"
  },
  "s3": {
    "status": "healthy"
  },
  "efs": {
    "status": "healthy"
  }
}
```

---

### Application Information

```http
GET /info
```

Example:

```json
{
  "application": "Infrastructure Validator",
  "version": "1.0.0",
  "region": "ap-south-1",
  "ecs": {
    "task_arn": "...",
    "availability_zone": "ap-south-1a"
  }
}
```

---

### Debug Endpoint

```http
GET /debug
```

Returns detailed diagnostic information for all configured integrations.

---

### Database Validation

```http
GET /db
```

Validates:

- RDS endpoint
- Security Groups
- Database authentication
- Database availability

---

### DynamoDB Validation

```http
GET /dynamodb
```

Validates:

- Table existence
- IAM permissions
- SDK connectivity

---

### S3 Validation

```http
GET /s3
```

Validates:

- Bucket access
- IAM permissions

---

### EFS Validation

```http
GET /efs
```

Validates:

- EFS mount path
- Read operations
- Write operations

---

## Project Structure

```text
infra-validator
├── app
│   ├── api
│   │   ├── __init__.py
│   │   └── routes.py
│   │
│   ├── core
│   │   ├── __init__.py
│   │   ├── config.py
│   │   └── metadata.py
│   │
│   ├── services
│   │   ├── __init__.py
│   │   ├── health.py
│   │   ├── rds.py
│   │   ├── dynamodb.py
│   │   ├── s3.py
│   │   └── efs.py
│   │
│   ├── static
│   │   └── .gitkeep
│   │
│   ├── templates
│   │   └── index.html
│   │
│   └── main.py
│
├── requirements.txt
├── Dockerfile
├── .dockerignore
└── README.md
```

---

## Environment Variables

### Application

| Variable | Description |
|-----------|-------------|
| APP_NAME | Application Name |
| APP_VERSION | Application Version |
| AWS_REGION | AWS Region |

Example:

```env
APP_NAME=Infrastructure Validator
APP_VERSION=1.0.0
AWS_REGION=ap-south-1
```

---

### RDS

| Variable | Description |
|-----------|-------------|
| DB_HOST | Database Endpoint |
| DB_PORT | Database Port |
| DB_NAME | Database Name |
| DB_USER | Database Username |
| DB_PASSWORD | Database Password |

Example:

```env
DB_HOST=mydb.xxxxx.ap-south-1.rds.amazonaws.com
DB_PORT=5432
DB_NAME=appdb
DB_USER=appuser
DB_PASSWORD=password
```

---

### DynamoDB

| Variable | Description |
|-----------|-------------|
| DYNAMODB_TABLE | DynamoDB Table Name |

Example:

```env
DYNAMODB_TABLE=infra-validator
```

---

### S3

| Variable | Description |
|-----------|-------------|
| S3_BUCKET | S3 Bucket Name |

Example:

```env
S3_BUCKET=infra-validator-bucket
```

---

### EFS

| Variable | Description |
|-----------|-------------|
| EFS_MOUNT_PATH | Mounted EFS Path |

Example:

```env
EFS_MOUNT_PATH=/data
```

---

## Local Development

### Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Set Environment Variables

```bash
export DB_HOST=my-demo-proj-dev-mysql.czq28eieeksn.ap-south-1.rds.amazonaws.com
export DB_PORT=3306
export DB_NAME=mydb
export DB_USER=myuser
export DB_PASSWORD=<your-rds-password>
export DYNAMODB_TABLE=my-demo-proj-dev-dynamodb
export AWS_REGION=ap-south-1
```

> **Getting the RDS password:** The password is stored in AWS Secrets Manager (managed by RDS). Retrieve it with:
> ```bash
> aws secretsmanager get-secret-value \
>   --secret-id <secret-arn-from-terraform-output> \
>   --region ap-south-1 \
>   --query SecretString --output text
> ```
> The secret ARN is in the Terraform output `db_instance_master_user_secret_arn`.

> **DynamoDB credentials:** DynamoDB uses IAM, not a username/password. When running locally, your AWS CLI credentials (`~/.aws/credentials`) are used automatically via boto3. Make sure your IAM user/role has `dynamodb:DescribeTable` permission on the table.

### Run Application

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

Open `http://localhost:8080`

---

## Docker

### Build Image

```bash
docker build -t infra-validator .
```

### Run Container

```bash
docker run -p 8080:80 \
  -e DB_HOST=my-demo-proj-dev-mysql.czq28eieeksn.ap-south-1.rds.amazonaws.com \
  -e DB_PORT=3306 \
  -e DB_NAME=mydb \
  -e DB_USER=myuser \
  -e DB_PASSWORD=<your-rds-password> \
  -e DYNAMODB_TABLE=my-demo-proj-dev-dynamodb \
  -e AWS_REGION=ap-south-1 \
  -e AWS_ACCESS_KEY_ID=<your-access-key> \
  -e AWS_SECRET_ACCESS_KEY=<your-secret-key> \
  infra-validator
```

> **Note on Docker + DynamoDB:** Docker containers don't inherit your host AWS credentials. You must pass `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` explicitly, or mount your credentials file:
> ```bash
> docker run -p 8080:80 \
>   -v ~/.aws:/root/.aws:ro \
>   -e AWS_REGION=ap-south-1 \
>   ... other env vars ...
>   infra-validator
> ```

Open `http://localhost:8080`

---

## RDS Public Access (Testing Only)

By default RDS is placed in private database subnets and is not reachable from outside the VPC. To connect directly from your machine for testing, the Terraform config supports placing RDS in public subnets with `publicly_accessible = true`.

This is controlled in `environment/dev/main.tf`:

```hcl
module "rds" {
  ...
  # Testing only — remove these two lines for production
  publicly_accessible = true
  public_subnet_ids   = module.vpc.public_subnets
}
```

**Revert for production** by removing those two lines. The defaults are `publicly_accessible = false` with RDS back in the private database subnets.

---

## ECS Deployment

The application is designed to run on:

- Amazon ECS Fargate
- Application Load Balancer
- Private or Public Subnets
- CloudWatch Logging

Container Port:

```text
80
```

Health Endpoint:

```text
/health
```

Recommended ALB Health Check:

```text
Path: /health
Protocol: HTTP
Success Codes: 200
```

---

## Future Enhancements

Planned improvements:

- Secrets Manager Integration
- RDS Connection Pooling
- OpenTelemetry Tracing
- AWS X-Ray Integration
- CloudWatch Custom Metrics
- S3 Object Operations
- DynamoDB CRUD Operations
- EFS File Browser
- Dark/Light Theme Support
- Infrastructure Metrics Dashboard

---

## Purpose

This application is intentionally focused on infrastructure validation rather than business functionality.

Its primary objective is to demonstrate and validate:

- ECS Deployments
- ALB Integration
- IAM Permissions
- RDS Connectivity
- DynamoDB Connectivity
- S3 Connectivity
- EFS Connectivity
- Cloud-Native Operational Patterns

within a production-style AWS ECS Reference Architecture.
