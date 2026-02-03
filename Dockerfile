FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir platformio

ENV PLATFORMIO_CORE_DIR=/root/.platformio

# Временный проект для прогрева кэша
WORKDIR /tmp/project

COPY platformio.ini ./
COPY src ./src
COPY lib ./lib

# 🔥 Полная сборка проекта = кэш платформ + библиотек
RUN pio run -e nodemcuv2

# 👉 Сохраняем проектные зависимости отдельно
RUN mkdir -p /opt/pio-deps && cp -r .pio/libdeps /opt/pio-deps

# Рабочая папка для реальной сборки
WORKDIR /workspace

# При запуске контейнера подсовываем уже скачанные библиотеки
ENV PLATFORMIO_LIBDEPS_DIR=/opt/pio-deps

CMD ["bash"]
