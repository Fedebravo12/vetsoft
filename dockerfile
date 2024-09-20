FROM python:3.11-slim as builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Instalar gcc y python3-dev para compilar dependencias como psutil
RUN apt-get update && apt-get install -y gcc python3-dev

COPY requirements.txt .

RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

RUN pip install --no-cache /wheels/*

COPY . .

RUN ["python", "manage.py", "migrate"]

EXPOSE 8000

CMD ["gunicorn", "--bind", ":8000", "--workers", "2", "vetsoft.wsgi"]
