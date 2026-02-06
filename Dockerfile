FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PLATFORMIO_CORE_DIR=/platformio

RUN apt-get update && apt-get install -y \
    git build-essential \
    && rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip install --no-cache-dir platformio

WORKDIR /workspace
COPY . /workspace

# Первичная сборка = скачивание ВСЕГО + прогрев кэша
RUN pio run

CMD ["bash"]
