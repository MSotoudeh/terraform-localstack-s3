# History

## Why this exists

Started in February 2026 to practise Terraform without paying for or risking real AWS: provision S3 against LocalStack, in a dedicated Ubuntu VM, with code authored on a Windows host. The repository was meant to model a realistic provisioning workflow (modules, environment folders, CI plan) at zero cost.

## Phases

1. **2026-02-09, sibling project.** The VM helper scripts were first written for [docker-flask-app](https://github.com/MSotoudeh/docker-flask-app).
2. **2026-02-11, initial commit.** This repository was created in one commit ("Modular Terraform LocalStack S3 setup"): module, `dev` environment, compose file, CI workflow, README, and copies of the three VM scripts, specialised for LocalStack (no Docker TCP listener, port 4566, Terraform state cleanup). It is the only commit before the cleanup; there are no other branches or tags.
3. **2026-11-19, public-ready cleanup.** Scripts moved to `scripts/` with kebab-case names, README rewritten to match the code, contributing/security documents added, `.gitignore` extended (LocalStack data, plans, tfvars).

## Previous state versus current state

Behaviour is unchanged. The old README showed an inline resource example that did not match the code (the real code uses the module) and described the scripts loosely; it now reflects the actual files.

## Unmerged lines of work

None. There were no other branches.

## Known unfinished

The README's old "Future Enhancements" list is still the backlog: remote backend simulation, static analysis (tflint, checkov), multi-environment expansion (stage). Also:

- `var.localstack_host` is declared in `envs/dev/provider.tf` but the endpoint is hard-coded to `http://localhost:4566`.
- Image tag `localstack/localstack:latest` is not pinned; the `DATA_DIR` setting in `docker-compose.yml` and the compose `version:` key may be ignored or deprecated by current versions.
- `terraform plan` in CI ends with `|| true`, so plan failures do not fail the job.
- `scripts/bootstrap.sh` still creates a bare repo named `docker-flask-app.git`, a leftover from the sibling project.
- Not validated locally in the 2026-11-19 cleanup: Terraform and Docker are not installed on the cleanup machine, so `terraform fmt/validate` and `docker compose config` were only checked by reading the files (CI is the authority).
