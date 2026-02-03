FROM python:3.11-slim

# Системные зависимости
RUN apt-get update && apt-get install -y \
    git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# -----------------------------
# Предзагрузка зависимостей PIO
# -----------------------------
WORKDIR /opt/pio-preload

# Копируем только конфиг проекта
COPY platformio.ini .

# Устанавливаем платформы и ВСЕ библиотеки из lib_deps
RUN pio pkg install

# (опционально) сразу ставим платформу явно — ускоряет будущие билды
RUN pio platform install espressif8266

# -----------------------------
# Рабочая директория для CI сборок
# -----------------------------
WORKDIR /workspace

CMD ["bash"]
