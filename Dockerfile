FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV ARDUINO_CONFIG_FILE=/arduino-cli.yaml

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Arduino CLI ---
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
RUN mv bin/arduino-cli /usr/local/bin/arduino-cli

# --- Config ---
COPY arduino-cli.yaml /arduino-cli.yaml

# --- Инициализация ---
RUN arduino-cli config init --overwrite \
 && arduino-cli config dump

# --- Обновляем индексы и ставим ядро ESP8266 ---
RUN arduino-cli core update-index \
 && arduino-cli core install esp8266:esp8266

# --- Папка для библиотек ---
WORKDIR /arduino/user/libraries

# --- Установка библиотек из Git ---
RUN git clone https://github.com/GyverLibs/FastBot.git \
 && git clone https://github.com/PaulStoffregen/OneWire.git \
 && git clone https://github.com/milesburton/Arduino-Temperature-Control-Library.git \
 && git clone https://github.com/GyverLibs/FileData.git \
 && git clone https://github.com/GyverLibs/GyverPortal.git \
 && git clone https://github.com/GyverLibs/GyverHC595.git \
 && git clone https://github.com/GyverLibs/GTimer.git

# --- Копируем тестовый скетч ---
WORKDIR /build
COPY sketch /build/sketch

# --- Прогрев кеша компиляции ---
RUN arduino-cli compile \
    --fqbn esp8266:esp8266:nodemcuv2 \
    --build-cache-path /arduino/cache \
    /build/sketch

# Теперь внутри образа есть:
# ✔ ядро
# ✔ тулчейны
# ✔ библиотеки
# ✔ кеш компиляции
