# Evidence

Environment: WSL2 (Linux 6.18), Docker Desktop 29.7 / Compose v5.3, Python 3.11.15. Terraform isn't installed on this host, so it ran through the `hashicorp/terraform:1.9` image. All outputs below are real; long JSON is trimmed with `…`.

**Capture note.** Sections 1–4 come from runs on 2026-10-18 between 15:19 and 15:25. Docker Desktop's engine then restarted on the host, outside this work, and left stale port forwards, so a final full re-capture couldn't complete. The Section 1 container outputs and the Section 5 Terraform outputs come from the earlier reference snapshot. Since then, `Dockerfile`, `infra/` and `tests/e2e_verify.py` haven't changed (`git diff reference-solution -- infra tests/e2e_verify.py Dockerfile` is empty). `compose.yaml` only gained the monitoring services, the worker's `-E` flag and the analysis memory limit, and dropped an unused bind mount.

## 1. Containerized workloads

```bash
docker compose up -d --build --wait                                   # postgres, mongo, redis, api, worker
docker compose run --rm analysis --experiment-id demo-container        # one-shot; generates fixtures in the app-data volume
docker compose --profile observability up -d --wait                   # adds monitoring (section 3)
docker compose --profile observability down -v                        # -v also removes data and metrics volumes
```

```
$ python -m pytest -q
6 passed in 0.25s
$ docker compose exec -T api id
uid=10001(app) gid=10001(app) groups=10001(app)
$ docker compose run --rm analysis --experiment-id demo-container
{"experiment_id": "demo-container", "written": 5}
{"experiment_id": "demo-container", "image_count": 5, "status": "COMPLETED"}
exit=0
$ curl -s localhost:8000/experiments/demo-container/results
COMPLETED 5 rows {'image_id': 'image-001', 'foreground_fraction': 0.501758, 'mean_intensity': 191.511, 'model_sha256': '70b292c8…cbf95f'}
$ curl -s -X POST localhost:8000/experiments/demo-container/exports
{"task_id":"18ff5e95-540c-40f3-97a5-ea2a1325fe41","status":"QUEUED"}
$ docker compose exec -T worker ls -l data/objects/reports
-rw-r--r-- 1 app app 1082 Oct 18 11:53 demo-container.json
```

The model is selected with `MODEL_PATH` (or `--model-path`), with no rebuild. Dependencies are gated with `depends_on: condition: service_healthy`. A failing step propagates to a nonzero container exit.

## 2. Verify an experiment

Command: `docker compose run --rm verify [--expected-sha256 HEX] [--timeout 180]`.

```
$ docker compose run --rm verify
  "result": "PASS",
  "elapsed_seconds": 8.06,
  "expected_model_sha256": "70b292c8f995c6aa958263c61bbfd4a96a3334466f78b158f7f5015035cbf95f",
exit=0

$ docker compose run --rm verify --expected-sha256 0000…0000      # deliberate failure: wrong digest (64 zeros)
  "result": "FAIL",
  "failures": ["model_sha256 != expected 0000…0000 for ['image-001', …, 'image-005']"]
exit=1

$ docker compose run --rm verify --timeout 2
    "analysis exceeded 2s timeout and was terminated",
exit=1
```

## 3. Observability

```
$ docker compose --profile observability up -d --build --wait     # from clean (down -v, no data/)
 Container …-mongodb-exporter-1 Healthy · …-postgres-exporter-1 Healthy · …-redis-exporter-1 Healthy
 Container …-prometheus-1 Healthy · …-celery-exporter-1 Healthy · …-blackbox-exporter-1 Healthy
 Container …-cadvisor-1 Healthy · …-api-1 Healthy · …-grafana-1 Healthy
exit=0

$ curl -s localhost:9090/api/v1/targets          # job → health
api=up, cadvisor=up, celery=up, mongo=up, postgres=up, prometheus=up, redis=up

$ promql: probe_success{job="api"} → 1 · sum(celery_worker_up) → 1 · celery_queue_length → 0 · pg_up / mongodb_up / redis_up → 1
$ promql: count(container_memory_working_set_bytes{container_label_com_docker_compose_project="teracyte-devops-interview"}) → 13

$ curl -s 'localhost:3000/api/search?type=dash-db'              # provisioned, no clicks
[('Experiment platform', 'Experiment platform')]
$ curl -s -u admin:admin localhost:3000/api/datasources/uid/prometheus/health
{"message":"Successfully queried the Prometheus API.","status":"OK"}

$ promtool check config /etc/prometheus/prometheus.yml   → SUCCESS: 5 rules found
$ curl -s localhost:9090/api/v1/rules → ApiDown:ok ExportQueueStuck:ok DependencyDown:ok ScrapeTargetDown:ok AnalysisMemoryNearLimit:ok
```

