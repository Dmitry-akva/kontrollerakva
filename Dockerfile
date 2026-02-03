FROM python:3.11-slim

# ⚙️ Системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# ⚡ Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# 🗂 Рабочая папка
WORKDIR /workspace

# 📂 Копируем lib и ini для кэша
COPY lib ./lib
COPY platformio.ini ./platformio.ini

# ⚡ Устанавливаем платформу и тулчейны
RUN pio platform install espressif8266@4.2.1 \
    --with-package toolchain-xtensa@2.100300.220621 \
    --with-package framework-arduinoespressif8266@3.30102.0

# ⚡ Создаём пустой main.cpp для прогрева кэша
RUN mkdir -p src && echo "void setup(){} void loop(){}" > src/main.cpp

# ⚡ Прогреваем кеш библиотек и тулчейнов за один раз через offline сборку
RUN pio run -e nodemcuv2 --offline

CMD ["bash"]
