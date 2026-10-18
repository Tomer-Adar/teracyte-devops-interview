# Manage the database schema with migrations

**Bonus task — Development** · [Assignment](../../README.md) · Time guide: ~1.5–2 h

## Goal

The PostgreSQL table `image_metrics` is created at runtime today, inside `pipelines/steps/db_update/run.py`. Make schema changes explicit, versioned, applied before anything uses the database, and reversible.

## Deliverables

| What | Where |
|---|---|
| Migration files and migration-tool configuration | Your repository, a directory of your choice |
| A one-shot migration service | Your Compose setup |
| Demonstration | EVIDENCE.md, section "Bonus: schema migrations" |

## Requirements

1. Use an established database migration tool.
2. **Migration 1** must create `image_metrics` exactly as it is today: the columns `experiment_id`, `image_id`, `foreground_fraction`, `mean_intensity` and `model_sha256`, with primary key `(experiment_id, image_id)`.
3. **Migration 2** must add one new nullable column, of your choice, without losing existing rows.
4. A one-shot migration service must run to completion before the API, worker and analysis start. They must depend on it finishing successfully.
5. Rolling back migration 2 must remove the column and keep all rows.
6. The `ci-core-dev.yml` workflow must apply all migrations to a fresh database and fail if any migration fails.
7. If you remove the `CREATE TABLE` from the analysis step, say so. If you keep it, explain why it is harmless.

## Done when

- [ ] On a fresh stack, the migration service applies migrations 1 and 2, then the app starts and your verifier passes.
- [ ] Rolling back migration 2 keeps every row, and the verifier still passes.
- [ ] The CI job applies the migrations on a fresh database.

## Evidence to include in EVIDENCE.md

- The migration history or status output after the upgrade and after the rollback.
- The row counts before and after.
- The verifier output.
- A link to the CI run.

## Not required

- MongoDB schema management, or zero-downtime migration patterns.
