# Write the cloud deployment plan

**Bonus task — Compute** · [Assignment](../../README.md) · extends the cloud deployment discussion topic

## Goal

Show practical cloud judgment for Dev's serving and analysis workloads and Data/ML's notebooks, training and model development, in writing, before the interview.

## Requirements

If you choose this task, add to ARCHITECTURE_AND_DECISIONS.md:
- One diagram or table placing the API, worker and broker, production batch analysis, notebook users, training workers, PostgreSQL, MongoDB, datasets and model artifacts. Choose Azure, AWS, GCP or a provider-neutral design.
- Which workloads need reliable capacity, and which could use Spot/interruptible capacity or scale to zero, and why.
- Short notes on GPU utilization, idle-notebook shutdown and checkpointing interrupted training.
- A migration outline for analysis, training and storage: configuration and credentials, data transfer, verification and rollback. Name the provider dependencies that remain and how you keep interfaces open (no proprietary ML or storage SDK calls in business logic).

**No cost calculation is needed.** We will discuss cost trade-offs in the interview, using your plan as the starting point.

## Suggested starting point

Build on your Terraform storage design and the observability you added: what you measured locally (for example the analysis container's memory) is good input for sizing.

## How to demonstrate it

The diagram or table and the short notes in ARCHITECTURE_AND_DECISIONS.md. Keep it to about one page.
