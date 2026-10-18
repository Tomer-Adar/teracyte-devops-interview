# Add observability

**Required task** · [Assignment](../../README.md) · [Starter guide](../../docs/local-development.md)

## Goal

Let Dev and DevOps see whether the system is healthy, where resources go and when something breaks, without reading container logs by hand.

## Requirements

- Add a metrics, dashboard and alerting stack of your choice to Compose.
- Collect at least:
  - API availability and response time
  - broker queue depth and worker health
  - CPU and memory per container, including a one-shot analysis run
  - PostgreSQL, MongoDB and Redis availability
- Provision the data source and one dashboard **as code**, so they appear on a fresh `docker compose up` with no clicking.
- Define one alert rule as code that would page someone for a real problem. Demonstrate it firing, for example by stopping the worker or the API, and resolving again.
- Prefer existing exporters, probes and container-level collectors over changing application code. If you do instrument the application, explain why.
- Keep monitoring optional at startup (for example with a Compose profile) or explain why it always runs. Pin image versions.

## Suggested starting point

The API has no metrics endpoint; that is deliberate. Look at what you can learn from outside the process first. The guide notes a memory bottleneck in preprocessing: your resource panels should make it visible.

Short-lived containers can finish between two scrapes. Note what that means for the analysis run's metrics.

## How to demonstrate it

In EVIDENCE.md, show the scrape targets as healthy, the provisioned dashboard (a screenshot is enough), the alert going from pending to firing with the command that caused it, and the alert resolving.

## Optional improvements

Alert routing (e.g. Alertmanager to a webhook), centralized logs, job-duration metrics for the batch analysis, recording rules or a resource-sizing recommendation for the analysis container based on what you measured.
