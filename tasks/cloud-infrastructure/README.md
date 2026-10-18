# Implement storage with Terraform

**Required task — configuration and validation only** · [Assignment](../../README.md) · Time guide: ~1–1.5 h

## Goal

Define the system's object storage as reviewable infrastructure code, with retention rules that keep storage costs down. You do not need a cloud account: the configuration is validated, not deployed.

## Deliverables

| What | Where |
|---|---|
| Terraform configuration | `infra/*.tf` |
| Provider lock file | `infra/.terraform.lock.hcl` (committed) |
| Example inputs, without credentials | `infra/terraform.tfvars.example` |
| Validation output, the storage mapping table, and the notes below | EVIDENCE.md, section "Terraform"; notes may go in ARCHITECTURE_AND_DECISIONS.md |

## Requirements

1. Use one cloud provider of your choice (Azure, AWS or GCP).
2. Define private object storage with three separate locations: **raw images**, **masks** and **model artifacts**. They can be separate containers/buckets, or prefixes in one, your choice.
3. Public/anonymous access must be disabled.
4. Implement exactly this retention policy:

   | Location | Rule |
   |---|---|
   | Raw images | Standard (hot) tier for the first 7 days; move to the provider's cool/infrequent-access tier on day 7; delete on day 30 |
   | Masks | Stay in the standard tier; delete on day 30 |
   | Model artifacts | No expiry and no tier change |

   If your provider does not allow a move to its cool tier on day 7, use the closest allowed tier or day, and explain the difference in note 4 (requirement 9).

5. These must be input variables:
   - a name prefix (no default; set it in `terraform.tfvars.example`)
   - the region (no default; set it in `terraform.tfvars.example`)
   - the raw-images tier-change day (default `7`)
   - the raw-images delete day (default `30`)
   - the masks delete day (default `30`)
6. These must be outputs:
   - the storage account or bucket name(s)
   - the address or URL of each of the three locations
7. Declare a `required_version` for Terraform and a version constraint for the provider. Commit `.terraform.lock.hcl`.
8. Configure no backend (local state only), and keep `*.tfstate`, `.terraform/` and saved plans out of Git.
9. Write short notes (at most 10 lines in total) covering:
   - how credentials would be supplied in production, with none in code
   - where shared state would live and how it would be locked
   - what the lifecycle rules delete, and what `terraform destroy` would delete
   - any minimum-storage-duration charge or lifecycle timing rule your provider applies to this policy

## Done when

From `infra/`, these three commands exit 0:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

- [ ] The retention rules match the table in requirement 4, including no rule on model artifacts.
- [ ] `git ls-files infra` shows the lock file and no state files or `.terraform/` directory.

## Evidence to include in EVIDENCE.md

- The three commands and their output.
- A table mapping each Terraform resource or rule to raw images, masks or models.
- The deploy and clean-up commands you would use (`plan`/`apply`/`destroy` with your variable file). Running them is not required.

## Not required

- Running `terraform plan` or `apply`, or having a cloud account.
- Networks, Kubernetes clusters, databases or a remote-state backend.

## Hints (not graded)

- `terraform init` downloads the provider and needs internet access. If it is blocked, say so instead of claiming validation passed.
- Look up your provider's minimum storage duration for its cool tier before writing note 4.
