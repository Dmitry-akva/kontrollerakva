FROM python:3.11-slim

RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir platformio

# 👉 Папка для предзагрузки зависимостей
WORKDIR /opt/pio-preload

# Копируем только platformio.ini
COPY platformio.ini .

# Создаём фиктивный src, который подключает ВСЕ библиотеки
RUN mkdir src && printf '#include <Arduino.h>\n#include <FastBot.h>\n#include <OneWire.h>\n#include <DallasTemperature.h>\n#include <FileData.h>\n#include <GyverPortal.h>\n#include <GyverHC595.h>\n#include <GTimer.h>\nvoid setup(){}\nvoid loop(){}\n' > src/main.cpp

# 👉 Это заставит PlatformIO скачать ВСЕ библиотеки и тулчейны
RUN pio run || true

# Возвращаем рабочую папку для реальных сборок
WORKDIR /workspace

CMD ["bash"]
