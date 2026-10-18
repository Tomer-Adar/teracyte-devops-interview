# Version datasets and link them to models

**Bonus task — MLOps** · [Assignment](../../README.md)

## Goal

Answer "which data was this model trained on?" for any model, and make retraining on changed data produce a new, traceable model version.

## Requirements

If you choose this task:
- Give the training dataset an identity: a version or content hash that changes when the data changes.
- Record that identity with every trained model, alongside the code version and evaluation results.
- Show that changing the data produces a new model version that is traceable back to the new dataset, while the old model still points at the old data.
- Prefer an established data-versioning or experiment-tracking tool over a hand-rolled scheme, and say why you chose it.

## Suggested starting point

The supplied training example generates synthetic data from a fixed seed (`make_dataset()` in [train.py](../../examples/model_lifecycle/train.py)). Persist that dataset as a file first; a changed seed or row count is enough to create a second version.

## How to demonstrate it

Two training runs on two dataset versions, and the command that shows which dataset each resulting model came from.
