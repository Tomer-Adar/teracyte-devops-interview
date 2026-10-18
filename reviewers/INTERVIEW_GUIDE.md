# Interview guide (reviewers only)

**Do not share this branch with candidates.** It holds a reference solution for the five required tasks, answers for the two required discussion topics, bonus grading notes, a grading rubric and interview questions. The candidate brief is on `assignment-mid-level`.

Target: mid-level DevOps engineer, about 6–8 hours of focused work with AI tools. The original, larger task specs are kept in [original-tasks/](original-tasks/) for context.

## How to review a submission (≈30 minutes)

1. Clone fresh. Run exactly the commands in the candidate's EVIDENCE.md. Most red flags show up here, before you read any code.
2. Run their verifier with a wrong expected digest. It must exit nonzero.
3. Start their monitoring, stop the worker (or the API), and watch whether their alert fires.
4. Open their CI run links. A workflow that never ran is a partial pass at best.
5. Only then read ARCHITECTURE_AND_DECISIONS.md and the code.

## Rubric: required tasks

| Area | Pass | Strong | Red flag |
|---|---|---|---|
| Containers | API, worker and analysis run from a clean clone; connections via env | Non-root, healthchecks, data in volumes, `.dockerignore`, model path via config | Works only with an existing local `data/`; secrets or weights baked into the image |
| Verification | 5 rows, COMPLETED, digest check, nonzero exit on failure | Unique experiment IDs, monotonic timer, timeout kills the whole process tree | Expected digest read from output rows; "failing" demo exits 0 |
| Observability | Metrics stack in Compose; dashboard and alert provisioned as code; alert fires and resolves | Exporters/probes instead of app changes; notices short-lived containers are missed between scrapes; sizing backed by a measurement | Dashboard built by clicking (not in Git); alert never shown firing; `latest` image tags |
| CI workflows | Two workflows, path-filtered by team; Dev runs E2E verify and Terraform validate; failures fail the job | Ran on GitHub with a deliberately failing run; logs uploaded on failure; pipefail; training-only change doesn't rebuild the API; model gate uses existing tools (e.g. `jq` on `evaluation.json`) | Never ran; `continue-on-error`; CI-only scripts that differ from local commands; cloud credentials in YAML |
| Terraform | fmt, init, validate pass (also in CI); private storage; lifecycle as specified | Models excluded from expiry; versioning; shared keys off; names what `destroy` deletes; provider minimum-duration rules | State or `.terraform/` committed; public access; credentials in tfvars |
| Honesty | Limits labelled | One real issue, with how the fix was verified | Claims that cannot be reproduced |

## Traps that unverified AI output falls into

These were all hit or nearly hit while building the reference. They make good probing questions.

- **Timeout leaves work running.** `subprocess.run(timeout=…)` kills only the runner, not the step it started. Reference fix: own process group + `os.killpg` ([tests/e2e_verify.py](../tests/e2e_verify.py)).
- **Circular digest check.** The expected digest is taken from the database rows it is meant to verify.
- **Bind mounts on a clean clone.** Docker creates a missing bind-mount source directory as root, breaking later host writes.
- **CI hides failures.** GitHub steps without `shell: bash` run without `pipefail`, so `verify | tee log` passes when verify fails.
- **Monitoring misses batch jobs.** The analysis container lives about 7 s. Prometheus saw a 5 MiB peak; the cgroup's `memory.peak` was 254 MiB. A candidate who sizes from the dashboard alone under-provisions by 50×.
- **Fresh-database shortcut.** Pre-run cleanup that creates `image_metrics` with a stub schema breaks the real insert.

## Required discussion topic 1: model handoff, notebook → model

**Ask:** "Data/ML has a new model in a notebook. Walk me from there to Dev's analysis using it in production, and back out again."

**Tool-agnostic. Accept any tool that gives these properties:**

| Property | What good sounds like |
|---|---|
| Immutable versions | Never overwrite a release; new version = new object/tag |
| Digest | SHA-256 recorded at publish and checked before use; the analysis records which digest it ran with (the starter already writes `model_sha256`) |
| Gate before selection | Evaluation threshold + "beats baseline" + loader/contract check happen **before** a candidate can be selected. A digest check after promotion is not a gate |
| Publish ≠ promote | Publishing a candidate never changes what production uses; promotion is explicit and audited |
| Rollback | Re-point the selection at the previous version; no rebuild |
| Reproducibility | Dataset identity, seed, code commit, dependency versions recorded with the model |

**Reasonable tool choices:** MLflow model registry with aliases (`@champion`); S3/MinIO/Azure Blob with object versioning, tags and Object Lock; OCI artifacts via ORAS in a container registry; DVC with Git tags. A plain bucket plus a JSON metadata file is acceptable for this scale if the properties hold.

**Red flags:** Azure ML or another vendor-only registry as a hard dependency in business code; "the latest file wins"; no notion of who approved a promotion.

The supplied fixture already provides training, evaluation against a baseline, and a safe JSON loader ([examples/model_lifecycle](../examples/model_lifecycle/README.md)). The reference CI ([ci-data-ml.yml](../.github/workflows/ci-data-ml.yml)) shows a minimal tool-based gate: `jq` on `evaluation.json`, `sha256sum`, and a workflow artifact.

## Reviewing the CI task (required)

**Ask:** "A data scientist changes only the training code. What runs? And if a Dev changes the analysis step?"

Reference: [ci-core-dev.yml](../.github/workflows/ci-core-dev.yml) and [ci-data-ml.yml](../.github/workflows/ci-data-ml.yml).

