# Add portable object storage and model caching

**Bonus task — Storage** · [Assignment](../../README.md) · Time guide: ~2–3 h

## Goal

Replace the fixed local paths with object storage that works the same on any cloud or on-prem, and stop re-downloading the model on every run.

## Deliverables

| What | Where |
|---|---|
| A local S3-compatible object store | Your Compose setup |
| Storage configuration (endpoint, bucket, credentials via environment variables) | Compose and your code |
| Demonstration | EVIDENCE.md, section "Bonus: portable storage" |

## Requirements

1. Run an S3-compatible object store locally in Compose. MinIO is one option.
2. Raw images, masks and model artifacts must be read and written through the S3 API, not local paths. Reports may stay local; list anything that is still local.
3. The endpoint, bucket names, credentials and model location must come from environment variables. None may be hardcoded.
4. Business logic must not call a cloud provider's SDK directly. Use an S3-compatible client or a storage library behind configuration.
5. The model must be selected by its SHA-256 digest. After download, the digest must be checked, and the run must fail on a mismatch.
6. A model cache must keep the downloaded model between runs, keyed by digest:
   - the second run with the same digest must not download it again
   - a different digest must trigger a new download
   - a partially written cache file must never be used

## Done when

- [ ] Upload the five fixture images and the model to the object store; the analysis reads them from there and writes the masks there.
- [ ] Run 1 downloads the model. Run 2 with the same digest does not, as shown in logs or timing.
- [ ] Changing the selected digest downloads the new model.
- [ ] A wrong expected digest makes the run fail.
- [ ] Your verifier still passes.

## Evidence to include in EVIDENCE.md

- The commands and output for the upload, both runs (showing the cache hit), the digest change, and the digest-mismatch failure.
- Two sentences: how long a cache entry lives, and how a partial file is prevented.

## Not required

- Running against a real cloud bucket, or a production-sized model. Use the 50 MiB fixture.
