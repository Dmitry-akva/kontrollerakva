FROM python:3.11-slim

# Системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

WORKDIR /workspace

# Копируем проект вместе с библиотеками
COPY platformio.ini ./ 
COPY src ./src
COPY lib ./lib   # сюда попадают все библиотеки из workflow

# ⚡ Предварительная сборка для кеша PlatformIO
RUN pio run || true

CMD ["bash"]
