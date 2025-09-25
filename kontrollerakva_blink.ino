// NodeMCU Blink
const int LED_PIN = LED_BUILTIN;  // встроенный светодиод

void setup() {
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_PIN, LOW);   // Вкл. светодиод (LOW для ESP8266)
  delay(500);                    // пауза 500 мс
  digitalWrite(LED_PIN, HIGH);  // Выкл. светодиод
  delay(500);
}
