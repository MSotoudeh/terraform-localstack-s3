# Terraform + LocalStack S3 Lab

Infrastructure as Code — Controlled Windows → Linux Execution Model

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![LocalStack](https://img.shields.io/badge/LocalStack-000000?style=for-the-badge&logo=localstack&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## Overview

This repository demonstrates a controlled Infrastructure-as-Code workflow using Terraform to provision AWS S3 resources against a LocalStack instance running inside a dedicated Ubuntu virtual machine.

The design separates:

* **Code authoring (Windows host)**
* **Execution environment (Linux VM)**
* **Cloud simulation layer (LocalStack via Docker)**

The objective is to model real-world cloud provisioning practices while maintaining zero AWS cost and full environment isolation.

---

## Architecture

```
Windows Host (10.0.0.2)
   |
   |  Git / Code Authoring
   v
Ubuntu VM (10.0.0.1)
   |
   |  Terraform Execution
   v
Docker Engine
   |
   v
LocalStack (S3 endpoint emulation)
```

---

## Environment Model

| Layer           | Responsibility                  | Technology             |
| --------------- | ------------------------------- | ---------------------- |
| Windows Host    | Code creation, Git operations   | Windows 11, PowerShell |
| Ubuntu VM       | Execution & testing environment | Ubuntu 24.04           |
| Container Layer | Cloud API simulation            | Docker Engine          |
| AWS Emulation   | S3 endpoint                     | LocalStack             |

**Key principle:**
All infrastructure code is written on Windows.
All infrastructure execution occurs inside the Ubuntu VM.

No direct production AWS interaction occurs in this lab.

---

## Terraform Configuration (Core Example)

Provider configured for LocalStack:

```hcl
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}
```

Example resource:

```hcl
resource "aws_s3_bucket" "lab_bucket" {
  bucket = "tf-localstack-lab-demo"
  acl    = "private"

  tags = {
    environment = "lab"
    managed_by  = "terraform"
  }
}
```

---

## Development Workflow

### 1️⃣ Author Code (Windows Host)

```powershell
cd C:\GitHub\terraform-localstack-s3
git add .
git commit -m "update terraform configuration"
git push
```

---

### 2️⃣ Execute in Ubuntu VM

SSH into VM:

```bash
ssh user@10.0.0.1
cd ~/projects/terraform-localstack-s3
```

Start LocalStack:

```bash
docker compose up -d
```

Run Terraform:

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply -auto-approve
```

---

### 3️⃣ Verify Resource

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

---

### 4️⃣ Teardown

```bash
terraform destroy -auto-approve
docker compose down
```

---

## Automation Scripts

### `bootstrap.sh`

* Installs Docker
* Installs Terraform
* Pulls LocalStack image
* Prepares working directory
* Idempotent execution model

### `reset_lab.sh`

* Removes Terraform state
* Restarts LocalStack container

### `nuke_vm.sh`

* Purges Docker images and volumes
* Removes LocalStack data
* Restores VM to clean lab state

---

## Security Model

This lab intentionally avoids:

* Exposing Docker daemon over TCP (2375)
* Direct root-level remote Docker binding
* Real AWS credentials

Remote Docker access, if required, should be performed over SSH using:

```
docker context create vm --docker "host=ssh://user@10.0.0.1"
```

Unencrypted Docker TCP exposure is not used in this design.

---

## Terraform Best Practices Applied

* Provider version pinning
* Environment separation (`envs/dev`)
* Module abstraction (`modules/s3_bucket`)
* No credentials committed
* Explicit tagging
* Explicit destroy workflow

---

## Development Loop Strategy

The repeatable loop is:

1. Modify Terraform configuration (Windows).
2. Push changes to Git.
3. SSH into VM.
4. Run `terraform plan`.
5. Apply or destroy.
6. Reset environment when required.

This mirrors real-world cloud development cycles while remaining fully isolated.

---

## Why LocalStack

* Zero AWS cost
* Safe experimentation
* Fast iteration
* Offline capability
* Deterministic testing environment

---

## Future Enhancements

* Remote backend simulation
* CI workflow with LocalStack container
* Terraform plan artifact upload
* Static analysis (tflint, checkov)
* Multi-environment expansion (dev/stage)

---

## License

MIT License

---

Maintained as part of a DevOps Infrastructure portfolio demonstrating Terraform-based infrastructure workflows within a controlled lab environment.
