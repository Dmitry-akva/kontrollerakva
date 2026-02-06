# Dockerfile - offline PlatformIO image with local libs installed into PIO cache
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PLATFORMIO_CORE_DIR=/root/.platformio \
    PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl unzip build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install platformio
RUN pip install --no-cache-dir platformio

# Preinstall platform/toolchain for esp8266
RUN pio pkg install --global \
    --platform espressif8266 \
    --tool toolchain-xtensa \
    --tool tool-esptool \
    --tool tool-mkspiffs || true

# create dirs
RUN mkdir -p /workspace /root/.platformio/lib /root/.platformio/packages /workspace/.pio/build

WORKDIR /workspace

# Copy project libs into image (source form)
COPY lib/ /tmp/lib/

# Ensure each library has library.properties/library.json (create minimal if missing),
# then copy each lib into PIO lib cache (/root/.platformio/lib/<LibName>)
RUN set -eux; \
    for d in /tmp/lib/*; do \
      [ -d "$d" ] || continue; \
      name="$(basename "$d")"; \
      # if no library.properties or library.json - create minimal library.properties
      if [ ! -f "$d/library.properties" ] && [ ! -f "$d/library.json" ]; then \
        echo "name = $name" > "$d/library.properties"; \
        echo "version = 0.0.0" >> "$d/library.properties"; \
        echo "Automatically created minimal library.properties for $name"; \
      fi; \
      # copy to PIO lib cache folder (use name to avoid nested paths)
      rm -rf "/root/.platformio/lib/$name" || true; \
      cp -r "$d" "/root/.platformio/lib/$name"; \
    done

# Do a temporary tiny build to let PlatformIO index libs (no network)
RUN echo "[env:nodemcuv2]\nplatform=espressif8266\nboard=nodemcuv2\nframework=arduino" > platformio.ini \
 && mkdir -p src \
 && echo "void setup(){} void loop(){}" > src/main.cpp \
 && pio run -e nodemcuv2 -v -j 4 || true \
 && rm -rf src platformio.ini .pio

# Optional: list cached libs for debug
RUN echo "=== cached libs ===" && ls -1 /root/.platformio/lib || true

WORKDIR /workspace
CMD ["tail","-f","/dev/null"]
