# Implement the model handoff

**Bonus task — MLOps** · [Assignment](../../README.md) · also a required interview discussion topic · Time guide: ~2–3 h

## Goal

Data/ML must be able to hand a trained model to Dev safely. A model may only be used in production after it passes a check, using it is an explicit decision, and going back to the previous model takes one command.

**Terms.** A *candidate* is a trained model that has not been checked yet. To *publish* is to store a checked candidate as an immutable, versioned release. To *promote* is to select a published release for production analysis. To *roll back* is to promote the previous release again.

## Deliverables

| What | Where |
|---|---|
| Publish, promote and roll-back commands, using a tool of your choice | Your repository; commands documented in EVIDENCE.md |
| The demonstration sequence below | EVIDENCE.md, section "Bonus: model handoff" |

## Requirements

1. Use an established tool for storing and versioning models (for example a model registry, an object store with versioning, or an artifact registry). Write your own code only as glue.
2. Each published release must record:
   - version
   - artifact location
   - SHA-256 digest of the model file
   - input/output shape (input `(n, 2)`, output `(n,)`)
   - the contents of `evaluation.json`
   - the Git commit it was trained from
3. Publishing must run this gate first and refuse the candidate if any check fails:
   - `test_mse` ≤ `0.001`
   - `test_mse` < `baseline_test_mse`
   - the model loads with the supplied `load_model()` and `predict()` returns shape `(n,)` for an `(n, 2)` input
4. Publishing must **not** change which model production uses.
5. Promoting must check that the stored model's SHA-256 still equals the recorded digest, and refuse on a mismatch.
6. The analysis must use the promoted model through configuration (for example `MODEL_PATH`), without rebuilding images.
7. Production analysis must be able to tell which release it ran with: the `model_sha256` in the result rows must equal the promoted release's digest.

## Done when

The following sequence runs, with the output shown:

- [ ] A candidate that fails the gate (for example with the threshold lowered to `0.0001`) is rejected, and nothing is published.
- [ ] Publish v1 → promote v1 → run the analysis → result rows show v1's digest.
- [ ] Publish v2 → production still uses v1 → promote v2 → run the analysis → rows show v2's digest.
- [ ] Roll back to v1 → run the analysis → rows show v1's digest.
- [ ] Changing a stored model file's bytes makes promotion fail with a digest mismatch.

## Evidence to include in EVIDENCE.md

- Every command in the sequence above, with its output.
- The recorded metadata of one release.

## Not required

- A model-serving API, GPU training, or cloud deployment.
- Changing the image-inference algorithm. The inference step only records the model's digest; it does not use the regression weights.

## Hints (not graded)

- The training CLI is `python -m examples.model_lifecycle.train --output-dir <dir>`. Changing the dataset seed in [train.py](../../examples/model_lifecycle/train.py) is one way to get a second, different model.
