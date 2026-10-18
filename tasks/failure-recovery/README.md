# Demonstrate failure recovery across PostgreSQL and MongoDB

**Bonus task — Storage** · [Assignment](../../README.md) · Time guide: ~1.5–2 h

## Goal

An interrupted analysis must never leave duplicate results or a false "completed" status. A retry must always reach a correct final state.

## Deliverables

| What | Where |
|---|---|
| A reproducible way to interrupt the run at a chosen point | A script, environment flag or documented command in your repository |
| Demonstration and explanation | EVIDENCE.md, section "Bonus: failure recovery" |

## Requirements

1. Interrupt the analysis **after PostgreSQL has committed the result rows and before MongoDB is marked `COMPLETED`**. This is the gap in `pipelines/steps/db_update/run.py`.
2. Make the interruption reproducible, with the same point every time, for example a fault-injection environment variable or a kill at a known log line.
3. Show the intermediate state: the PostgreSQL row count and the MongoDB status, right after the interruption.
4. Retry the same experiment ID. The final state must be exactly 5 PostgreSQL rows and MongoDB `COMPLETED` with `result_count = 5`. Your verifier must pass.
5. Explain, in at most 5 lines, when an existing inference output (`inference.json`) may be reused on retry and when it must be recomputed, based on image identity and model digest.
6. Explain, in at most 5 lines, what happens if a Celery export task is retried or runs while the experiment is incomplete.

## Done when

- [ ] The interruption reproduces at the same point on two attempts.
- [ ] The intermediate state shows rows present but status not `COMPLETED`.
- [ ] After the retry: 5 rows, no duplicates, `COMPLETED`, verifier `PASS`.

## Evidence to include in EVIDENCE.md

- The interruption command, the intermediate-state queries and output, the retry command, and the final verifier output.
- The two explanations from requirements 5 and 6.

## Not required

- Kubernetes, real Spot evictions, or automatic resume.
