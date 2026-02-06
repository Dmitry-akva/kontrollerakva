FROM python:3.11-slim

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

# Папки кешей PlatformIO
RUN mkdir -p /home/pio/.platformio/lib /home/pio/.platformio/packages /home/pio/.platformio/platforms
ENV PLATFORMIO_HOME_DIR=/home/pio/.platformio

# Рабочая директория для проекта
WORKDIR /workspace

CMD ["bash"]
