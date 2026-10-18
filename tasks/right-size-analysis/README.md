# Profile and right-size the analysis

**Bonus task — Compute** · [Assignment](../../README.md)

## Goal

The guide notes a memory bottleneck in preprocessing. Measure it correctly, fix or contain it, and size the analysis container from evidence.

## Requirements

If you choose this task:
- Measure peak memory and CPU per analysis step and for the whole run. The run is short: show that your measurement captures the real peak, not just what a periodic scrape happened to see.
- Either optimize the bottleneck or right-size the container around it, with before/after numbers.
- Set resource limits from your measurement and explain the headroom you chose.
- Estimate what your change means at production image sizes and volumes (throughput per node, or nodes needed).
- Preserve the step's outputs: masks, thresholds and result rows must not change.

## Suggested starting point

Dev owns the step's code. If you change it, keep the change small and show the verifier still passes with identical metrics.

## How to demonstrate it

Before/after peak memory and duration, how you measured them, the limits you set, and the verifier passing.
