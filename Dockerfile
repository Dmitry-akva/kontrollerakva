FROM python:3.11-slim

# ⚙️ Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# ⚡ Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# 🗂 Рабочая папка
WORKDIR /workspace

# 📂 Копируем lib и platformio.ini для кеша библиотек
COPY lib ./lib
COPY platformio.ini ./platformio.ini

# ⚡ Устанавливаем платформу и тулчейны
RUN pio platform install espressif8266@4.2.1 \
    --with-package toolchain-xtensa@2.100300.220621 \
    --with-package framework-arduinoespressif8266@3.30102.0

# ⚡ Прогреваем кеш библиотек offline
RUN pio lib install --offline

# ⚡ Прогоняем первичную сборку (тестовая компиляция)
#     Если src/ нет, создадим пустой пример, чтобы PIO мог собрать
RUN mkdir -p src && echo "void setup(){} void loop(){}" > src/main.cpp
RUN pio run -e nodemcuv2 --offline

CMD ["bash"]
