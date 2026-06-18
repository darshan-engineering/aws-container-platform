# Infrastructure Validator

A lightweight FastAPI application that validates AWS infrastructure connectivity and serves as the reference workload for this ECS platform. It exposes a web dashboard and API endpoints that confirm live connectivity to RDS, DynamoDB, and the ECS runtime environment.

---

## What It Does

- Displays ECS task metadata (task ARN, family, revision, availability zone)
- Tests RDS MySQL connectivity by running `SELECT NOW()`
- Tests DynamoDB connectivity by calling `DescribeTable`
- Exposes a `/health` endpoint used by the ALB health check

---

## API Endpoints

| Endpoint | Description |
|---|---|
| `GET /` | HTML dashboard |
| `GET /health` | Health status of all integrations |
| `GET /info` | App version, region, ECS metadata |
| `GET /debug` | Full diagnostic dump (ECS + RDS + DynamoDB) |
| `GET /db` | RDS connectivity check |
| `GET /dynamodb` | DynamoDB connectivity check |

---

## Project Structure

```
app/infra-validator/
├── app/
│   ├── api/routes.py          # All HTTP endpoints
│   ├── core/
│   │   ├── config.py          # Settings from environment variables
│   │   └── metadata.py        # ECS task metadata fetch
│   ├── services/
│   │   ├── health.py          # Aggregates RDS + DynamoDB checks
│   │   ├── rds.py             # PyMySQL connectivity check
│   │   └── dynamodb.py        # boto3 DynamoDB check
│   ├── templates/index.html   # Dashboard UI
│   └── main.py                # FastAPI app entrypoint
├── Dockerfile
├── requirements.txt
└── .dockerignore
```

---

## Environment Variables

All configuration is read from environment variables. In ECS these are set by the task definition — no manual configuration needed.

| Variable | Description |
|---|---|
| `APP_NAME` | Application name |
| `APP_VERSION` | Application version |
| `AWS_REGION` | AWS region (e.g. `ap-south-1`) |
| `DB_HOST` | RDS endpoint |
| `DB_PORT` | RDS port (default `3306`) |
| `DB_NAME` | Database name (`mydb`) |
| `DB_USER` | Database username (`myuser`) |
| `DB_PASSWORD` | Database password — injected from Secrets Manager by ECS |
| `DYNAMODB_TABLE` | DynamoDB table name |

---

## Local Development

```bash
cd app/infra-validator
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Set environment variables:

```bash
export DB_HOST=my-demo-proj-dev-mysql.czq28eieeksn.ap-south-1.rds.amazonaws.com
export DB_PORT=3306
export DB_NAME=mydb
export DB_USER=myuser
export DB_PASSWORD=<retrieve from Secrets Manager — see below>
export DYNAMODB_TABLE=my-demo-proj-dev-dynamodb
export AWS_REGION=ap-south-1
```

Retrieve the RDS password from Secrets Manager:

```bash
aws secretsmanager get-secret-value \
  --secret-id <secret-arn-from-terraform-output> \
  --region ap-south-1 \
  --query SecretString --output text
```

Run:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

Open `http://localhost:8080`

> DynamoDB uses IAM, not a username/password. Locally, boto3 picks up your AWS CLI credentials (`~/.aws/credentials`) automatically. Ensure your IAM user has `dynamodb:DescribeTable` on the table.

---

## Docker

Build and run locally:

```bash
docker build -t infra-validator-app ./app/infra-validator

docker run -p 8080:80 \
  -e DB_HOST=my-demo-proj-dev-mysql.czq28eieeksn.ap-south-1.rds.amazonaws.com \
  -e DB_PORT=3306 \
  -e DB_NAME=mydb \
  -e DB_USER=myuser \
  -e DB_PASSWORD=<password> \
  -e DYNAMODB_TABLE=my-demo-proj-dev-dynamodb \
  -e AWS_REGION=ap-south-1 \
  -v ~/.aws:/root/.aws:ro \
  infra-validator-app
```

Mounting `~/.aws` gives the container your local credentials for DynamoDB access.
