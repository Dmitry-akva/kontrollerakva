#include <ESP8266mDNS.h> //для ота
#include <WiFiUdp.h>   //для ота
#include <ArduinoOTA.h>   //для ота
#include <FastBot.h>   // телеграмм бот
#include <OneWire.h>   // для датчика
#include <DallasTemperature.h>  // для датчика
#include <FileData.h>
#include <LittleFS.h>
#include <GyverPortal.h>
#include <GyverHC595.h>
#include <EEPROM.h>
#include <GTimer.h>

void setup() {
    // Инициализация последовательного порта
    Serial.begin(115200);
    Serial.println("ESP8266 minimal build test");

}

void loop() {
    // Просто мигаем встроенным светодиодом
    digitalWrite(LED_BUILTIN, HIGH);
    delay(500);
    digitalWrite(LED_BUILTIN, LOW);
    delay(500);
}

