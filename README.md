# DevOps Engineer — Take-Home Assignment

You have **48 hours to submit**. Expect about **6–8 hours of focused work** for the required tasks.
We'd rather see five tasks done well and honestly labelled than everything half-finished.

Start with a clean, working baseline. If a requirement is beyond your experience, implement a simplified version and explain the missing production work.

## The system

Camera images pass through preprocessing, mock model inference and database aggregation. MongoDB tracks experiments; PostgreSQL stores results. Dev owns the API, Celery and production analysis steps. Data/ML develops models through notebooks, training and benchmarking. DevOps provides the infrastructure and the delivery paths between them. We run on Azure today and need cost-conscious, portable infrastructure.

## Start here

Follow the [local-development guide](docs/local-development.md) to run the supplied services and the sequential analysis runner.


## Use tools, not home-grown implementations

We'd much rather see an established tool used well than a custom script that re-implements one, whether for model tracking and registries, orchestration, monitoring, storage, testing or security. **If you know a tool that fits a task, use it** and say briefly why you chose it. Write your own code only as glue between tools, and expect us to ask why a tool didn't fit.

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

### [Add CI workflows for both teams](tasks/ci-workflows/README.md)
- Give Dev and Data/ML separate GitHub Actions workflows that run only what each change needs.
- Reuse your local commands; fail on errors and keep logs.

### [Implement storage with Terraform](tasks/cloud-infrastructure/README.md)
- Define private object storage and retention policies for your chosen cloud.
- Validate the configuration locally and in CI; cloud deployment is optional.

## Required interview discussion topics

Prepare these for the interview. **They are required, but need no implementation or write-up.** Expect to sketch them on a whiteboard and explain trade-offs, including tools you would use.

1. **Model handoff, notebook → model.** Data/ML trains the [supplied toy model](examples/model_lifecycle/README.md). How does a trained model get versioned, checked against an evaluation threshold, promoted, rolled back and consumed by Dev's analysis step? How does the analysis know which model it ran with?
2. **Cloud deployment plan and its cost trade-offs.** Where would the API, worker and broker, batch analysis, notebook users, training jobs, databases and object storage run? Which workloads need reliable capacity, and which could use Spot or scale to zero? What drives the cost, and what changes if we move to another provider?

## Bonus tasks: attempt at most 3

Bonuses are optional and only count after the required tasks work. **Pick at most three, from any categories.** We review only the first three listed in EVIDENCE.md, and more do not earn extra credit; depth beats breadth.

### MLOps
- [Implement the model handoff](tasks/model-handoff/README.md)
- [Implement a portable training and promotion platform](tasks/training-platform/README.md)
- [Version datasets and link them to models](tasks/dataset-versioning/README.md)

### Storage
- [Add portable object storage and model caching](tasks/portable-storage-models/README.md)
- [Demonstrate failure recovery across PostgreSQL and MongoDB](tasks/failure-recovery/README.md)
- [Back up and restore the databases](tasks/backup-restore/README.md)

### Compute
- [Write the cloud deployment plan](tasks/cloud-deployment-plan/README.md)
- [Add Argo orchestration](tasks/argo-orchestration/README.md)
- [Deploy to local Kubernetes with queue-based autoscaling](tasks/kubernetes-autoscaling/README.md)
- [Profile and right-size the analysis](tasks/right-size-analysis/README.md)

### Development
- [Isolate shared development environments](tasks/dev-isolation/README.md)
- [Add supply-chain security to CI](tasks/supply-chain-security/README.md)
- [Manage the database schema with migrations](tasks/schema-migrations/README.md)

### Your own idea
- [Propose and implement an improvement we haven't listed](tasks/own-idea/README.md): any DevOps optimization or relevant work you think this system needs.

## AI use and submission

**You are encouraged to use AI assistants. However, unverified, generic AI output will fail the review.** We will run your submission from a clean clone.

Submit your repository with:
- **EVIDENCE.md:** exact run commands, relevant outputs, one failed verification, the alert firing, CI run output, the bonuses you chose and any setup limits.
- **ARCHITECTURE_AND_DECISIONS.md:** a short paragraph per major choice explaining why, one alternative and the trade-off.

Explain one issue you encountered and how you verified the fix. Label estimates and incomplete work honestly. Keep generated data, model weights and credentials out of Git. In the interview we will discuss your working system and the two topics above.
