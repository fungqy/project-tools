FROM python:3.13-slim

WORKDIR /app

ENV UV_SYSTEM_PYTHON=1

RUN pip install uv

COPY pyproject.toml uv.lock ./

RUN uv pip install --system -r pyproject.toml

COPY src/ ./src/
COPY logging.conf .
COPY scripts/run.sh ./scripts/

RUN chmod +x scripts/run.sh

RUN mkdir -p logs

EXPOSE 8000

CMD ["./scripts/run.sh"]
