# Dockerfile: offline esp8266 platformio with full cache
FROM python:3.11-slim

# 1) Системные зависимости
RUN apt-get update && apt-get install -y \
    git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# 2) PlatformIO
RUN pip install --no-cache-dir platformio

# 3) Предзагрузка: рабочая папка
WORKDIR /opt/pio-preload

# Копируем platformio.ini, чтобы pio знал lib_deps
COPY platformio.ini .

# Нужен минимальный src, чтобы pio run отработал (LDF родит lib_deps)
RUN mkdir -p src && printf '#include <Arduino.h>\nvoid setup(){}\nvoid loop(){}\n' > src/main.cpp

# 4) Устанавливаем платформы, тулчейны и lib_deps
# pio pkg install можно использовать, но pio run гарантированно вызовет LDF и скачает project lib_deps
RUN pio pkg install || true
RUN pio run || true

# 5) Сохраняем кеши в отдельные папки в образе
RUN mkdir -p /opt/pio-cache && cp -a /root/.platformio /opt/pio-cache/ || true
RUN mkdir -p /opt/pio-libdeps && cp -a .pio/libdeps /opt/pio-libdeps/ || true

# 6) (опционально) чистим временные кеши, чтобы уменьшить образ
RUN rm -rf /opt/pio-preload/src /opt/pio-preload/.pio/.cache/tmp || true

# 7) Рабочая директория для CI
WORKDIR /workspace
CMD ["bash"]
