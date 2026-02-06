FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PLATFORMIO_CORE_DIR=/platformio
ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    git build-essential \
    && rm -rf /var/lib/apt/lists/*

# Ставим PlatformIO
RUN pip install --no-cache-dir platformio

# Создаём папку заранее (важно для слоёв Docker)
RUN mkdir -p /platformio

WORKDIR /tmp/project

# Копируем ТОЛЬКО файлы, нужные для первичной сборки
COPY platformio.ini .
COPY src ./src

# 🔥 ПЕРВАЯ СБОРКА = скачивание ВСЕГО ВНУТРЬ ОБРАЗА
RUN pio run

# Удаляем временный проект, но НЕ platformio кеш
WORKDIR /
RUN rm -rf /tmp/project

WORKDIR /workspace
CMD ["bash"]
