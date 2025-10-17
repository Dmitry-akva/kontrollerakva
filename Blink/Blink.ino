const int LED_PIN = LED_BUILTIN;  // Встроенный светодиод

unsigned long previousMillis = 0;
const long interval = 800;  // интервал в миллисекундах
bool ledState = false;

void setup() {
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    ledState = !ledState;
    digitalWrite(LED_PIN, ledState ? LOW : HIGH);  // LOW = включено для ESP8266
  }
}
