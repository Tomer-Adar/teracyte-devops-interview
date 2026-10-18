# Calculate cloud costs

**Bonus task — calculation only** · [Assignment](../../README.md) · supports the cloud deployment discussion topic

## Goal

Back the cloud deployment discussion with numbers: what the storage retention policy saves, and what Spot capacity and model caching change for production analysis.

## Requirements

If you choose this task, add to ARCHITECTURE_AND_DECISIONS.md:
- Both calculations below, with formulas, units, results and a recommendation.
- Any provider minimum-storage-duration or lifecycle timing rule on your chosen cloud that changes the storage result.
- Omitted costs and risks, such as requests, retrieval, egress, cluster/control-plane charges, database availability, backups and Spot interruptions.

No cloud account, price research or complete cloud bill is required.

## Suggested starting point

Use these **hypothetical exercise rates, not provider quotes**. Use binary units: 1 GiB = 1,024 MiB. Treat a month as 30 days.

### Calculation 1: storage

| Input | Assumption |
|---|---|
| Volume | 500,000 raw images/day; one mask per image |
| Size | Raw image 10 MiB; mask 1 MiB |
| Baseline | Raw images and masks remain hot for 30 days, then are deleted |
| Alternative | Raw images hot for 7 days, cool for 23 days, then deleted; masks hot for 30 days, then deleted |
| Rates | Hot $0.02/GiB-month; cool $0.01/GiB-month |

Calculate steady-state stored GiB and monthly storage cost for each policy, after retention has filled. Daily GiB × days retained gives the capacity in each tier; multiply that capacity by the tier's monthly rate. Do not multiply the monthly rate by 30 again. Report the monthly difference and one retrieval/retention trade-off.

### Calculation 2: production analysis compute and model delivery

| Input | Assumption |
|---|---|
| Production analysis workload (not training) | 100 node-hours/day before retries |
| On-Demand rate | $0.20/node-hour |
| Spot rate | $0.06/node-hour |
| Spot overhead | 20% extra node-hours for retries |
| Production model | 1.5 GiB |
| No cache | 2,000 model downloads/day |
| Cache | 4 cache warmups/day, one full model download per warmup |

Calculate monthly On-Demand and Spot compute cost, plus daily model-transfer GiB with and without the cache. Explain the likely startup benefit and cache loss on interrupted nodes. No transfer dollar price is supplied: identify where network charges might apply instead of inventing a quote.

These compute and download assumptions concern production analysis, not notebook or training usage. The 1.5 GiB model and image sizes are production assumptions; use the smaller supplied fixtures for implementation.

## How to demonstrate it

Show the formulas and results in ARCHITECTURE_AND_DECISIONS.md. Be ready to walk through them in the interview.

## Optional improvements

Use real dated pricing, estimate archive/retrieval or GPU costs, or evaluate reserved capacity.
