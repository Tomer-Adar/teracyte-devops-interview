# Containerize the workloads

**Required task** · [Assignment](../../README.md) · [Starter guide](../../docs/local-development.md) · Time guide: ~1–1.5 h

## Goal

Dev needs one repeatable way to run its API, worker and analysis pipeline, the same on every laptop and in CI.

## Deliverables

| What | Where |
|---|---|
| Dockerfile(s) | Repository root or next to each service (your choice) |
| `.dockerignore` | Repository root |
| Compose services for the API, worker and analysis | `compose.yaml` (extend the supplied file) |
| The 4 commands below, with their output | EVIDENCE.md, section "Containerize" |

## Requirements

1. Compose must run three workloads using your image(s):
   - **API:** `uvicorn services.api.main:app`, reachable at `http://localhost:8000`.
   - **Worker:** the Celery worker `celery -A services.api.tasks.celery_app worker`.
   - **Analysis:** `python -m scripts.run_local --experiment-id <id>` as a **one-shot** container. It must not start with `docker compose up`. It is started on demand with `docker compose run --rm <analysis service> --experiment-id <id>`, runs once, then exits. Experiment IDs may contain only letters, digits, `_` and `-`, because the API rejects anything else.
2. One shared image with different commands is allowed. So are separate images. Your choice.
3. Every workload must get its database and broker connections from these environment variables, which the code already reads:
   - `POSTGRES_URL`
   - `MONGO_URL`
   - `CELERY_BROKER_URL`
   - `CELERY_RESULT_BACKEND`

   Set all four explicitly in Compose, using the service names and internal ports: `postgres:5432`, `mongo:27017`, `redis:6379`. You do not need to remove the code's built-in `localhost` defaults.
4. The model file used by the analysis must be selectable with an environment variable named `MODEL_PATH`, without rebuilding the image. `MODEL_PATH` is a path **inside the container**, typically a file in the shared data volume. You may edit `scripts/run_local.py` to read `MODEL_PATH`; today it always uses the path in `data/manifest.json`. When `MODEL_PATH` is unset, the generated mock model is used, as now.
5. Generated data (`data/`) must live in a Docker volume or bind mount that the API, worker and analysis share. It must be writable by the user the containers run as. Data and model files must not be inside any image. All three workloads must run with the same working directory, the directory that contains the repository code, and the shared storage must be mounted at `data/` inside it. The API and worker use the relative paths `data/objects/raw` and `data/objects/reports`.
6. `.dockerignore` must exclude at least `data/`, `.env`, `.git` and `.venv`.
7. The analysis must start only after PostgreSQL, MongoDB and Redis report healthy.
8. If any analysis step fails, the analysis container must exit with a nonzero code.
9. The API must have a Compose healthcheck that passes when `GET /openapi.json` returns HTTP 200. FastAPI serves this path already.

## Done when

Reviewers run these from a fresh clone, using the exact commands you document:

- [ ] **Build + start:** one command builds the images and starts the databases, Redis, the API and the worker. Every service with a healthcheck reports healthy, and the worker is running.
- [ ] **Analysis:** one command runs the analysis for a new experiment ID and exits 0. The first run generates the five fixture images.
- [ ] **Results + export:** `curl http://localhost:8000/experiments/<id>/results` returns status `COMPLETED` with 5 results. `curl -X POST http://localhost:8000/experiments/<id>/exports` returns `QUEUED`, and the worker writes `data/objects/reports/<id>.json`.
- [ ] **Stop:** one command stops everything. Say whether it also deletes data.
- [ ] `docker history <image>` shows no `data/` or model files.
- [ ] **Model selection:** copy another file into the data volume (for example the toy model's `model.json`), run the analysis with `MODEL_PATH` pointing to it, and the result rows show that file's SHA-256.

## Evidence to include in EVIDENCE.md

- The 4 commands (build + start, analysis, results/export, stop) and their output.
- How you read the report file (for example `docker compose exec worker cat data/objects/reports/<id>.json`).
- The model-selection run: the command with `MODEL_PATH`, the file's SHA-256 (`sha256sum`), and the matching `model_sha256` in the results.

## Not required

- Kubernetes, multiple environments, a container registry, or pushing images.
- Changing the analysis algorithm. Running the three steps in sequence inside one container is expected.
- Image-size or startup-time optimization.

## Hints (not graded)

- Inside a container, `localhost` is that container, not the database.
- `depends_on` with `condition: service_healthy` handles requirement 7.
- Non-root users, a worker healthcheck and pinned dependency versions all count as good practice in review.
