# Add Argo orchestration

**Bonus task — Compute** · [Assignment](../../README.md) · Time guide: ~4–6 h

## Goal

Run Dev's existing analysis steps as a visible, repeatable workflow on Kubernetes, with Argo Workflows as the orchestrator.

## Deliverables

| What | Where |
|---|---|
| A local cluster + Argo setup script or commands | Your repository |
| Workflow template | `workflow-template.yaml` |
| Demonstration | EVIDENCE.md, section "Bonus: Argo" |

## Requirements

1. One documented command or script must create a local Kubernetes cluster (kind or k3d) and install Argo Workflows at a pinned version.
2. `workflow-template.yaml` must take two parameters, `experiment-id` and `image-ids`.
3. The workflow must run the existing commands: `pipelines.steps.preprocess.run`, then `pipelines.steps.ml_infer.run` for each image, then `pipelines.steps.db_update.run` once, only after every image's inference has finished.
4. Database connections must come from the same environment variables as in Compose, supplied through Kubernetes configuration, not hardcoded.
5. Every step must have CPU and memory requests and limits, and a retry limit of at most 2.
6. PostgreSQL, MongoDB and Redis may stay in Compose or run in the cluster. Steps must reach them either way.
7. One documented command or UI path must show a workflow's final status, its duration, and the logs of any failed step.

## Done when

- [ ] Submitting the template for a new experiment with `image-001`…`image-005` ends in `Succeeded`.
- [ ] Your verifier's checks pass for that experiment: 5 rows, `COMPLETED`, correct digest.
- [ ] The status/duration/log command works on a deliberately failed run.

## Evidence to include in EVIDENCE.md

- The setup and submit commands.
- The final status and duration.
- The log output of one failed step.
- The verification of the experiment.

## Not required

- Cloud Kubernetes, an artifact repository, or a monitoring stack for the cluster.

## Hints (not graded)

- A shared volume between steps is the simplest start. Note its scheduling limits if you use one.
