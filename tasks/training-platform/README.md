# Implement a portable training and promotion platform

**Bonus task — MLOps** · [Assignment](../../README.md) · [Model handoff bonus](../model-handoff/README.md) · Time guide: ~4–6 h

## Goal

Give Data/ML a self-service way to run training jobs, compare experiments and release models, on a laptop today and on cloud compute later, without code changes.

## Deliverables

| What | Where |
|---|---|
| Tracking and registry service(s) | Your Compose setup |
| Training job definition and submit command | Your repository; command documented in EVIDENCE.md |
| Demonstration | EVIDENCE.md, section "Bonus: training platform" |

## Requirements

1. Use an established experiment-tracking and model-registry tool. Do not build one.
2. One documented command must submit a training job that runs the supplied training code in a container.
3. Every training run must record:
   - a dataset identity (a seed or hash)
   - parameters
   - the Git commit
   - metrics (`test_mse`, `baseline_test_mse`)
   - the model artifact
4. You must be able to compare at least two runs side by side, in the tool's UI or CLI.
5. Registering a model must be separate from promoting it to production. Promotion must apply the [model handoff](../model-handoff/README.md) gate (requirement 3 there).
6. Rolling back to the previous production model must take one command or action.
7. CPU or GPU must be selectable with one setting. Running only on CPU locally is fine; document the GPU setting.
8. No credentials in notebooks, code or Git. Endpoints and credentials come from environment variables or a secrets file excluded from Git.
9. Training and model-loading code must not call proprietary cloud ML APIs.

## Done when

- [ ] Two submitted runs (for example with different seeds) appear in the tracking tool with all fields from requirement 3.
- [ ] A comparison of the two runs is shown.
- [ ] One model is registered, promoted, a second one promoted, then rolled back.
- [ ] `git grep` finds no credentials.

## Evidence to include in EVIDENCE.md

- The submit command and output.
- A screenshot or CLI output of the run comparison.
- The promote and roll-back commands and their results.
- A short list: what ran locally, what is only configuration, and what is untested in the cloud.

## Not required

- An actual cloud or GPU run, multi-user access control, or a serving API.
