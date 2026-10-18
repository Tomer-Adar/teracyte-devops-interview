"""End-to-end verification of one analysis run against real PostgreSQL and MongoDB.

Usage: python -m tests.e2e_verify [--experiment-id ID] [--expected-sha256 HEX] [--timeout 180]

The expected digest comes from --expected-sha256 / EXPECTED_MODEL_SHA256 (e.g. a release's
handoff metadata) or, if absent, is hashed from the selected model file *before* the run.
It is never derived from the output rows. Exit code is nonzero on any failed check.
"""

import argparse
import hashlib
import json
import os
import signal
import subprocess
import sys
import time
import uuid
from pathlib import Path

import psycopg
from pymongo import MongoClient

from scripts.generate_mock_data import generate_data

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_IMAGE_IDS = [f"image-{n:03d}" for n in range(1, 6)]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--experiment-id", default=f"e2e-{uuid.uuid4().hex[:12]}")
    parser.add_argument("--expected-sha256", default=os.getenv("EXPECTED_MODEL_SHA256") or None)
    parser.add_argument("--model-path", default=os.getenv("MODEL_PATH") or None)
    parser.add_argument("--timeout", type=float, default=float(os.getenv("E2E_TIMEOUT_SECONDS", "180")))
    args = parser.parse_args()

    postgres_url = os.getenv("POSTGRES_URL", "postgresql://starter:starter@localhost:15432/experiments")
    mongo_url = os.getenv("MONGO_URL", "mongodb://localhost:27018")

    # Fixtures and the expected digest are prepared before the timer starts.
    data_dir = ROOT / "data"
    if not (data_dir / "manifest.json").exists():
        generate_data(data_dir)
    model_path = Path(args.model_path or json.loads((data_dir / "manifest.json").read_text())["model_path"])
    expected_sha = args.expected_sha256 or sha256_file(model_path)

    # Remove stale state so an earlier run cannot satisfy the checks.
    with MongoClient(mongo_url) as mongo:
        mongo["experiments"]["experiments"].delete_one({"_id": args.experiment_id})
    with psycopg.connect(postgres_url) as conn:
        # The analysis step owns the schema; only clean up if it already exists.
        if conn.execute("SELECT to_regclass('image_metrics')").fetchone()[0]:
            conn.execute("DELETE FROM image_metrics WHERE experiment_id = %s", (args.experiment_id,))

    command = [sys.executable, "-m", "scripts.run_local", "--experiment-id", args.experiment_id,
               "--model-path", str(model_path)]
    failures: list[str] = []
    started = time.monotonic()
    # Own process group: on timeout, kill the runner *and* the step it is executing.
    process = subprocess.Popen(command, cwd=ROOT, start_new_session=True)
    try:
        if process.wait(timeout=args.timeout) != 0:
            failures.append(f"analysis exited with status {process.returncode}")
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()
        failures.append(f"analysis exceeded {args.timeout:.0f}s timeout and was terminated")
    elapsed = time.monotonic() - started

    with psycopg.connect(postgres_url) as conn:
        rows = conn.execute(
            "SELECT image_id, model_sha256 FROM image_metrics WHERE experiment_id = %s ORDER BY image_id",
            (args.experiment_id,),
        ).fetchall()
    with MongoClient(mongo_url) as mongo:
        experiment = mongo["experiments"]["experiments"].find_one({"_id": args.experiment_id}) or {}

    image_ids = [row[0] for row in rows]
    if image_ids != EXPECTED_IMAGE_IDS:
        failures.append(f"expected PostgreSQL rows {EXPECTED_IMAGE_IDS}, got {image_ids}")
    if experiment.get("status") != "COMPLETED":
        failures.append(f"expected MongoDB status COMPLETED, got {experiment.get('status')!r}")
    if experiment.get("result_count") != 5:
        failures.append(f"expected MongoDB result_count 5, got {experiment.get('result_count')!r}")
    wrong_digest = [image_id for image_id, sha in rows if sha != expected_sha]
    if wrong_digest:
        failures.append(f"model_sha256 != expected {expected_sha} for {wrong_digest}")

    print(json.dumps({
        "experiment_id": args.experiment_id,
        "result": "PASS" if not failures else "FAIL",
        "elapsed_seconds": round(elapsed, 2),
        "timeout_seconds": args.timeout,
        "rows": len(rows),
        "mongo_status": experiment.get("status"),
        "expected_model_sha256": expected_sha,
        "failures": failures,
    }, indent=2))
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
