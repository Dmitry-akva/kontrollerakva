FROM python:3.11-slim

# ⚙️ Системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# ⚡ Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# 🗂 Рабочая папка
WORKDIR /workspace

COPY platformio.ini ./
COPY src ./src
COPY lib ./lib

# ⚡ Кэшируем платформы и тулчейны
RUN pio platform install espressif8266@4.2.1 --with-package toolchain-xtensa@2.100300.220621 --with-package framework-arduinoespressif8266@3.30102.0

# ⚡ Прогрев кэша библиотек
RUN pio lib install --offline

CMD ["bash"]
