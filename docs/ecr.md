# ECR — Elastic Container Registry

This module provisions a private ECR repository using [`terraform-aws-modules/ecr/aws`](https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest). It handles image storage, access control, tag mutability, lifecycle cleanup, and vulnerability scanning.

---

## Accepted Image Types

ECR is an OCI-compatible registry. It accepts:

- **Docker images** — standard `docker build` / `docker push` workflow
- **OCI images** — built with tools like `buildah` or `podman`
- **Multi-arch manifests** — manifest lists targeting `linux/amd64`, `linux/arm64`, etc.

Images are referenced by their full URI:

```
<account_id>.dkr.ecr.<region>.amazonaws.com/<repo_name>:<tag>
```

The repository URL is available as a Terraform output:

```
repository_url = "590183956795.dkr.ecr.ap-south-1.amazonaws.com/infra-validator-app"
```

---

## Pushing Images

Authenticate Docker to ECR, then build, tag and push:

```bash
# Authenticate
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin \
    590183956795.dkr.ecr.ap-south-1.amazonaws.com

# Build
docker build -t infra-validator-app ./app/infra-validator

# Tag
docker tag infra-validator-app:latest \
  590183956795.dkr.ecr.ap-south-1.amazonaws.com/infra-validator-app:latest

# Push
docker push 590183956795.dkr.ecr.ap-south-1.amazonaws.com/infra-validator-app:latest
```

> After pushing, ECS does **not** pick up the new image automatically. You must force a redeployment — see [ecs.md](./ecs.md#deploying-a-new-image).

---

## Tag Mutability

The repository uses `IMMUTABLE_WITH_EXCLUSION` — a middle ground between fully immutable and fully mutable:

- **By default**, all tags are immutable. A tag like `v1.0.0` cannot be overwritten once pushed, preventing accidental production overwrites.
- **Excluded tags** (mutable, allowed to be overwritten):

```hcl
repository_image_tag_mutability_exclusion_filter = [
  { filter = "latest*", filter_type = "WILDCARD" },
  { filter = "dev-*",   filter_type = "WILDCARD" },
  { filter = "qa-*",    filter_type = "WILDCARD" },
]
```

This means `latest`, `dev-build-123`, `qa-rc1` can be re-pushed freely, while versioned tags like `v2.1.0` are locked once pushed.

---

## Lifecycle Policy

Lifecycle rules keep the repository clean and control storage costs.

### Rule 1 — Expire untagged images after 7 days (Priority 1)

When a mutable tag like `latest` is re-pushed, the old image loses its tag but stays in the registry as an untagged layer. This rule removes those orphaned images after 7 days.

### Rule 2 — Keep only the last 10 images (Priority 2)

Applies to all images regardless of tag status. When the repo exceeds 10 images, the oldest are expired automatically. Adjust `countNumber` to retain more history.

> Rules are evaluated in priority order — lower number = evaluated first.

---

## Image Scanning

Enhanced scanning is enabled via Amazon Inspector for CVE detection across OS packages and application dependencies.

| Scan type | Filter | Behaviour |
|---|---|---|
| `SCAN_ON_PUSH` | `infra-validator-app*` | Every pushed image is scanned immediately |
| `CONTINUOUS_SCAN` | `infra-validator-app-prod*` | Production repos are re-scanned periodically for newly disclosed CVEs |

Scan results are visible in the ECR console under **Repositories → Images → Vulnerabilities**.

---

## Access Control

```hcl
repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
```

Only the IAM identity running Terraform is granted read/write access. ECS tasks pull images using the **task execution role** (`AmazonECSTaskExecutionRolePolicy`), which grants ECR pull permissions independently.

---

## Force Delete

```hcl
repository_force_delete = true
```

Allows `terraform destroy` to delete the repository even if it contains images. Set to `false` in production to prevent accidental data loss.
