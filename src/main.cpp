#include <Arduino.h>

void setup() {
    // Инициализация последовательного порта
    Serial.begin(115200);
    Serial.println("ESP8266 minimal build test");
    Serial.println("ESP8266 minimal build test");
    Serial.println("ESP8266 minimal build test");
}

void loop() {
    // Просто мигаем встроенным светодиодом
    digitalWrite(LED_BUILTIN, HIGH);
    delay(500);
    digitalWrite(LED_BUILTIN, LOW);
    delay(500);
}

