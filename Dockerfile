# Pull an official python image
FROM python:3.13-rc-slim

# Set the working directory in the container
WORKDIR /app

# Set environment variables

# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1

# Install dependencies
COPY requirements.txt .

# Instala dependencias del sistema necesarias y luego las de Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove build-essential

# Upgrade pip and prevents keeping the cache
# RUN pip install -U pip && pip install --no-cache-dir -r requirements.txt

# Copy the project files into the working directory
COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Open the port 8000
EXPOSE 8000

# Comandos para preparar la app (equivalente a build.sh)
# RUN python manage.py collectstatic --no-input \
#     && python manage.py migrate

ENTRYPOINT ["/entrypoint.sh"]
# Comando por defecto para ejecutar el contenedor
CMD ["gunicorn", "core.asgi:application", "-k", "uvicorn.workers.UvicornWorker", "--workers", "4", "--bind", "0.0.0.0:8000"]
# Run the application with Gunicorn, a WSGI HTTP server for Python
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "core.wsgi:application"]
