# Profile and right-size the analysis

**Bonus task — Compute** · [Assignment](../../README.md) · Time guide: ~2–3 h

## Goal

The [starter guide](../../docs/local-development.md) notes a memory bottleneck in preprocessing. Measure the analysis correctly, fix or contain the bottleneck, and size the analysis container from evidence, not guesses.

## Deliverables

| What | Where |
|---|---|
| A measurement method and its results | EVIDENCE.md, section "Bonus: right-size" |
| Container resource limits | Your Compose setup |
| Code change, if you optimize | `pipelines/steps/preprocess/run.py` |

## Requirements

1. Measure peak memory and duration for each step (preprocess, inference, database update) and for the whole run.
2. Your measurement must capture the true peak, even if it lasts under a second. For example, read the kernel's per-container or per-process peak counter. Explain why your method cannot miss the peak.
3. Do **one** of these:
   - **(a)** reduce the bottleneck's peak memory with a code change
   - **(b)** keep the code and contain the bottleneck with limits and concurrency settings
4. Set the analysis container's memory limit from your measurement, and state the headroom (for example 2× the measured peak).
5. Results must not change: your verifier must pass, and every `foreground_fraction` and `mean_intensity` value must equal the value before your change.
6. Estimate the effect at production size (images of 10 MiB each, 500,000 images/day): memory per worker and workers per node. State your assumptions.

## Done when

- [ ] A before/after table of peak memory and duration per step.
- [ ] The memory limit is set and justified by the table.
- [ ] Verifier `PASS`, and identical metric values before and after.

## Evidence to include in EVIDENCE.md

- The measurement commands and output, before and after.
- The before/after table.
- The limit you set.
- The production estimate with its assumptions.

## Not required

- Changing the thresholding algorithm, or GPU acceleration.
