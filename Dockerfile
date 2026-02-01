# Используем легкую Ubuntu
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip3 install --no-cache-dir platformio

# Создаем рабочую папку
WORKDIR /workspace

CMD ["/bin/bash"]
