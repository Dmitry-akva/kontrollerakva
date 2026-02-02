# Базовый образ Python
FROM python:3.11-slim

# Системные зависимости для сборки прошивки
RUN apt-get update && \
    apt-get install -y git wget unzip build-essential && \
    rm -rf /var/lib/apt/lists/*

# Установка PlatformIO
RUN pip install platformio

# Рабочая папка для проекта
WORKDIR /workspace

# Контейнер запускается интерактивно, PlatformIO сам скачает тулчейны и библиотеки при первом run
CMD ["bash"]
