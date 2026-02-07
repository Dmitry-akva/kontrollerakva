FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV ARDUINO_DIRECTORIES_DATA=/arduino/data
ENV ARDUINO_DIRECTORIES_DOWNLOADS=/arduino/staging
ENV ARDUINO_DIRECTORIES_USER=/arduino/user

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Arduino CLI
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh \
    && mv bin/arduino-cli /usr/local/bin/arduino-cli

# Копируем готовый конфиг (НЕ делаем config init!)
COPY arduino-cli.yaml /arduino-cli.yaml

# Создаём каталоги заранее
RUN mkdir -p /arduino/data /arduino/staging /arduino/user /arduino/cache

# Проверяем что ESP8266 индекс доступен
RUN arduino-cli core update-index --config-file /arduino-cli.yaml \
 && arduino-cli core search esp8266 --config-file /arduino-cli.yaml

# Ставим ядро ESP8266
RUN arduino-cli core install esp8266:esp8266 --config-file /arduino-cli.yaml

# Библиотеки
WORKDIR /arduino/user/libraries

RUN git clone https://github.com/GyverLibs/FastBot.git \
 && git clone https://github.com/PaulStoffregen/OneWire.git \
 && git clone https://github.com/milesburton/Arduino-Temperature-Control-Library.git DallasTemperature \
 && git clone https://github.com/GyverLibs/FileData.git \
 && git clone https://github.com/GyverLibs/GyverPortal.git \
 && git clone https://github.com/GyverLibs/GyverHC595.git \
 && git clone https://github.com/GyverLibs/GTimer.git

# Тестовый скетч
WORKDIR /build
COPY sketch /build/sketch

# Прогрев кеша компиляции
RUN arduino-cli compile \
    --config-file /arduino-cli.yaml \
    --fqbn esp8266:esp8266:nodemcuv2 \
    --build-cache-path /arduino/cache \
    /build/sketch

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

WORKDIR /work
CMD ["arduino-cli"]
