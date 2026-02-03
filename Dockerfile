FROM python:3.11-slim

# Системные зависимости
RUN apt-get update && apt-get install -y \
    git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# Папка для предзагрузки
WORKDIR /opt/pio-preload

# Копируем только platformio.ini
COPY platformio.ini .

# Минимальный src (чтобы pio run сработал)
RUN mkdir -p src && printf '#include <Arduino.h>\nvoid setup(){}\nvoid loop(){}\n' > src/main.cpp

# Устанавливаем платформы, тулчейны и project lib_deps
RUN pio pkg install || true
RUN pio run || true

# Копируем кеши в «фиксированные» папки внутри образа
RUN mkdir -p /opt/pio-cache && cp -a /root/.platformio /opt/pio-cache/.platformio || true
RUN mkdir -p /opt/pio-libdeps && cp -a .pio/libdeps /opt/pio-libdeps || true

# Очистка временных файлов для уменьшения размера
RUN rm -rf /opt/pio-preload/src /opt/pio-preload/.pio/.cache/tmp || true

# Рабочая папка для CI
WORKDIR /workspace
CMD ["bash"]
