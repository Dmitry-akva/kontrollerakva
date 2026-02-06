FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PLATFORMIO_CORE_DIR=/platformio
ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    git build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# Создаём директорию для кеша (обязательно, чтобы слой был корректно запечён)
RUN mkdir -p /platformio

# Копируем только то, что нужно для прогрева: platformio.ini + src
WORKDIR /tmp/project
COPY platformio.ini /tmp/project/
COPY src /tmp/project/src

# ВАЖНО: запускаем pio с переменной окружения PLATFORMIO_CORE_DIR, чтобы всё пошло в /platformio
# Это скачает тулчейн, платформу, фреймворк и библиотеки, указанные в lib_deps платформы.
RUN env PLATFORMIO_CORE_DIR=/platformio pio run --project-dir /tmp/project || true

# Опционально: убедиться, что /platformio действительно заполнен (для отладки)
# RUN ls -la /platformio || true

# Очищаем временный проект (если не нужен)
RUN rm -rf /tmp/project

WORKDIR /workspace
CMD ["bash"]
