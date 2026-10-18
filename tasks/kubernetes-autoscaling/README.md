# Deploy to local Kubernetes with queue-based autoscaling

**Bonus task — Compute** · [Assignment](../../README.md) · Time guide: ~3–4 h

## Goal

Run the API and Celery workers on Kubernetes, and scale the workers on the real demand signal, the export queue length, not CPU. Idle workers must cost nothing.

## Deliverables

| What | Where |
|---|---|
| Kubernetes manifests or packaged charts | Your repository |
| Setup commands | Documented in EVIDENCE.md |
| Scaling demonstration | EVIDENCE.md, section "Bonus: Kubernetes autoscaling" |

## Requirements

1. One documented command or script must create a local cluster (kind or k3d) and deploy the API and the worker from declarative files in the repository.
2. Connections must come from the same environment variables as in Compose, supplied through Kubernetes configuration. Credentials go in Kubernetes Secrets, not in Git as plain text.
3. Workers must scale on export-queue length, using an established autoscaling component, not a custom controller script:
   - from **0** when the queue is empty
   - up to a maximum of your choice (at most 5)
   - back to **0** within 5 minutes after the queue empties
4. The API and worker must have CPU and memory requests and limits, and readiness and liveness probes.
5. PostgreSQL, MongoDB and Redis may stay in Compose or run in the cluster.

## Done when

- [ ] With an empty queue, the worker has 0 replicas.
- [ ] Sending 20 export requests (`POST /experiments/<id>/exports`) scales workers above 0, and all 20 reports are written.
- [ ] Within 5 minutes after the queue empties, workers are back to 0.

## Evidence to include in EVIDENCE.md

- The setup command.
- The burst command.
- The worker replica count over time, from the empty queue through the burst and back to 0.
- The count of written reports.

## Not required

- Cloud Kubernetes, ingress/TLS, or autoscaling the API.