| Change | Expected behaviour |
|---|---|
| API, Celery, analysis step | Dev workflow: unit tests, image build, end-to-end verification against real databases |
| Monitoring config | Dev workflow: `promtool check config`/`check rules`, dashboards are valid JSON |
| Terraform | Dev workflow: fmt, `init -backend=false`, validate; no credentials, no apply |
| Training / evaluation only | Data/ML workflow: train, evaluate, gate, keep the candidate as an artifact; **no API rebuild, no promotion** |
| Shared (requirements, runtime) | Both |

## Required discussion topic 2: cloud deployment plan

**Ask:** "Place every workload on Azure. What runs on Spot? Where does the money go?"

| Workload | Good placement | Capacity |
|---|---|---|
| API | AKS stable pool (or Container Apps), ≥2 replicas | Reliable |
| Worker + broker | Workers on stable pool, HPA on queue depth; Managed Redis | Reliable, small |
| Batch analysis | AKS Spot pool, scale 0→N; idempotent steps (upsert key exists) | **Spot**, scale to zero |
| Notebooks | JupyterHub with idle culler, GPU profile on request | Scale to zero |
| Training | K8s Jobs on GPU Spot pool, checkpoints to Blob, TTL cleanup | **Spot**, scale to zero |
| PostgreSQL | Azure Database for PostgreSQL Flexible Server | Reliable, backups |
| MongoDB | MongoDB Atlas on Azure (real wire protocol, portable), **not** Cosmos DB-specific APIs | Reliable |
| Images, models | Blob (the candidate's Terraform) | Lifecycle for images; none for models |

**Quantitative probe.** If the candidate did the cloud-cost bonus, check their numbers against this table; otherwise give the inputs on the whiteboard and expect answers within about 5 minutes. They are hypothetical rates, not quotes; 1 GiB = 1,024 MiB; 30-day month.

| Question | Inputs | Answer |
|---|---|---|
| Storage, all hot 30 days | 500,000 raw images/day × 10 MiB, masks × 1 MiB; hot $0.02/GiB-month | 4,882.81 + 488.28 GiB/day × 30 = 161,132.81 GiB → **$3,222.66/month** |
| Storage, raw cool after day 7 | Cool $0.01/GiB-month | Raw hot 34,179.69 GiB $683.59 + raw cool 112,304.69 GiB $1,123.05 + masks $292.97 = **$2,099.61** → saves **$1,123.05 (34.8%)** |
| Senior follow-up | Azure cool has a 30-day minimum | Deleted after 23 days in cool → ~7 days early-deletion charge ≈ **$341.80/month** → real saving ≈ **$781**. AWS lifecycle can't move to Standard-IA before day 30 |
| Compute | 100 node-h/day; On-Demand $0.20, Spot $0.06, +20% retries | **$600** vs **$216/month** |
| Model delivery | 1.5 GiB model; 2,000 pulls/day vs 4 cache warm-ups/day | **3,000 vs 6 GiB/day**; Spot eviction loses node cache |

**Common error:** multiplying the monthly rate by 30 again (30× too high).

## Bonus grading

Candidates may attempt **at most three** bonuses. Grade only the first three listed in their EVIDENCE.md and ignore the rest. A bonus never compensates for a broken required task.

| Bonus | Good looks like | Red flag |
|---|---|---|
| Model handoff | Gate before selection; publish ≠ promote; rollback shown; digest in pipeline results; an established tool (registry, versioned object store, OCI artifacts) | Custom script reimplementing a registry; digest checked only after promotion |
| Cloud costs | Numbers match the table above; provider minimum-duration rule named; omitted costs listed | Rates × 30 twice; invented transfer prices |
| Failure recovery | Kill during aggregation, show partial state, retry gives exactly 5 rows and honest MongoDB status; explains the PostgreSQL→MongoDB gap | Only kills during inference, where upserts already make retry trivial |
| Portable storage + caching | MinIO/S3 via configuration; models selected by digest; cache reuse shown across two runs; incomplete-entry handling | Provider SDK calls in business logic; cache keyed by file name |
| Dev isolation | Per-developer namespaces/prefixes/DB records; quotas and expiry; A/B table | Ten full copies of the stack |
| Argo | kind/k3d setup reproducible; preserves image → mask → inference → aggregation order; retries and limits; logs reachable | Workflow that only wraps `run_local.py` in one step |
| Training platform | Tracking + registry with promotion separate from publication; no proprietary ML APIs in training code | Large platform deployed with no experiment actually tracked |

## Interview questions

1. Your verifier times out after 180 s. What exactly is killed, and how did you confirm nothing kept running?
2. Where does the expected digest come from, and why can't it come from the database rows?
3. Your dashboard shows the analysis container's memory. Is that the real peak? How would you know?
4. Stop the worker now. What fires, after how long, and who gets paged?
5. Raw images move to cool on day 7 and are deleted on day 30. What does your provider charge beyond the storage rate?
6. What does `terraform destroy` delete in your configuration, and how would you protect model artifacts?
7. (Topic 1) Show where a bad model would be rejected. What if that check ran after promotion?
8. (CI task) A data scientist changes only the notebook. Which workflow runs, and does the API image rebuild?
9. Live change: point the analysis at a different model file through configuration and show the new digest in the results.

## Reference solution map

| Required task | Files |
|---|---|
| Containers | [Dockerfile](../Dockerfile), [.dockerignore](../.dockerignore), [compose.yaml](../compose.yaml) |
| Verification | [tests/e2e_verify.py](../tests/e2e_verify.py) |
| Observability | [observability/](../observability/) (Prometheus, alert rules, Grafana provisioning, dashboard), exporters in `compose.yaml` |
| Terraform | [infra/](../infra/) |
| Write-ups | [EVIDENCE.md](../EVIDENCE.md), [ARCHITECTURE_AND_DECISIONS.md](../ARCHITECTURE_AND_DECISIONS.md) |
| CI workflows (required) | [.github/workflows/](../.github/workflows/) |
