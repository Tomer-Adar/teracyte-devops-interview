# Manage the database schema with migrations

**Bonus task — Development** · [Assignment](../../README.md)

## Goal

The guide notes that schema creation happens at runtime, inside the analysis step. Make schema changes explicit, versioned and reversible.

## Requirements

If you choose this task:
- Move the PostgreSQL schema (`image_metrics`) into versioned migrations managed by a migration tool.
- Run migrations as a one-shot step that completes before the API, worker and analysis start, in Compose and in CI.
- Demonstrate an upgrade (for example, adding a column) and a rollback, with existing rows preserved.
- Keep the analysis step working whether or not it still contains its own `CREATE TABLE IF NOT EXISTS`; explain what you changed in Dev's code, if anything.

## Suggested starting point

Start by capturing the current table as the first migration, then add a second one.

## How to demonstrate it

The migration history, an upgrade and a rollback, and the verifier passing after each.
