# Add observability

**Required task** · [Assignment](../../README.md) · [Starter guide](../../docs/local-development.md) · Time guide: ~1–1.5 h

## Goal

Dev and DevOps must see at a glance whether the system is healthy and where resources go, and be alerted when users are affected, without reading container logs.

## Deliverables

| What | Where |
|---|---|
| Metrics, dashboard and alerting services | Your Compose setup |
| Their configuration, dashboard definition and alert rule | Files in the repository (your choice of directory) |
| Proof that it works | EVIDENCE.md, section "Observability" |

## Requirements

1. The tools are your choice. Use established monitoring tools, not a custom metrics collector.
2. One documented command must start the monitoring together with the application. Monitoring may be off in the default startup (for example behind a Compose profile).
3. You must collect these four groups of metrics:

   | # | Group | Must show |
   |---|---|---|
   | M1 | API | Up/down, and response time of `GET /openapi.json` |
   | M2 | Queue | Length of the Celery queue named `celery` in Redis (queued export tasks), and number of live Celery workers |
   | M3 | Containers | CPU and memory per container, including the one-shot analysis container while it runs |
   | M4 | Dependencies | Up/down for PostgreSQL, MongoDB and Redis |

4. Prefer collecting from outside the application, through probes, exporters and container metrics. If you change application code (Python files) to expose metrics, explain why in ARCHITECTURE_AND_DECISIONS.md. Changing a service's command-line flags in Compose (for example enabling Celery events) does not count as an application code change.
5. A dashboard with at least four panels, one per group M1–M4, must be defined in a file in the repository. It must appear automatically on startup, with no clicking.
6. One alert rule, defined in a file in the repository, must cover **one** of these user-facing failures (your choice):
   - **A.** Export tasks are queued and no Celery worker is alive, for 30 seconds.
   - **B.** The API is down for 30 seconds.
7. The alert must reach the *firing* state within 2 minutes of causing the failure, and clear within 2 minutes of recovery.
8. Every monitoring image must be pinned to a version. No `latest` tags.

## Done when

- [ ] One command starts the application plus monitoring from a fresh clone.
- [ ] Every metrics source reports as healthy (for example, on a scrape-targets page).
- [ ] The dashboard opens with M1–M4 panels showing data, without any manual setup.
- [ ] **Alert A:** run the analysis for an experiment, stop the worker, then `POST /experiments/<id>/exports` (the API accepts exports only for completed experiments). The alert fires within 2 minutes; restarting the worker clears it within 2 minutes.
- [ ] **Alert B:** stop the API. The alert fires within 2 minutes; restarting the API clears it within 2 minutes.
- [ ] No monitoring image in the Compose files uses `latest` or an untagged name.

## Evidence to include in EVIDENCE.md

- The start command.
- The list of metrics sources and their health.
- A screenshot of the dashboard, or its URL plus an API listing that shows it loaded.
- A timestamped sequence: (for A) the analysis run and the export request, the command that broke the service, the alert going *pending → firing*, the command that fixed it, and the alert clearing.
- One sentence on whether your M3 panel captures the analysis container's real peak memory, and how you know.

## Not required

- Sending notifications (email, chat, paging), logs, tracing, or long-term metric storage.
- More than one alert rule.

## Hints (not graded)

- The API deliberately has no metrics endpoint. See what you can measure from outside first.
- The analysis run lasts only a few seconds. Think about what that means for metrics that are sampled periodically.
