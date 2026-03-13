# Deploy Scripts

`deploy/run.sh` is meant to be executed from AWS CloudShell.

The script is designed for a Linux shell environment and will:
- install Terraform if it is not already available
- clone only `deploy/<project>` from the public repository
- run optional `pre_run.sh` and `post_run.sh` hooks in that project
- run `terraform init`
- run `terraform apply -auto-approve`

## Intended CloudShell Usage

From any AWS CloudShell session, run:

```bash
curl -fsSL https://raw.githubusercontent.com/mauri-codes/pharos-project/main/deploy/run.sh | bash -s -- NewAccountAdmin
```

That is the intended way to call the script from CloudShell when you do not want to clone the whole repository first.

## Alternative Usage

If you already cloned the repository in CloudShell, you can run:

```bash
bash deploy/run.sh NewAccountAdmin
```

## Project Argument

The required argument is the name of a subfolder inside `deploy/`.

Example:
- `NewAccountAdmin` maps to `deploy/NewAccountAdmin`
