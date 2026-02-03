FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir platformio

WORKDIR /workspace

COPY platformio.ini ./
COPY src ./src
COPY lib ./lib

# Предзагрузка всего (платформы, тулчейна, библиотек)
RUN pio run || true

CMD ["bash"]
