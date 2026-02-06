#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <ArduinoOTA.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>
// #include <OneWire.h>
#include <DallasTemperature.h>
#include <EEPROM.h>
#include <FastBot.h>
#include <FileData.h>
#include <LittleFS.h>
#include <GyverPortal.h>
#include <GyverHC595.h>
#include <GTimer.h>

OneWire oneWire(2);
DallasTemperature sensors(&oneWire);
ESP8266WebServer server(80);

void setup() {
  Serial.begin(115200);

  WiFi.mode(WIFI_STA);
  WiFi.begin("ssid","pass");

  sensors.begin();
  server.begin();
  ArduinoOTA.begin();
}

void loop() {
  sensors.requestTemperatures();
  float t = sensors.getTempCByIndex(0);
  server.handleClient();
  ArduinoOTA.handle();
  delay(1000);
}
