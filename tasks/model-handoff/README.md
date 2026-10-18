# Implement the model handoff

**Bonus task** · [Assignment](../../README.md) · also a required interview discussion topic

## Goal

Turn the notebook → model discussion into a working local handoff: Data/ML publishes a model, a gate decides whether it may be used, and Dev's analysis consumes the selected version through configuration.

## Requirements

If you choose this task:
- Train and evaluate the [supplied toy model](../../examples/model_lifecycle/README.md) and publish it with handoff metadata: artifact location, release version, expected digest, input/output expectations and evaluation results.
- Gate the candidate **before** it can be selected: for example, an evaluation threshold, beating the baseline, and loading it with the supplied helper. Demonstrate one rejected handoff (a failed threshold or a digest mismatch). A digest assertion after the candidate has already been selected is not a gate.
- Keep publication separate from selection: publishing a candidate must not change what production analysis uses. Make promotion explicit and show a rollback.
- Make the selected version available to the existing analysis through configuration, and show its digest in the pipeline results.
- Use established tools of your choice, such as a model registry, an object store with versioning, or OCI artifacts. Write code only as glue.

## Suggested starting point

The image-inference starter is a mock: it records the chosen artifact's digest but doesn't evaluate the regression model. Prove selection and integration through the image pipeline, and demonstrate the toy model's evaluation separately with the supplied helpers. Production accuracy is outside this exercise.

Use open artifact formats and configurable locations. Training and consumption code must not depend on proprietary cloud ML APIs.

## How to demonstrate it

Include the training command, evaluation result, published artifact and metadata, the rejected handoff, a promotion and a rollback, and the selected digest in the pipeline results.
