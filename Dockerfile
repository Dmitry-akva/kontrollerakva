# Используем лёгкий Python-образ
FROM python:3.11-slim

# Устанавливаем необходимые системные пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl unzip build-essential libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN python3 -m pip install --upgrade pip setuptools wheel \
    && pip install platformio

# Предустанавливаем платформу ESP8266 (Arduino + toolchain)
RUN pio platform install espressif8266

# Создаём папки для кеша и библиотек
RUN mkdir -p /root/.platformio/lib /root/.platformio/packages /workspace

# Устанавливаем рабочую директорию
WORKDIR /workspace

# Копируем локальные библиотеки lib/ в рабочую директорию
COPY lib/ /workspace/lib/

# Контейнер просто ждёт команды
CMD ["tail", "-f", "/dev/null"]
