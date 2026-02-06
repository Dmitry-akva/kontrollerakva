FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PLATFORMIO_CORE_DIR=/platformio
ENV PIO_LIB_DIR=/platformio/lib
ENV PATH="/root/.local/bin:$PATH"

# Устанавливаем зависимости для PlatformIO и ESP8266
RUN apt-get update && \
    apt-get install -y git build-essential ca-certificates curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# Создаём кешевые директории
RUN mkdir -p /platformio /platformio/lib

# Рабочая директория временного проекта для прогрева кеша
WORKDIR /tmp/project

# Копируем конфиг и исходники проекта для прогрева библиотек
COPY platformio.ini /tmp/project/
COPY src /tmp/project/src

# Прогреваем кеш: тулчейн, платформу, framework и все библиотеки из lib_deps
RUN env PLATFORMIO_CORE_DIR=/platformio PIO_LIB_DIR=/platformio/lib pio run || true

# Опционально можно удалить исходники временного проекта, оставляем только кеш
RUN rm -rf /tmp/project

# Рабочая директория для конечного пользователя контейнера
WORKDIR /workspace
CMD ["bash"]
