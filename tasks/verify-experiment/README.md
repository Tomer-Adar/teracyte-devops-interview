# Verify an experiment

**Required task** · [Assignment](../../README.md) · Time guide: ~1–1.5 h

## Goal

One command must prove that a full analysis run wrote correct results. When results are wrong or late, the command must fail visibly.

**Terms.** An *experiment* is one analysis run, identified by its experiment ID. The *model digest* is the SHA-256 hash of the model file's bytes. The inference step records it in every result row as `model_sha256`.

## Deliverables

| What | Where |
|---|---|
| Verifier script | `tests/e2e_verify.py` |
| One command that runs the analysis and then verifies it | Documented in EVIDENCE.md, section "Verify" |
| One passing run and one deliberately failing run | EVIDENCE.md, section "Verify" |

## Requirements

1. The verifier must run as a one-shot Compose service, using the same image, environment variables and data volume as the analysis service. It starts the analysis as a child process inside its own container. It works against the real PostgreSQL and MongoDB of your Compose setup, not mocks.
2. It must take these inputs. Use these environment variable names; command-line flags may be added as well:

   | Input | Variable | Default |
   |---|---|---|
   | Model file | `MODEL_PATH` | The generated mock model (as in the containerize task) |
   | Expected model digest | `EXPECTED_MODEL_SHA256` | The SHA-256 of the model file, computed **before** the analysis starts |
   | Timeout | `E2E_TIMEOUT_SECONDS` | `180` |
   | Experiment ID | `E2E_EXPERIMENT_ID` | A new unique ID for every run, using only letters, digits, `_` and `-` |

3. The expected digest must never be read from the database rows being verified.
4. Before starting the timer, it must:
   - generate the fixtures if `data/manifest.json` does not exist, by calling `generate_data()` from `scripts/generate_mock_data.py` for the `data/` directory
   - fail with a clear message if the model file does not exist
   - delete any existing PostgreSQL rows and MongoDB document for the experiment ID. On a fresh database the `image_metrics` table does not exist yet; treat that as nothing to delete, and do not create the table yourself.
5. It must run the analysis (`scripts/run_local.py`) for that experiment ID and measure the elapsed time with a monotonic clock (for example `time.monotonic()`). The clock starts when the analysis starts and stops when it exits.
6. If the analysis exceeds the timeout, the verifier must stop it **and every process it started**, then report a timeout failure.
7. After the analysis, it must check all of these:
   - PostgreSQL table `image_metrics` has exactly 5 rows for the experiment, with `image_id` values `image-001` … `image-005`.
   - MongoDB document `experiments.experiments` with `_id = <experiment ID>` has `status = "COMPLETED"` and `result_count = 5`.
   - Every row's `model_sha256` equals the expected digest.
   - The analysis exited with code 0 within the timeout.
8. It must print:
   - `PASS` or `FAIL`
   - the experiment ID
   - the elapsed seconds
   - the expected digest
   - a list of every check that failed
9. Exit code: `0` only when every check passes, nonzero otherwise.

## Done when

- [ ] The documented command prints `PASS` and exits 0 on a fresh stack (after `docker compose down -v`).
- [ ] With `EXPECTED_MODEL_SHA256` set to a wrong value (for example 64 zeros), it prints `FAIL`, names the digest check, and exits nonzero.
- [ ] With `E2E_TIMEOUT_SECONDS=2`, it reports a timeout and exits nonzero, and no analysis process keeps running afterwards.
- [ ] Running it twice in a row passes both times; the second run cannot pass because of the first run's data.

## Evidence to include in EVIDENCE.md

- The command and the full output of one passing run, including elapsed seconds.
- The command and output of the wrong-digest run, with its exit code.

## Not required

- Checking metric values (`foreground_fraction`, `mean_intensity`).
- Chaos testing, database corruption or Kubernetes.

## Hints (not graded)

- The [CI workflows](../ci-workflows/README.md) task runs this same command in CI. Make it work non-interactively from a clean checkout.
- Test requirement 6 yourself: after a timeout, list the running processes or containers.
