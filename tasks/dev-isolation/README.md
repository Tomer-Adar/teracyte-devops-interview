# Isolate shared development environments

**Bonus task — Development** · [Assignment](../../README.md) · Time guide: ~2–3 h (blueprint ~1.5 h)

## Goal

Ten developers and data scientists must test their own changes at the same time, on shared infrastructure, without overwriting each other's work and without paying for ten full environments.

## Deliverables

| What | Where |
|---|---|
| **Either** a blueprint (written design) **or** working configuration, your choice | ARCHITECTURE_AND_DECISIONS.md, section "Dev isolation", plus any config files |
| The A/B demonstration or worked example | EVIDENCE.md, section "Bonus: dev isolation" |

## Requirements

Cover all six areas for two people, **Developer A** (changes the API) and **Data scientist B** (tests a new candidate model), working at the same time:

1. **Versions and routing:** how A's API version and B's model each run alongside the shared version, and how a request or analysis run reaches A's or B's version and not the other's.
2. **Database records:** how A's and B's experiments stay separate in PostgreSQL and MongoDB, so neither can see or overwrite the other's rows.
3. **Object storage:** how A's and B's images, masks, models and reports are kept apart (for example key prefixes).
4. **Secrets:** how each person gets credentials scoped to their own environment only.
5. **Quotas:** the CPU and memory limits per personal environment.
6. **Expiry:** how an idle environment is detected and removed automatically, and after how long.

Also:

7. State which components are shared by everyone, and which scale to zero when nobody uses them.

## Done when

- [ ] A table with one row per area (1–6) and columns "Developer A" and "Data scientist B" shows concrete names, prefixes, namespaces or settings for each.
- [ ] **Working configuration:** A and B run at the same time, and their results land in separate records and storage locations. **Blueprint:** a step-by-step walkthrough of A and B's simultaneous runs shows the same.
- [ ] The expiry rule states its time limit and what it deletes.

## Evidence to include in EVIDENCE.md

- The A/B table.
- Commands and output (working configuration) or the walkthrough (blueprint).
- The shared vs scale-to-zero list.

## Not required

- Ten actual environments, a cloud cluster, or a self-service UI.
