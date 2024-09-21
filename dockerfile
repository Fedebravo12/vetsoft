# Fase de construcción para instalar las dependencias
FROM python:3.11-slim as builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instalar gcc y python3-dev para compilar dependencias
RUN apt-get update && apt-get install -y gcc python3-dev

COPY requirements.txt .

RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Fase final: Construir la imagen final para ejecutar la app
FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

RUN pip install --no-cache /wheels/*

# Copiar el resto del código de la aplicación
COPY . .

# Ejecutar migraciones automáticamente al iniciar el contenedor
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

# Exponer el puerto 8000
EXPOSE 8000
