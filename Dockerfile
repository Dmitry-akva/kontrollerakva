FROM python:3.11-slim

# Отключаем интерактивные вопросы apt
ENV DEBIAN_FRONTEND=noninteractive

# Ставим системные зависимости
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# Создаём рабочую папку проекта
WORKDIR /workspace

# Чтобы PlatformIO кэш сохранялся внутри контейнера
ENV PLATFORMIO_CORE_DIR=/root/.platformio

# Команда по умолчанию — сборка проекта
CMD ["pio", "run"]
