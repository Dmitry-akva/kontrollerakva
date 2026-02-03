FROM python:3.11-slim

# Системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl unzip \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# Пусть PlatformIO хранит кэш в стандартном месте
ENV PLATFORMIO_CORE_DIR=/root/.platformio

# Временная рабочая директория для прогрева кэша
WORKDIR /tmp/project

# Копируем то, что нужно PIO чтобы понять зависимости
COPY platformio.ini ./
COPY src ./src
# Если у тебя локальные библиотеки в repo/lib, копируем их тоже
COPY lib ./lib

# Устанавливаем платформу/тулчейн/фреймворк (пример для espressif8266)
# (можно убрать версии или подставить свои)
RUN pio platform install espressif8266@4.2.1 \
    --with-package toolchain-xtensa@2.100300.220621 \
    --with-package framework-arduinoespressif8266@3.30102.0

# Скачиваем библиотеки, перечисленные в platformio.ini (lib_deps)
# НЕ используем --offline здесь — в процессе сборки у образа должен быть интернет
RUN pio lib install

# Прогоняем реальную сборку указанного env, чтобы PlatformIO сделал полный кеш
# Заменить nodemcuv2 на твой env, если он называется иначе
RUN pio run -e nodemcuv2 -v || true

# (Опционально) скопировать проектные libdeps в /opt/pio-deps для удобства
RUN mkdir -p /opt/pio-deps && cp -r .pio/libdeps /opt/pio-deps || true

# Чистим временные исходники, если не хотим хранить src в образе
RUN rm -rf /tmp/project/src

# Работаем в /workspace по умолчанию — сюда будем монтировать реальный код при запуске
WORKDIR /workspace

CMD ["bash"]
