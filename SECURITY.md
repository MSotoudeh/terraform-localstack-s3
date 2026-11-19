# Security

## Reporting a vulnerability

Please report issues privately through GitHub ("Report a vulnerability" under the Security tab). Do not publish details in a public issue.

## Notes

- The Terraform provider uses the dummy credentials `test`/`test` for LocalStack only. They are not secrets. Never replace them with real AWS keys in committed files.
- Terraform state and plans can contain sensitive values; they are git-ignored (`*.tfstate*`, `tfplan`).
- Real secrets belong only in the git-ignored `secrets/` folder or `.env` files. No `*.tfvars` is tracked; if you need one, commit a `*.tfvars.example` with placeholders.
- `scripts/bootstrap.sh` changes the firewall and installs packages; `scripts/nuke-vm.sh` and `scripts/reset-lab.sh` delete data. Use them only on a disposable VM.
