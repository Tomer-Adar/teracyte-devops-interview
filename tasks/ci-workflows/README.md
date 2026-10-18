# Add CI workflows for both teams

**Required task** · [Assignment](../../README.md) · Time guide: ~1.5–2 h

## Goal

Two teams change this repository: **Dev** changes the API, worker, analysis steps and infrastructure, and **Data/ML** changes the training code in `examples/model_lifecycle/`. Each team needs its own GitHub Actions workflow. It must run automatically on the right changes, check what that team owns, and fail loudly when something is wrong.

## Deliverables

| What | Where |
|---|---|
| Dev workflow | `.github/workflows/ci-core-dev.yml` |
| Data/ML workflow | `.github/workflows/ci-data-ml.yml` |
| Run links or output, and the trigger table | EVIDENCE.md, section "CI" |

## Requirements

### Both workflows
1. Each must run on `pull_request`, and on `push` to the `main` branch, **only** when a file in its path list (below) changes.
2. Steps that also exist locally (tests, Compose, the verifier, Terraform) must use the same commands you documented for local use. The CI-only steps, the evaluation gate and the digest file in requirement 9, must be listed in EVIDENCE.md as commands that can also be run locally.
3. Any failing command must fail the job. That includes a command piped into another one, such as `cmd | tee log`.
4. Each must declare `permissions: contents: read` and use no cloud credentials or secrets.

### `ci-core-dev.yml`: Dev
5. **Triggers on changes to:**
   - `services/**`, `pipelines/**`, `scripts/**`, `tests/**`, `infra/**`. `tests/**` includes `tests/test_model_lifecycle.py`; that overlap with the Data/ML workflow is intended, because the `unit` job runs every test.
   - your monitoring configuration directory
   - `Dockerfile` (and any other Dockerfiles), `.dockerignore`, `compose*.yaml`
   - `**/requirements*.txt` (every requirements file, at any depth)
   - `.github/workflows/ci-core-dev.yml`
6. **Must contain these four jobs:**

   | Job | What it runs | Passes when |
   |---|---|---|
   | `unit` | `python -m pytest -q` | All tests pass |
   | `e2e` | Build and start the stack with Compose, then run your [verify command](../verify-experiment/README.md) | The verifier prints `PASS` and exits 0 |
   | `terraform` | In `infra/`: `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate` | All three exit 0 |
   | `monitoring-config` | Your monitoring tool's own config and alert-rule checker on your monitoring files. If your tool has no checker: start the monitoring service in the job and query its API to confirm the alert rule loaded. Either way, check that the dashboard file is valid syntax (for example valid JSON) | All checks exit 0 |

7. The `e2e` job must upload the Compose logs and the verifier output as a workflow artifact **even when the job fails**.

### `ci-data-ml.yml`: Data/ML
8. **Triggers on changes to:**
   - `examples/model_lifecycle/**`
   - `tests/test_model_lifecycle.py`
   - `**/requirements*.txt` (every requirements file, at any depth; `requirements-local.txt` includes the nested ones)
   - `.github/workflows/ci-data-ml.yml`

   It must also be startable by hand (`workflow_dispatch`).
9. **Must run these steps in this order:**
   1. Install the Python dependencies from `requirements-local.txt`.
   2. Run `python -m pytest -q tests/test_model_lifecycle.py`.
   3. Train: `python -m examples.model_lifecycle.train --output-dir candidate`. This writes `candidate/model.json` and `candidate/evaluation.json`.
   4. **Evaluation gate:** fail the job if, in `candidate/evaluation.json`, `test_mse` is greater than `0.001`, or `test_mse` is not lower than `baseline_test_mse`.
   5. Write the SHA-256 digest of `candidate/model.json` to `candidate/model.json.sha256`.
   6. Upload `candidate/` as a workflow artifact named `model-candidate-<commit SHA>`.
10. It must **not** build Docker images, start the Compose stack, or change which model production analysis uses.

### Shared changes
11. A change to any requirements file must trigger **both** workflows. The `**/requirements*.txt` path in requirements 5 and 8 ensures this.

## Done when

- [ ] Changing a file in `services/` runs only `ci-core-dev`, and all four of its jobs pass.
- [ ] Changing a file in `examples/model_lifecycle/` runs only `ci-data-ml`, it passes, and the `model-candidate-<SHA>` artifact contains `model.json`, `evaluation.json` and `model.json.sha256`.
- [ ] Changing `requirements-local.txt` runs both workflows.
- [ ] Lowering the gate threshold from `0.001` to `0.0001` makes `ci-data-ml` fail at the gate step (the supplied model's `test_mse` is about `0.00011`).
- [ ] A failing `e2e` run still uploads its logs artifact.

## Evidence to include in EVIDENCE.md

- Links to one passing run of each workflow, from a fork or your own copy of the repository.
- A link to one deliberately failing `ci-data-ml` run (the lowered gate threshold), with the failing step named.
- A link to one deliberately failing `e2e` run (for example `EXPECTED_MODEL_SHA256` set to a wrong value on a test branch), showing that the logs artifact was still uploaded.
- The gate and digest commands from requirement 9, written so they run locally.
- This table, filled in from real runs:

  | Changed file | `ci-core-dev` ran? | `ci-data-ml` ran? |
  |---|---|---|
  | a file in `services/` | | |
  | a file in `examples/model_lifecycle/` | | |
  | `requirements-local.txt` | | |

- **If you cannot run GitHub Actions:** say why, and paste the same commands run locally with their output.

## Not required

- Deploying anything, pushing images to a registry, or publishing/promoting models (that is the [model handoff bonus](../model-handoff/README.md)).
- Branch protection rules, caching or matrix builds.

## Hints (not graded)

- Test requirement 3 with a deliberately failing piped command.
- A command-line JSON tool is enough for the evaluation gate; no extra Python is needed.
