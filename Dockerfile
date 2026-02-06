# Dockerfile
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PLATFORMIO_CORE_DIR=/platformio
ENV PATH="/root/.local/bin:$PATH"

# Устанавливаем зависимости для сборки
RUN apt-get update && apt-get install -y \
    git build-essential ca-certificates curl unzip \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# Создаём кеш-директорию для PlatformIO
RUN mkdir -p /platformio

# Копируем проект для прогрева кеша
WORKDIR /tmp/project
COPY platformio.ini /tmp/project/
COPY src /tmp/project/src

# Прогреваем кеш PlatformIO: тулчейн, фреймворк и все библиотеки из lib_deps
RUN env PLATFORMIO_CORE_DIR=/platformio pio run --project-dir /tmp/project || true

# Чистим временный проект, оставляем кеш
RUN rm -rf /tmp/project

WORKDIR /workspace
CMD ["bash"]
