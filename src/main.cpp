#include <FastBot.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <FileData.h>
#include <LittleFS.h>
#include <GyverPortal.h>
#include <GyverHC595.h>
#include <EEPROM.h>
#include <GTimer.h>

#define ONE_WIRE_PIN 2
#define HC595_DATA_PIN 5
#define HC595_CLOCK_PIN 4
#define HC595_LATCH_PIN 0

OneWire oneWire(ONE_WIRE_PIN);
DallasTemperature sensors(&oneWire);
FastBot bot;
FileData fileData;
GyverPortal portal;
GyverHC595 hc(HC595_DATA_PIN, HC595_CLOCK_PIN, HC595_LATCH_PIN);
GTimer timer;

void setup() {
    Serial.begin(115200);

    // LittleFS монтируем для прогрева
    LittleFS.begin();

    // EEPROM прогреваем чтением/записью первого байта
    byte val = EEPROM.read(0);
    EEPROM.write(0, val);

    // Инициализация библиотек
    sensors.begin();
    hc.update();        // обновление сдвигового регистра
    portal.init();
    timer.setTimeout(1000);  // задаём таймер

    // FastBot: минимальный вызов метода
    bot.sendMessage("Test"); // можно закомментировать, если нет сети
}

void loop() {
    // Просто вызываем методы библиотек, чтобы компилятор не удалил
    sensors.requestTemperatures();
    hc.update();
    portal.update();
    if (timer.isReady()) timer.reset();
    delay(1000);
}
