# Back up and restore the databases

**Bonus task — Storage** · [Assignment](../../README.md) · Time guide: ~1.5–2 h

## Goal

Prove that experiment results survive the loss of the database containers and their volumes, instead of assuming it.

## Deliverables

| What | Where |
|---|---|
| Backup and restore commands or services | Your repository and Compose setup |
| Restore drill | EVIDENCE.md, section "Bonus: backup and restore" |

## Requirements

1. Use established backup tooling where it fits (database dump/restore tools or a backup tool), not custom export scripts.
2. One documented command must back up **both** PostgreSQL and MongoDB, to a Docker volume, a host directory excluded from Git, or object storage.
3. No credentials in Git. Backup credentials come from environment variables.
4. Run a **restore drill**:
   1. complete an experiment
   2. take a backup
   3. `docker compose down -v`, which deletes all volumes
   4. start fresh
   5. restore
   6. check the **original** experiment ID without re-running the analysis: 5 PostgreSQL rows for `image-001`…`image-005` with the original `model_sha256`, and MongoDB `status = COMPLETED` with `result_count = 5` (use direct queries, or add a verify-only mode to your verifier)
5. Report the measured restore time (RTO), and the maximum data loss your backup schedule allows (RPO).
6. Explain, in at most 3 lines, what happens if the PostgreSQL and MongoDB backups were taken at different moments, and how you prevent an inconsistent restore.

## Done when

- [ ] After `down -v` and the restore, the original experiment has 5 rows and `COMPLETED` status.
- [ ] The restore time is measured, not estimated.

## Evidence to include in EVIDENCE.md

- The backup command and output.
- The `down -v` command, the restore command and output, and the verification (queries or verifier output) of the original experiment.
- The RTO and RPO, and the explanation from requirement 6.

## Not required

- Off-site or cross-region copies, encryption at rest, or point-in-time recovery.
