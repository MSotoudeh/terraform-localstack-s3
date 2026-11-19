# Contributing

## Setup

You need Docker and Terraform >= 1.5. Everything runs against LocalStack with dummy credentials; never point this lab at a real AWS account.

```bash
docker compose up -d
cd envs/dev
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
terraform init
```

## Checks before a pull request

```bash
docker compose config --quiet
terraform fmt -check -recursive
cd envs/dev && terraform validate
bash -n scripts/*.sh
```

CI (`.github/workflows/terraform-plan.yml`) runs fmt, validate and plan against a LocalStack container.

## Rules

- Keep reusable code in `modules/`, environment wiring in `envs/<name>/`.
- Do not commit state, plans, `*.tfvars` or LocalStack data (all git-ignored). Provide `*.tfvars.example` instead.
- The VM scripts in `scripts/` are destructive and have a sibling copy in docker-flask-app; see [docs/lab-scripts.md](docs/lab-scripts.md).

## Branches and commits

Branch from `main` using `feat/...`, `fix/...`, `docs/...` or `chore/...`. Use [Conventional Commits](https://www.conventionalcommits.org/), for example `feat(module): add versioning option`.
