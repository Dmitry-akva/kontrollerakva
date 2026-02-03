FROM python:3.11-slim

# ⚙️ Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y git build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# ⚡ Устанавливаем PlatformIO
RUN pip install --no-cache-dir platformio

# 🗂 Рабочая папка для проекта
WORKDIR /workspace

# 📂 Копируем проект и библиотеки (lib уже в репозитории)
COPY platformio.ini ./
COPY src ./src
COPY lib ./lib

# 💾 Кэшируем PlatformIO (платформы, тулчейны, библиотеки)
RUN pio run || true

# 🔧 Командная оболочка для запуска сборки вручную
CMD ["bash"]
