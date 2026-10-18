# One shared runtime for Dev's API, Celery worker and analysis steps.
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
WORKDIR /app

COPY requirements-local.txt ./
COPY services/api/requirements.txt services/api/
COPY pipelines/steps/preprocess/requirements.txt pipelines/steps/preprocess/
COPY pipelines/steps/ml_infer/requirements.txt pipelines/steps/ml_infer/
COPY pipelines/steps/db_update/requirements.txt pipelines/steps/db_update/
RUN pip install -r requirements-local.txt

COPY . .
# data/ is excluded from the build context; it is a mounted volume at runtime.
RUN useradd --create-home --uid 10001 app && mkdir -p data && chown app:app data
USER app

CMD ["python", "-m", "uvicorn", "services.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
