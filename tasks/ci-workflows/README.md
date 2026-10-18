# Add CI workflows for both teams

**Required task** · [Assignment](../../README.md)

## Goal

Dev owns the API, Celery and production analysis steps. Data/ML owns the notebook, training and evaluation assets under `examples/model_lifecycle`. Give each team a delivery path that runs only what its change needs, and fails loudly when something breaks.

## Requirements

- Add `ci-core-dev.yml` and `ci-data-ml.yml` under `.github/workflows` with the ownership below.
- Reuse the same commands you documented locally (Compose, the verifier, Terraform); don't write a second, CI-only way of running things.
- Propagate failures: a failing test, verification or check must fail the job. Retain useful logs (for example, Compose logs and verifier output as workflow artifacts) when a job fails.
- No cloud credentials, `terraform apply` or deployment are required.

| Change | Delivery path |
|---|---|
| API, Celery or production analysis step | Dev workflow: build, tests and the [end-to-end verification](../verify-experiment/README.md) against real databases |
| Terraform storage configuration | Dev workflow: `fmt -check`, `init -backend=false`, `validate` |
| Monitoring configuration | Dev workflow: validate the config and rules with the monitoring tool's own checker |
| Notebook, training or evaluation assets | Data/ML workflow: train, evaluate, apply an evaluation threshold and keep the candidate model and its evaluation as a workflow artifact. It must not rebuild the API image or select the model for production |
| Shared dependencies or runtime | Both workflows |

## Suggested starting point

Path filters decide which workflow runs. Decide explicitly which files are shared. One shared Dockerfile is fine.

Use the supplied training CLI (`python -m examples.model_lifecycle.train`); do not invent an ML algorithm. Its `evaluation.json` already contains the test error and a baseline to gate on.

## How to demonstrate it

Push to a fork and include the workflow run output, including one run where a check fails. If repository permissions prevent Actions from running, include the workflow files, the equivalent local output and the limitation. Show which workflow runs for an API change, a training-only change and a shared change.

## Optional improvements

Lint the workflows (for example with actionlint), cache dependencies, publish immutable images, or add a manually triggered workflow for model-only candidates.
