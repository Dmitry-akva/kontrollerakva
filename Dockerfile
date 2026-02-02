FROM python:3.11-slim

# Устанавливаем зависимости для сборки прошивки
RUN apt-get update && \
    apt-get install -y git wget unzip build-essential && \
    rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip install platformio

# Копируем кэш PlatformIO из workflow
COPY local_cache/.platformio /root/.platformio

# Рабочая папка для проекта
WORKDIR /workspace

CMD ["bash"]
