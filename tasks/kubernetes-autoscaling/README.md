# Deploy to local Kubernetes with queue-based autoscaling

**Bonus task — Compute** · [Assignment](../../README.md)

## Goal

Run the API and Celery workers on Kubernetes and scale workers with the real demand signal, the export queue, instead of CPU.

## Requirements

If you choose this task:
- Run the API and worker on a local Kubernetes cluster from declarative, reproducible configuration (manifests or packages). Databases and broker may stay in Compose or run in the cluster.
- Configure data and broker connections externally, as in Compose.
- Scale workers on queue depth, down to zero when the queue is idle, with a sensible maximum.
- Set resource requests and limits, readiness and liveness checks.
- Prefer an established autoscaling component over a custom controller script.

## Suggested starting point

A burst of `POST /experiments/<id>/exports` requests fills the queue. Your observability stack can show the scale-up and scale-down.

## How to demonstrate it

The setup commands, a burst of exports, worker replicas rising and returning to zero, and the reports produced.
