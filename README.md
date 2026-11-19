# terraform-localstack-s3

A Terraform lab that creates an S3 bucket against LocalStack (a local AWS emulator) running in Docker, with a reusable `s3_bucket` module, a `dev` environment, a CI workflow and helper scripts for a disposable Ubuntu VM.

## Status

**Active, small by design.** A zero-cost practice lab for Infrastructure as Code; it never talks to real AWS.

## What it does

- Defines a reusable module (`modules/s3_bucket`) that creates a bucket, sets ownership controls and applies an ACL.
- Instantiates it in `envs/dev` with the bucket `tf-localstack-lab-demo`.
- Points the AWS provider at LocalStack (`http://localhost:4566`, dummy credentials `test`/`test`).
- Provides `docker-compose.yml` to start LocalStack with `s3`, `iam` and `cloudformation`.
- Provides a GitHub Actions workflow that starts LocalStack, runs `terraform init`, `fmt -check`, `validate` and `plan`, and uploads the plan.
- Provides VM helper scripts (`scripts/`) to prepare, reset and wipe the Ubuntu VM used as the execution host.

## How it works

Intended workflow ("author on Windows, execute on Linux"): write code on a Windows host, push to Git, then run Terraform inside an Ubuntu VM that hosts Docker and LocalStack.

```
Windows host  --git-->  Ubuntu VM  --terraform-->  Docker: LocalStack (S3 on :4566)
```

`envs/dev/provider.tf` pins Terraform `>= 1.5.0` and the AWS provider `~> 5.0`, and sets the LocalStack endpoint. `modules/s3_bucket` takes `bucket_name`, `acl` (default `private`) and `tags`, and outputs `bucket_id` and `bucket_arn`.

## Quick start

Needs Docker and Terraform >= 1.5 (on the VM or locally).

```bash
docker compose up -d                       # start LocalStack on :4566
cd envs/dev
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply -auto-approve
aws --endpoint-url=http://localhost:4566 s3 ls   # verify (needs AWS CLI)
terraform destroy -auto-approve
docker compose down
```

Note that Terraform commands run in `envs/dev`; the root has no Terraform configuration.

### Disposable VM helpers (optional, Ubuntu only)

```bash
sudo bash scripts/bootstrap.sh   # Docker, Terraform, Ansible, AWS CLI, yq, lazygit, UFW (22, 5000, 4566 from the SSH client IP)
./scripts/reset-lab.sh           # compose down -v, docker prune, remove Terraform state (run from repo root)
sudo ./scripts/nuke-vm.sh        # purge Docker, Terraform, Ansible, AWS CLI, firewall (run from repo root)
```

These scripts are destructive; use them only on a VM you can discard. They are a hardened sibling of the scripts in [docker-flask-app](https://github.com/MSotoudeh/docker-flask-app); see [docs/lab-scripts.md](docs/lab-scripts.md).

## Configuration

No `.env` file is needed. Terraform reads the standard AWS variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`, any dummy values for LocalStack) and the variable `TF_VAR_localstack_host` (declared in `envs/dev/provider.tf` but not yet used by the endpoint). No `terraform.tfvars` is tracked; real `*.tfvars` files are git-ignored.

## Project layout

```
envs/dev/             Terraform root module for the dev lab (provider + module call)
modules/s3_bucket/    reusable S3 bucket module
scripts/              VM bootstrap / reset / wipe helpers
docs/                 history and notes on the shared lab scripts
.github/workflows/    CI: LocalStack + terraform fmt/validate/plan
docker-compose.yml    LocalStack service
```

## Testing

```bash
docker compose config --quiet
cd envs/dev && terraform init -input=false && terraform fmt -check && terraform validate
bash -n scripts/*.sh
```

`terraform plan` and `apply` need a running LocalStack (`docker compose up -d`). CI runs the same steps.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