**Alert fires and resolves.** `ExportQueueStuck` means exports are queued but no worker is alive:

```
15:22:29 $ docker compose stop worker
$ curl -s -X POST localhost:8000/experiments/obs-demo/exports      # ×2
{"task_id":"74cb4f3f-…","status":"QUEUED"}
{"task_id":"772916c2-…","status":"QUEUED"}
15:22:37 alerts: none
15:22:42 alerts: ExportQueueStuck=pending
15:23:09 alerts: ExportQueueStuck=firing
$ docker compose start worker
15:23:25 alerts: ExportQueueStuck=firing
15:23:30 alerts: none
$ docker compose exec -T worker ls data/objects/reports/
obs-demo.json                                                     # the queued export ran after recovery
```

**Batch memory: what Prometheus sees vs. the truth.** This is the issue I hit, and how I verified the fix:

```
$ promql: max_over_time(max(container_memory_working_set_bytes{container_label_com_docker_compose_service="analysis"})[2m:5s])
analysis peak working set MiB: [5]

$ docker compose run --rm --entrypoint sh analysis -c 'python -m scripts.run_local --experiment-id mem-peak >/dev/null && cat /sys/fs/cgroup/memory.peak'
memory.peak MiB: 254
```

The analysis run lasts about 7 s, so 5 s scrapes and 5 s cAdvisor housekeeping missed its peak by 50×. The fix:
- Size from the cgroup's `memory.peak`, not the dashboard: `mem_limit: 512m`, about 2× headroom.
- Re-ran the analysis under the limit: `{"experiment_id": "limit-check", … "status": "COMPLETED"}`, exit 0.
- Changed the memory alert to "above 80% of limit". It only catches sustained pressure; an OOM kill shows as exit 137 and a failed verification.

## 4. CI (reference for the interview discussion)

`actionlint` passes on both workflows (exit 0). The Data/ML gate was replayed locally:

```
$ python -m examples.model_lifecycle.train --output-dir candidate
$ jq -e '.test_mse <= 0.001 and .test_mse < .baseline_test_mse' candidate/evaluation.json
true
$ jq -e '.test_mse <= 0.0001' candidate/evaluation.json              # stricter gate rejects
false
exit=1
```

The workflows have not run on GitHub; nothing was pushed.

## 5. Terraform (Azure storage)

```
$ cd infra
$ terraform fmt -check -recursive        # exit 0, no output
$ terraform init -backend=false -input=false
- Installing hashicorp/azurerm v4.81.0...
Terraform has been successfully initialized!
$ terraform validate
Success! The configuration is valid.
```

Example inputs are in `infra/terraform.tfvars.example`. To deploy (not done; needs an authorized subscription): `az login && terraform init && terraform plan -var-file=terraform.tfvars -out=tfplan && terraform apply tfplan`. To clean up: `terraform destroy -var-file=terraform.tfvars`, which **also deletes model artifacts**.

## Other issues found and fixed

1. **A timeout left the step running.** `subprocess.run(timeout=…)` killed only the runner, and preprocessing kept printing after the reported failure. Fix: a dedicated process group plus `os.killpg`. Verified with `--timeout 2`: no step output after the failure, no leftover containers.
2. **CI could hide failures.** Without `shell: bash`, GitHub runs steps without `pipefail`, so `verify | tee` would pass. Fix: `defaults.run.shell: bash`.

## Setup limits / not done

- No cloud deployment, `plan` or `apply`, and no GitHub Actions run.
- No Grafana screenshot (no renderer available); the provisioned dashboard and datasource are shown through the Grafana API.
- The Terraform lock file has linux_amd64 hashes only. On macOS, run `terraform providers lock -platform=darwin_arm64 -platform=linux_amd64`.
