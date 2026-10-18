# DevOps Engineer — Take-Home Assignment

You have **48 hours to submit**. Expect about **6–8 hours of focused work** for the required tasks: the sum of the time guides below, plus reading.
We'd rather see five tasks done well and honestly labelled than everything half-finished.

Start from the working baseline described below. If a requirement is beyond your experience, build a simplified version, mark it **Simplified** in EVIDENCE.md, and list what is missing compared with the requirement.

## The system

Camera images pass through preprocessing, mock model inference and database aggregation. MongoDB tracks experiments; PostgreSQL stores results. Dev owns the API, Celery and production analysis steps. Data/ML develops models through notebooks, training and benchmarking. DevOps provides the infrastructure and the delivery paths between them. We run on Azure today and need cost-conscious, portable infrastructure.

## Start here

Follow the [local-development guide](docs/local-development.md) to run the supplied services and the sequential analysis runner.


## Use tools, not home-grown implementations

We'd much rather see an established tool used well than a custom script that re-implements one, whether for model tracking and registries, orchestration, monitoring, storage, testing or security. **If you know a tool that fits a task, use it** and say briefly why you chose it. Write your own code only as glue between tools, and expect us to ask why a tool didn't fit.

## Required tasks

Do all five. Each task page lists numbered requirements, a **Done when** checklist (what reviewers will check) and the exact evidence to include.

| # | Task | You deliver | Time guide |
|---|---|---|---|
| 1 | [Containerize the workloads](tasks/containerize-workloads/README.md) | Dockerfile(s) and Compose services for the API, worker and one-shot analysis | ~1–1.5 h |
| 2 | [Verify an experiment](tasks/verify-experiment/README.md) | `tests/e2e_verify.py`: checks results, status, model digest and run time; exits nonzero on failure | ~1–1.5 h |
| 3 | [Add observability](tasks/observability/README.md) | Monitoring in Compose, a dashboard and one alert defined in files, the alert shown firing | ~1–1.5 h |
| 4 | [Add CI workflows for both teams](tasks/ci-workflows/README.md) | `ci-core-dev.yml` (Dev) and `ci-data-ml.yml` (Data/ML) GitHub Actions workflows | ~1.5–2 h |
| 5 | [Implement storage with Terraform](tasks/cloud-infrastructure/README.md) | Private object storage with retention rules under `infra/`, validated | ~1–1.5 h |

## Required interview discussion topics

Prepare both topics for the interview. **They are required, but need no implementation or write-up.** Expect to sketch your answer on a whiteboard, about 10 minutes per topic, and to name the tools you would use.

1. **Model handoff, notebook → model.** Data/ML trains the [supplied toy model](examples/model_lifecycle/README.md); Dev's analysis consumes it. We will ask:
   - Where is a trained model stored, and how is each version identified?
   - What check must a model pass before production may use it, and where in the flow does that check run?
   - How does production switch to a new model, and how do you roll back? How does a result row tell you which model produced it?
2. **Cloud deployment plan and its cost trade-offs.** We will ask:
   - Where would you run the API, worker and broker, batch analysis, notebook users, training jobs, PostgreSQL, MongoDB and object storage?
   - Which of those need reliable capacity, and which can use Spot/interruptible capacity or scale to zero? Why?
   - What drives the monthly cost, what would you do to reduce it, and what changes if we move to another cloud provider?

## Bonus tasks: attempt at most 3

Bonuses are optional. Rules:

- Attempt **0 to 3** bonuses, from any categories.
- List the ones you attempted, in order, under "Bonuses attempted" in EVIDENCE.md. We grade only the first three on that list; extra bonuses earn no credit.
- Bonuses are graded only if the five required tasks run. A bonus never makes up for a missing required task.
- Each bonus page has its own requirements and **Done when** checklist. A partly finished bonus counts if you mark what is missing.

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

## Submission

Send us a link to your Git repository, with read access for the reviewers, within 48 hours.

**How we review.** We clone your repository fresh and run the commands written in your EVIDENCE.md, exactly as written. Then we tick each task's **Done when** checklist. Commands that only work on your machine count as not done.

**AI assistants.** You are encouraged to use them. Unverified, generic AI output will fail the review: every result in EVIDENCE.md must come from a command you ran. The only exceptions are items a task page explicitly says you need not run, such as Terraform `apply` commands; label those **Not run**.

Your repository must contain these files at the root:

1. **EVIDENCE.md**, with these sections in this order:
   1. Containerize
   2. Verify
   3. Observability
   4. CI
   5. Terraform
   6. Bonuses attempted: the list, then one section per bonus
   7. Issue I hit: one real problem, how you fixed it, and how you verified the fix
   8. Setup limits: anything you could not run, and why

   Each section contains the evidence its task page asks for: the exact commands and their real output.
2. **ARCHITECTURE_AND_DECISIONS.md**: one short paragraph per major choice, covering at least your image design, data and volume handling, monitoring tools, CI structure and cloud provider. Each paragraph states why you chose it, one alternative, and the trade-off.

**Must not be committed:** `data/`, model weight files, `.env` or any credentials, Terraform state (`*.tfstate`), `.terraform/` directories, and saved plans.

Label estimates and incomplete work honestly. In the interview we will discuss your working system and the two topics above.
