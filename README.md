# DevOps Engineer — Take-Home Assignment

You have **48 hours to submit**. Expect about **5–6 hours of focused work** for the required tasks. Don't spend much more than that; we'd rather see four tasks done well and honestly labelled than everything half-finished.

Start with a clean, working baseline. If a requirement is beyond your experience, implement a simplified version and explain the missing production work.

## The system

Camera images pass through preprocessing, mock model inference and database aggregation. MongoDB tracks experiments; PostgreSQL stores results. Dev owns the API, Celery and production analysis steps. Data/ML develops models through notebooks, training and benchmarking. DevOps provides the infrastructure and the delivery paths between them. We run on Azure today and need cost-conscious, portable infrastructure.

## Start here

Follow the [local-development guide](docs/local-development.md) to run the supplied services and the sequential analysis runner.

**Prefer established infrastructure tools of your choice over custom scripts.** Compose, Terraform, exporters, Prometheus/Grafana, object stores and registries are examples, not requirements. Write code only as glue, and say briefly why you chose each tool.

## Required tasks

### [Containerize the workloads](tasks/containerize-workloads/README.md)
- Run the API, worker and analysis pipeline with Compose.
- Configure connections externally; keep data and models outside images.

### [Verify an experiment](tasks/verify-experiment/README.md)
- Check five results, experiment status, model digest and execution time.
- Demonstrate one failing check.

### [Add observability](tasks/observability/README.md)
- Collect availability, queue, resource and database health metrics with monitoring tools in Compose.
- Provision a dashboard and one alert as code; demonstrate the alert firing.

### [Implement storage with Terraform](tasks/cloud-infrastructure/README.md)
- Define private object storage and retention policies for your chosen cloud.
- Validate the configuration locally; cloud deployment is optional.

## Required interview discussion topics

Prepare these for the interview. **They are required, but need no implementation or write-up.** Expect to sketch them on a whiteboard and explain trade-offs, including tools you would use.

1. **Model handoff, notebook → model.** Data/ML trains the [supplied toy model](examples/model_lifecycle/README.md). How does a trained model get versioned, checked against an evaluation threshold, promoted, rolled back and consumed by Dev's analysis step? How does the analysis know which model it ran with?
2. **CI workflows.** How would you split delivery between Dev (API, worker, analysis steps, Terraform) and Data/ML (training, model candidates)? What runs on which change, what runs on a model-only change, and how do failures and logs surface?
3. **Cloud deployment plan.** Where would the API, worker and broker, batch analysis, notebook users, training jobs, databases and object storage run? Which workloads need reliable capacity, and which could use Spot or scale to zero? What drives the cost, and what changes if we move to another provider?

## Optional extensions

Choose only what interests you after the required work. None are expected.

- [Demonstrate failure recovery](tasks/failure-recovery/README.md)
- [Add portable object storage and model caching](tasks/portable-storage-models/README.md)
- [Isolate shared development environments](tasks/dev-isolation/README.md)

## AI use and submission

**You are encouraged to use AI assistants. However, unverified, generic AI output will fail the review.** We will run your submission from a clean clone.

Submit your repository with:
- **EVIDENCE.md:** exact run commands, relevant outputs, one failed verification, the alert firing and any setup limits.
- **ARCHITECTURE_AND_DECISIONS.md:** a short paragraph per major choice explaining why, one alternative and the trade-off.

Explain one issue you encountered and how you verified the fix. Label estimates and incomplete work honestly. Keep generated data, model weights and credentials out of Git. In the interview we will discuss your working system and the three topics above.
