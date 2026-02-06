# ------------------------------
# Stage 1: builder (сборка кеша)
# ------------------------------
FROM python:3.11-slim AS builder

# Системные зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential libffi-dev libssl-dev python3-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip install --no-cache-dir platformio

# Создание non-root пользователя
RUN useradd -m -s /bin/bash pio
USER pio
WORKDIR /home/pio

# Папки для кешей PlatformIO
RUN mkdir -p /home/pio/.platformio/lib \
             /home/pio/.platformio/packages \
             /home/pio/.platformio/platforms

ENV PLATFORMIO_HOME_DIR=/home/pio/.platformio

# Копируем проект в контейнер
WORKDIR /workspace
COPY . /workspace

# Устанавливаем локальные библиотеки и делаем сборку для кеша
RUN set -euo pipefail && \
    for lib in /workspace/lib/*; do \
        [ -d "$lib" ] || continue; \
        echo "Installing library: $lib"; \
        pio lib install "$lib"; \
    done && \
    echo "Running full build to populate cache..." && \
    pio run -v -j 4

# ------------------------------
# Stage 2: final image (оффлайн)
# ------------------------------
FROM python:3.11-slim

# Системные зависимости минимально
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl \
    && rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip install --no-cache-dir platformio

# Создание non-root пользователя
RUN useradd -m -s /bin/bash pio
USER pio
WORKDIR /home/pio

ENV PLATFORMIO_HOME_DIR=/home/pio/.platformio

# Копируем кеши из builder
COPY --from=builder /home/pio/.platformio /home/pio/.platformio

# Копируем проект (опционально)
WORKDIR /workspace
COPY --from=builder /workspace /workspace

CMD ["bash"]
