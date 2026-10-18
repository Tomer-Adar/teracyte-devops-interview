# Write the cloud deployment plan

**Bonus task — Compute** · [Assignment](../../README.md) · extends the cloud deployment discussion topic · Time guide: ~1–1.5 h

## Goal

Put your cloud placement in writing before the interview: where each workload runs, which capacity type it uses and why, and how we could move to another provider. We will discuss costs in the interview; **no cost calculation is needed here**.

## Deliverables

| What | Where |
|---|---|
| The plan, at most one page | ARCHITECTURE_AND_DECISIONS.md, section "Cloud deployment plan" |

## Requirements

1. Choose one target: Azure, AWS, GCP or a provider-neutral design.
2. Include a table with exactly these 9 rows and these 3 columns:

   | Component | Service you would use | Capacity type (reliable / Spot / scale-to-zero) and why |
   |---|---|---|
   | API | | |
   | Celery worker | | |
   | Broker (Redis) | | |
   | Production batch analysis | | |
   | Notebook users | | |
   | Training jobs | | |
   | PostgreSQL | | |
   | MongoDB | | |
   | Images, masks and model artifacts | | |

3. Add a diagram of how these components connect. A diagram-as-code block or an image file is fine.
4. In at most 5 lines, explain how you would:
   - keep GPUs busy
   - shut down idle notebooks
   - limit the work lost when a Spot training job is interrupted
5. Write a migration outline to another provider in four labelled steps: **configuration and credentials**, **data transfer**, **verification**, **rollback**.
6. List the provider-specific parts that remain, and how application code avoids them. Application code must not call proprietary ML or storage SDKs directly.

## Done when

- [ ] All 9 rows are filled and every capacity type has a reason.
- [ ] The diagram, the GPU/notebook/checkpoint notes and the 4-step migration outline are present.
- [ ] It fits on one page.

## Evidence to include in EVIDENCE.md

- A one-line pointer to the section in ARCHITECTURE_AND_DECISIONS.md.

## Not required

- Prices or cost calculations, deployment, or Terraform beyond the required storage task.
