# Evidence

**Clean run, 2026-10-18 ~17:10.** A fresh `git clone` of this branch into a different directory: a new virtualenv, no images, no volumes, no `data/`. Environment: WSL2 (Linux 6.18), Docker 29.7 / Compose v5.3 (Docker Desktop engine), Python 3.11.15. Terraform ran through the `hashicorp/terraform:1.9` image. All outputs are real; long JSON is trimmed with `…`.

## Containerize

```bash
docker compose up -d --build --wait                                # databases, Redis, API, worker
docker compose run --rm analysis --experiment-id <id>               # one-shot analysis
docker compose --profile observability up -d --wait                # adds monitoring (see Observability)
docker compose --profile observability down -v                     # stop; -v also deletes data and metrics volumes
```

```
$ docker compose up -d --build --wait
exit=0 (44s)
$ docker compose ps --format '{{.Service}}: {{.Status}}'
api: Up 3 seconds (healthy)
mongo: Up 7 seconds (healthy)
postgres: Up 7 seconds (healthy)
redis: Up 7 seconds (healthy)
worker: Up 3 seconds
$ docker compose exec -T api id
uid=10001(app) gid=10001(app) groups=10001(app)
$ docker compose run --rm analysis --experiment-id demo-container
{"experiment_id": "demo-container", "written": 5}
{"experiment_id": "demo-container", "image_count": 5, "status": "COMPLETED"}
exit=0
$ curl -s localhost:8000/experiments/demo-container/results
COMPLETED 5 results; first: {'image_id': 'image-001', 'foreground_fraction': 0.501758, 'mean_intensity': 191.511, 'model_sha256': '70b292c8…cbf95f'}
$ curl -s -X POST localhost:8000/experiments/demo-container/exports
{"task_id":"3ac2cb9f-2c61-4faa-8851-358ef586726e","status":"QUEUED"}
$ docker compose exec -T worker cat data/objects/reports/demo-container.json | head -4
{
  "experiment_id": "demo-container",
  "results": [
    {
$ docker history --no-trunc teracyte-starter:local | grep -cE 'data/|\.weights'
0
```

**Model selection with `MODEL_PATH`** (the toy model, trained inside the data volume):

```
$ docker compose run --rm --entrypoint python analysis -m examples.model_lifecycle.train --output-dir data/model-lifecycle
{"baseline_test_mse": 2.6468672472, …, "test_mse": 0.000111415, …}
$ docker compose run --rm --entrypoint sha256sum analysis data/model-lifecycle/model.json
40bfe02753cb2b202f626f9d672dc49be7f780d7b17542cb9b8986604d48b10f  data/model-lifecycle/model.json
$ MODEL_PATH=/app/data/model-lifecycle/model.json docker compose run --rm analysis --experiment-id model-select
{"experiment_id": "model-select", "image_count": 5, "status": "COMPLETED"}
$ curl -s localhost:8000/experiments/model-select/results   # distinct model_sha256 values
['40bfe02753cb2b202f626f9d672dc49be7f780d7b17542cb9b8986604d48b10f']
```

## Verify

Command: `docker compose run --rm verify`. Inputs: `MODEL_PATH`, `EXPECTED_MODEL_SHA256`, `E2E_TIMEOUT_SECONDS` (default 180), `E2E_EXPERIMENT_ID`.

```
$ docker compose run --rm verify
{ "experiment_id": "e2e-49f81832628c", "result": "PASS", "elapsed_seconds": 8.01, "timeout_seconds": 180.0,
  "rows": 5, "mongo_status": "COMPLETED",
  "expected_model_sha256": "70b292c8f995c6aa958263c61bbfd4a96a3334466f78b158f7f5015035cbf95f", "failures": [] }
exit=0
$ docker compose run --rm verify          # second run in a row
  "experiment_id": "e2e-080093682f6f", "result": "PASS"
exit=0
$ EXPECTED_MODEL_SHA256=<64 zeros> docker compose run --rm verify      # deliberate failure
{ "experiment_id": "e2e-2268309da3a2", "result": "FAIL", "elapsed_seconds": 7.85, "rows": 5, "mongo_status": "COMPLETED",
  "failures": ["model_sha256 != expected 0000…0000 for ['image-001', 'image-002', 'image-003', 'image-004', 'image-005']"] }
exit=1
$ E2E_TIMEOUT_SECONDS=2 docker compose run --rm verify
  "failures": [
    "analysis exceeded 2s timeout and was terminated",
    "expected PostgreSQL rows ['image-001', …, 'image-005'], got []",
exit=1
$ docker ps --filter name=verify --filter name=analysis --format '{{.Names}}'     # leftovers after timeout
(none)
```

## Observability

```
$ docker compose --profile observability up -d --wait
exit=0
$ curl -s localhost:9090/api/v1/targets          # job=health
api=up, cadvisor=up, celery=up, mongo=up, postgres=up, prometheus=up, redis=up
promql: probe_success{job="api"}                         ['1']            # M1
promql: probe_duration_seconds{job="api"}                ['0.001812506']  # M1
promql: celery_queue_length{queue_name="celery"}         ['0']            # M2
promql: sum(celery_worker_up)                            ['1']            # M2
promql: pg_up / mongodb_up / redis_up                    ['1'] ['1'] ['1'] # M4
$ curl -s 'localhost:3000/api/search?type=dash-db'
[('Experiment platform', 'Experiment platform')]
$ curl -s localhost:3000/api/dashboards/uid/experiment-platform     # panels
['Service health', 'API probe latency', 'Export queue and workers', 'Memory working set by service', 'CPU by service', 'Celery tasks by state (rate)']
$ curl -s -u admin:admin localhost:3000/api/datasources/uid/prometheus/health
{"message":"Successfully queried the Prometheus API.","status":"OK"}
$ curl -s localhost:9090/api/v1/rules
ApiDown:ok ExportQueueStuck:ok DependencyDown:ok ScrapeTargetDown:ok AnalysisMemoryNearLimit:ok
```

