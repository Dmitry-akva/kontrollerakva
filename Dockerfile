FROM python:3.11-slim

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

WORKDIR /workspace

# Копируем проект
COPY platformio.ini ./
COPY src ./src
COPY lib ./lib

# Клонируем все Git-библиотеки внутрь образа
RUN mkdir -p /root/.platformio/lib && \
    git clone https://github.com/GyverLibs/FileData.git /root/.platformio/lib/FileData && \
    git clone https://github.com/GyverLibs/GyverPortal.git /root/.platformio/lib/GyverPortal && \
    git clone https://github.com/GyverLibs/GyverHC595.git /root/.platformio/lib/GyverHC595 && \
    git clone https://github.com/GyverLibs/GTimer.git /root/.platformio/lib/GTimer

# ⚡ Предварительная сборка для кеша PlatformIO
RUN pio run || true

CMD ["bash"]
