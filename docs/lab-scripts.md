# Lab helper scripts and their sibling copy

`scripts/bootstrap.sh`, `scripts/nuke-vm.sh` and `scripts/reset-lab.sh` exist in two repositories:

- this one (`terraform-localstack-s3`), and
- [`docker-flask-app`](https://github.com/MSotoudeh/docker-flask-app), where they were first written (2026-02-09).

They are **not identical and not shared**. The copies here were derived from the docker-flask-app originals and specialised for LocalStack and Terraform. There is no dependency between the repositories; each stays self-contained. If you fix a bug in one, check by hand whether the other needs the same fix.

| Script | terraform-localstack-s3 (this repo) | docker-flask-app |
| --- | --- | --- |
| `bootstrap.sh` | Docker via socket only (no TCP listener); UFW opens 22, 5000 and 4566 for the SSH client IP; ends with a note that Terraform runs manually or in CI. | Enables `tcp://<guest-ip>:2375` through `daemon.json` and a systemd override; UFW opens 22, 2375 and 5000. |
| `nuke-vm.sh` | Stops/removes the `localstack` container first, removes the Docker systemd override, deletes Terraform state/cache in the working directory (root and `envs/dev`), then the usual purge. | Usual purge only. |
| `reset-lab.sh` | `docker compose down -v --remove-orphans`, `docker system prune -f`, removes Terraform state/cache. | Kills and removes all containers, `docker system prune -f --volumes`. |

Shared base: package list, Docker CE / Terraform / AWS CLI / yq / lazygit installation, the `moha` / `10.0.0.2` fallbacks, and the bare Git repository `~/repos/docker-flask-app.git` (a leftover name here).

`nuke-vm.sh` and `reset-lab.sh` use paths relative to the current directory (`envs/dev/...`), so run them from the repository root.
