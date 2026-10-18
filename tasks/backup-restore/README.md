# Back up and restore the databases

**Bonus task — Storage** · [Assignment](../../README.md)

## Goal

Prove that experiment results survive losing the database containers, rather than assuming it.

## Requirements

If you choose this task:
- Back up PostgreSQL and MongoDB with one command or on a schedule, to object storage or a dedicated volume. Keep credentials out of Git.
- Run a **restore drill**: destroy the stack's database volumes, start fresh, restore, and run your [verifier](../verify-experiment/README.md) against the restored experiment.
- State the recovery point (how much data you could lose) and recovery time you actually achieved.
- Keep PostgreSQL results and MongoDB experiment status consistent after a restore; explain what happens if the two backups were taken at different moments.
- Prefer established backup tooling over custom dump scripts where it fits.

## Suggested starting point

`docker compose down -v` already destroys the data; that is your disaster. Start with a manual backup and restore, then automate it.

## How to demonstrate it

The backup command, the destruction, the restore, the verifier passing on restored data, and the measured recovery time.
