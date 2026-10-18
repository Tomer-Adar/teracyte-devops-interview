# Supplied notebook-to-model example

[Assignment](../../README.md) · required interview discussion topic: model handoff

This fixture supplies the ML algorithm so your work can focus on infrastructure. It trains a tiny linear regression on synthetic data using the existing NumPy dependency. No GPU, cloud account or new ML framework is needed.

## Run it

From the repository root, with the local-development environment activated:

~~~bash
python -m examples.model_lifecycle.train --output-dir data/model-lifecycle
~~~

Alternatively, open [notebook.ipynb](notebook.ipynb) in an existing Jupyter-compatible editor using the same Python environment. Installing a notebook server is optional; the CLI is equivalent and sufficient for the required demonstration. The notebook finds the repository from either its directory or the repository root.

Both paths call run_experiment and write model.json and evaluation.json. Repeating with the same environment produces the same output bytes. Coefficients/metrics are rounded; cross-version or cross-platform numerical equivalence should be tested rather than assumed. Record dependency versions for a reproducible training environment.

## What the helpers provide

[train.py](train.py) provides:
- make_dataset(): fixed seed 2026, 128 training rows and 64 held-out test rows.
- fit(): least-squares regression using only training rows.
- load_model(): plain JSON loading with format and feature-shape checks; no pickle or arbitrary-code deserialization.
- predict(): predictions for an input matrix.
- evaluate(): held-out mean squared error (MSE, lower is better).
- run_experiment(): train, save, reload and evaluate, including a training-mean prediction baseline.

The evaluation report identifies the dataset/seed and row counts. It compares the trained model with a baseline on the same held-out data. It is a starting point for experiment tracking and benchmarking, not a model approval policy.

## Artifact and prediction contract

| Field/input | Meaning |
|---|---|
| format | toy-linear-v1 |
| feature_names | feature_a, feature_b, in that order |
| coefficients | Two finite coefficients |
| intercept | One finite scalar |
| Prediction input | Finite numeric array of shape (n, 2), one row per sample |
| Prediction output | Numeric vector of shape (n,), one scalar prediction per row |
| Evaluation input | Features plus a finite target vector of shape (n,), with n > 0 |

The format is a schema identifier, not a model release version. A release would add its own identity, artifact location, digest and evaluation references.

## Interview discussion

The fixture does not publish artifacts, compare release candidates against an approval threshold, choose production versions, verify release digests or roll back a release. **You do not need to implement any of this** unless you choose the [model handoff bonus](../../tasks/model-handoff/README.md). Be ready to discuss in the interview how you would do it, and with which tools: where artifacts live, how versions and digests are recorded, what gate a candidate must pass before it can be selected, how Dev's analysis picks a version, and how to roll back.

The existing image-inference step reads any nonempty artifact and records its SHA-256, but it computes mask-based mock metrics without evaluating these regression weights. Do not claim that a successful image-pipeline run validates this model's production accuracy. No change to the camera-image algorithm is required.

Outputs belong under ignored data/. Rerunning the same output directory overwrites scratch training outputs; use separate directories if you want to retain experiments.
