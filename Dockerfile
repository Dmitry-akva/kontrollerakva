# -------- База --------
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PLATFORMIO_CORE_DIR=/root/.platformio \
    PATH="/root/.local/bin:${PATH}"

# -------- Системные зависимости (минимум) --------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# -------- Установка PlatformIO --------
RUN pip install --no-cache-dir platformio

# -------- Предустановка платформы и тулчейна ESP8266 --------
RUN pio pkg install --global \
    --platform espressif8266 \
    --tool toolchain-xtensa \
    --tool tool-esptool \
    --tool tool-mkspiffs

# -------- Создаём рабочие папки --------
RUN mkdir -p /workspace /root/.platformio/lib /root/.platformio/lib_cache

WORKDIR /workspace

# -------- Копируем локальные библиотеки --------
COPY lib/ /workspace/lib/

# -------- Инсталируем библиотеки в PIO lib cache --------
# Перечисляем все библиотеки, чтобы PIO установил их и больше не тянул из интернета
RUN pio lib install /workspace/lib/DallasTemperature \
 && pio lib install /workspace/lib/FastBot \
 && pio lib install /workspace/lib/FileData \
 && pio lib install /workspace/lib/GTimer \
 && pio lib install /workspace/lib/GyverHC595 \
 && pio lib install /workspace/lib/GyverPortal \
 && pio lib install /workspace/lib/OneWire

# -------- Тестовая "пустая" сборка, чтобы проиндексировать кеш --------
RUN echo "[env:nodemcuv2]\nplatform=espressif8266\nboard=nodemcuv2\nframework=arduino" > platformio.ini \
 && mkdir src \
 && echo "void setup(){} void loop(){}" > src/main.cpp \
 && pio run -e nodemcuv2 || true \
 && rm -rf src platformio.ini .pio

# -------- Контейнер ждёт команд --------
CMD ["tail", "-f", "/dev/null"]
