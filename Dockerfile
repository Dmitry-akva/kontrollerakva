# Dockerfile для ESP8266 + PlatformIO
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip3 install --no-cache-dir platformio

# Рабочая директория
WORKDIR /workspace

CMD ["/bin/bash"]
