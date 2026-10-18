# Implement storage with Terraform

**Required task — configuration and validation only** · [Assignment](../../README.md)

## Goal

Turn the system's object storage into reviewable infrastructure code. No paid cloud account or Kubernetes experience is needed.

## Requirements

- Add Terraform under `infra/` using your chosen cloud provider. Define private object storage for raw images, masks and model artifacts, separated by containers/buckets or prefixes. Disable public access.
- Implement this retention policy:

  | Data | Policy |
  |---|---|
  | Raw images | Hot (standard) tier for 7 days, then a cool/infrequent-access tier, deleted after 30 days |
  | Masks | Hot for 30 days, then deleted |
  | Model artifacts | Never expired by these rules |

- Explain any provider minimum-storage-duration charges or lifecycle timing rules that affect this policy on your chosen cloud.
- Configure names, region and retention settings through variables. Include useful storage location outputs and example inputs without credentials. Identify external dependencies.
- Declare Terraform and provider version constraints and commit `.terraform.lock.hcl`. Keep state, downloaded providers, secrets and saved plans out of Git.
- Briefly explain credentials, secure shared state and locking in production, and what lifecycle expiration or `terraform destroy` would delete.
- Run formatting and validation locally. Cloud credentials, `plan` and `apply` are not required.

## Suggested starting point

Use the provider you know and implement storage only. A full network, cluster, database estate or remote-state backend implementation is unnecessary. Keep model retention separate from short-lived image retention.

Provider downloads need internet access. Initializing without a backend avoids connecting to remote state; validation does not verify cloud permissions, quotas, pricing or successful deployment.

## How to demonstrate it

From `infra/`, record these commands and their output in EVIDENCE.md:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Include example inputs and a short table mapping storage resources and lifecycle rules to raw images, masks and models. Document deployment and cleanup commands. Applying is not required; any optional deployment must use an account you are authorized to manage, with charges and cleanup documented. Disclose any validation blocked by network access instead of claiming it passed.

## Optional improvements

A linter or policy scanner (for example tflint, trivy or checkov), a secure remote-state backend, or a plan/apply in an account you control. Describe any real deployment charges before running them.