**Alert A (exports queued, no worker alive) fires and clears:**

```
$ docker compose run --rm analysis --experiment-id obs-demo
{"experiment_id": "obs-demo", "image_count": 5, "status": "COMPLETED"}
17:12:51 $ docker compose stop worker
$ curl -s -X POST localhost:8000/experiments/obs-demo/exports
{"task_id":"502b4ccf-…","status":"QUEUED"}
17:12:54 (+0s)  alerts: (no alerts)
17:12:59 (+5s)  alerts: ExportQueueStuck=pending
17:13:30 (+36s) alerts: ExportQueueStuck=firing
17:13:30 $ docker compose start worker
17:13:41 (+10s) alerts: (no alerts)
$ docker compose exec -T worker ls data/objects/reports/
demo-container.json
obs-demo.json                      # the queued export ran after recovery
```

**M3 (per-container CPU/memory).** On this clean run, cAdvisor's container series had **no Docker labels**, so the M3 panels were empty. This machine runs two Docker engines in one WSL distro: the native `dockerd` and Docker Desktop's WSL integration. cAdvisor reads the host's `/var/run`, where Desktop's `docker.sock` sits next to the native engine's `containerd.sock`, and it cannot match containers across the two (`rpc error: NotFound`). Earlier today, on the native engine alone, the same configuration labelled all 13 containers:

```
# native engine, 15:20 run
$ promql: count(container_memory_working_set_bytes{container_label_com_docker_compose_project="teracyte-devops-interview"})
['13']
$ promql: max_over_time(max(container_memory_working_set_bytes{container_label_com_docker_compose_service="analysis"})[2m:5s])
analysis peak working set MiB: [5]
```

**Analysis memory: scraped vs. real.** The scrape above saw 5 MiB. The kernel's own counter for the same 5-image run shows the real peak:

```
$ docker compose run --rm --entrypoint sh analysis -c 'python -m scripts.run_local --experiment-id mem-peak >/dev/null && cat /sys/fs/cgroup/memory.peak'
memory.peak MiB: 204         # clean run (an earlier run measured 254 MiB)
```

A ~7 s run peaks between 5 s scrapes, so the dashboard understates memory by 40–50×. The 512 MiB analysis limit is set from the cgroup figure, not the dashboard.

## CI

The workflows are `.github/workflows/ci-core-dev.yml` and `ci-data-ml.yml`. **They have not run on GitHub; nothing was pushed.** These are the same commands, run locally in the fresh clone:

```
$ actionlint                                        exit=0
$ promtool check config observability/prometheus/prometheus.yml
 SUCCESS: /etc/prometheus/prometheus.yml is valid prometheus config file syntax
  SUCCESS: 5 rules found                            exit=0
$ jq empty observability/grafana/dashboards/*.json  exit=0
$ python -m examples.model_lifecycle.train --output-dir candidate
{"baseline_test_mse": 2.6468672472, …, "test_mse": 0.000111415, …}
$ jq -e '.test_mse <= 0.001 and .test_mse < .baseline_test_mse' candidate/evaluation.json     # gate
true                                                exit=0
$ jq -e '.test_mse <= 0.0001 and .test_mse < .baseline_test_mse' candidate/evaluation.json    # lowered gate
false                                               exit=1
$ sha256sum candidate/model.json
40bfe02753cb2b202f626f9d672dc49be7f780d7b17542cb9b8986604d48b10f  candidate/model.json
```

## Terraform

```
$ terraform fmt -check -recursive                   exit=0
$ terraform init -backend=false -input=false
- Installing hashicorp/azurerm v4.81.0...
Terraform has been successfully initialized!        exit=0
$ terraform validate
Success! The configuration is valid.                exit=0
$ git ls-files infra
infra/.terraform.lock.hcl  infra/main.tf  infra/outputs.tf  infra/terraform.tfvars.example  infra/variables.tf  infra/versions.tf
```

**Not run:** `az login && terraform plan -var-file=terraform.tfvars -out=tfplan && terraform apply tfplan`. Clean-up would be `terraform destroy -var-file=terraform.tfvars`, which **also deletes model artifacts**.

## Bonuses attempted

None. This is the reference for the required tasks.

## Issue I hit

1. **A timeout left the step running.** `subprocess.run(timeout=…)` killed only the runner. The current preprocess or inference step kept running and printed output after the failure was reported. **Fix:** start the runner in its own process group and kill the group (`os.killpg`). **Verified:** with `E2E_TIMEOUT_SECONDS=2`, no step output follows the failure, and no `verify` or `analysis` containers remain.
2. **The dashboard depended on the clone directory.** Panels filter on the Compose project label, which Compose takes from the directory name. **Fix:** set `name: teracyte-devops-interview` in `compose.yaml`. **Verified:** this clean run used a differently named directory, and the API, queue and dependency metrics resolved.
3. **CI could hide failures.** GitHub steps without an explicit shell lack `pipefail`, so `verify | tee` would pass. **Fix:** `defaults.run.shell: bash`.

## Setup limits

- GitHub Actions never ran (nothing was pushed); only the local replay above.
- M3 container metrics are missing on hosts that run two Docker engines in one WSL distro; see Observability. They work on a single engine.
- No Grafana screenshot (no renderer available); the dashboard is shown through the Grafana API.
- The Terraform lock file has linux_amd64 hashes only. On macOS, run `terraform providers lock -platform=darwin_arm64 -platform=linux_amd64`.
- No cloud `plan` or `apply`.
