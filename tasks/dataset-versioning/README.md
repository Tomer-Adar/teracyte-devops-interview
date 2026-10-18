# Version datasets and link them to models

**Bonus task — MLOps** · [Assignment](../../README.md) · Time guide: ~1.5–2 h

## Goal

For any trained model, answer "which exact data was this trained on?" When the data changes, retraining must produce a new model that traces back to the new data.

## Deliverables

| What | Where |
|---|---|
| Versioned dataset(s) and the tool configuration | Your repository; data files themselves stay out of Git |
| Demonstration | EVIDENCE.md, section "Bonus: dataset versioning" |

## Requirements

1. Use an established data-versioning or experiment-tracking tool. No hand-rolled hashing scheme.
2. Save the training dataset to files (it is generated in memory today by `make_dataset()` in [train.py](../../examples/model_lifecycle/train.py)), and train from those files.
3. Each dataset version must have an identity that changes whenever the data changes.
4. Each trained model must record the identity of the dataset it was trained on.
5. One documented command must show, for a given model, its dataset version. Another must show, for a given dataset version, the models trained on it.

## Done when

- [ ] Two dataset versions exist, for example produced with different seeds.
- [ ] One model is trained on each.
- [ ] The commands from requirement 5 show model 1 → dataset 1 and model 2 → dataset 2.
- [ ] The dataset files are not committed to Git.

## Evidence to include in EVIDENCE.md

- The commands and outputs for creating both versions, training both models, and both lookups.

## Not required

- Large or real datasets, data-quality checks, or remote storage. Local storage is enough.
