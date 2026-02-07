FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Базовые зависимости
RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Установка Arduino CLI
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh \
    && mv bin/arduino-cli /usr/local/bin/arduino-cli

# Копируем конфигурацию CLI
COPY arduino-cli.yaml /arduino-cli.yaml

# Создаём структуру каталогов заранее (чтобы попали в слой образа)
RUN mkdir -p /arduino/data /arduino/staging /arduino/user /arduino/cache

# Инициализация конфига
RUN arduino-cli config init --config-file /arduino-cli.yaml --overwrite

# Обновление индексов (с поддержкой ESP8266)
RUN arduino-cli core update-index --config-file /arduino-cli.yaml

# Установка ядра ESP8266 (скачает весь тулчейн внутрь образа)
RUN arduino-cli core install esp8266:esp8266 --config-file /arduino-cli.yaml

# Установка библиотек (git версии для оффлайна)
WORKDIR /arduino/user/libraries

RUN git clone https://github.com/GyverLibs/FastBot.git \
 && git clone https://github.com/PaulStoffregen/OneWire.git \
 && git clone https://github.com/milesburton/Arduino-Temperature-Control-Library.git DallasTemperature \
 && git clone https://github.com/GyverLibs/FileData.git \
 && git clone https://github.com/GyverLibs/GyverPortal.git \
 && git clone https://github.com/GyverLibs/GyverHC595.git \
 && git clone https://github.com/GyverLibs/GTimer.git

# Копируем тестовый скетч для прогрева кеша
WORKDIR /build
COPY sketch /build/sketch

# Предварительная компиляция (прогрев кеша тулчейна и библиотек)
RUN arduino-cli compile \
    --config-file /arduino-cli.yaml \
    --fqbn esp8266:esp8266:nodemcuv2 \
    --build-cache-path /arduino/cache \
    /build/sketch

# Дополнительный прогрев для популярных плат (ускоряет будущие сборки)
RUN arduino-cli compile \
    --config-file /arduino-cli.yaml \
    --fqbn esp8266:esp8266:d1_mini \
    --build-cache-path /arduino/cache \
    /build/sketch

RUN arduino-cli compile \
    --config-file /arduino-cli.yaml \
    --fqbn esp8266:esp8266:generic \
    --build-cache-path /arduino/cache \
    /build/sketch

# Рабочая директория по умолчанию
WORKDIR /work

CMD ["arduino-cli"]
