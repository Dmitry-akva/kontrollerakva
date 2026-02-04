# Базовый образ с Python и необходимыми инструментами
FROM python:3.11-slim

# Устанавливаем системные зависимости для PlatformIO и сборки ESP8266
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN python3 -m pip install --upgrade pip setuptools wheel \
    && pip install platformio

# Создаём папки для кеша и библиотек
RUN mkdir -p /root/.platformio/lib /root/.platformio/packages /workspace

# Устанавливаем рабочую директорию
WORKDIR /workspace

# Копируем локальные библиотеки (lib/) в рабочую папку
# Если хочешь, можно добавить COPY src/ и platformio.ini, но обычно монтируем весь репозиторий при run
# COPY lib/ /workspace/lib/

# Экспортим кэш PlatformIO (опционально, для документации)
VOLUME ["/root/.platformio"]

# По умолчанию контейнер просто ждёт команду
CMD ["tail", "-f", "/dev/null"]
