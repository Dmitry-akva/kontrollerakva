FROM python:3.11-slim

# Установка системных зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential libffi-dev libssl-dev python3-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip install --no-cache-dir platformio

# Non-root пользователь
RUN useradd -m -s /bin/bash pio
USER pio
WORKDIR /home/pio

# Кеши PlatformIO
RUN mkdir -p /home/pio/.platformio/lib \
             /home/pio/.platformio/packages \
             /home/pio/.platformio/platforms
ENV PLATFORMIO_HOME_DIR=/home/pio/.platformio

# Копируем весь проект (исходники + lib + platformio.ini)
WORKDIR /workspace
COPY . /workspace

# -------------------------------
# Прогрев кеша: установка всех локальных библиотек и сборка
# -------------------------------
RUN set -euo pipefail && \
    for lib in /workspace/lib/*; do \
        [ -d "$lib" ] || continue; \
        echo "Installing library: $lib"; \
        pio lib install "$lib"; \
    done && \
    echo "Running full build to populate cache..." && \
    pio run -v -j 4
