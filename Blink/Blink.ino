#include <ESP8266mDNS.h>
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

GyverPortal ui(&LittleFS);  // передать ссылку на fs (SPIFFS/LittleFS)
GyverHC595<1, HC_SPI> reg(12);
///////////////////////////////ETYывппERT/////////fgh///
#define ONE_WIRE_BUS 0 // Пин подключения OneWire шины, gpio0
OneWire oneWire(ONE_WIRE_BUS); // Подключаем бибилотеку OneWire
DallasTemperature sensors(&oneWire); // Подключаем бибилотеку DallasTemperature
DeviceAddress temperatureSensors[3]; // размер массива определяем исходя из количества установленных датчиков

GTimer<millis> TimerCount; 

String ver = "zim";

uint8_t deviceCount = 0;
volatile bool res = 0;
volatile uint32_t startUnix;  // время старта
volatile uint32_t timer = 0;
volatile uint16_t timer1 = 0;

#define BOT_TOKEN "5726804719:AAFMHa-xit34yCUDe-9izymWZgg34uyb3UI"
#define CHAT_ID "1143197272"

struct LoginPass {  char ssid[20];  char passw[20];  char tok[20];  char id[55];  bool AP;  };

LoginPass lp;
////////////////////////////////////////
FastBot bot(BOT_TOKEN);
ADC_MODE (ADC_VCC); //мониторинг собственой батареи
///////////////////////////////////////
GPtime valrele1on; 
GPtime valrele1off; 
GPtime valrele2on; 
GPtime valrele2off; 
GPtime valrele3on; 
GPtime valrele3off;
GPtime valrele4on, valrele5on, valrele6on, valrele7on;
bool val1Switch, val2Switch, val3Switch;

struct Data {
 volatile uint16_t rele1on, rele1off, rele2on, rele2off, rele3on, rele3off, rele4on, rele5on, rele6on;
 bool ch1, ch2, ch3, ch4, ch5, ch6, ch7;
 float val4Spin, val5Spin, val6Spin, val7Spin;
 long int correct;
 };
 
Data mydata;
FileData data(&LittleFS, "/datazim.dat", 'B', &mydata, sizeof(mydata));

void setup() {
	
  TimerCount.setMode(GTMode::Interval);
  TimerCount.setTime(86400000);
  TimerCount.start();
  
  Serial.begin(115200);  delay(1000);   Serial.println();
  // читаем логин пароль из памяти
  EEPROM.begin(150);
  EEPROM.get(0, lp);
  
//  lp.ssid = "netis_2.4G_OBK2";
 // lp.passw = "991991991666";
  
  Serial.println(lp.ssid);
  Serial.println(lp.passw);
  pinMode(LED_BUILTIN, OUTPUT);//// лед пин назначить как выход

  connectWiFi();  
  bot.setChatID(CHAT_ID);  bot.attach(newMsg); bot.sendMessage("Bot started....", CHAT_ID);
  if  (WiFi.status() != WL_CONNECTED) { WiFi.mode(WIFI_AP);   WiFi.begin("", "");}
  
  if (bot.timeSynced()) { /////////////////////////синхронизация времени на старте
    startUnix = bot.getUnix();   FB_Time t = bot.getTime(7);
    TimerCount.setTime( t.hour * 60 * 60 + t.minute * 60 + t.second); // синхронизация времени
    bot.sendMessage("Time"+ver+" updated " + t.timeString() + " at " + t.dateString());
    bot.sendMessage(String(TimerCount.getTime()-TimerCount.getLeft()), CHAT_ID);}

  ////////////////////////////////////////
  sensors.begin(); // Иницилизируем датчики
  deviceCount = sensors.getDeviceCount(); // Получаем количество обнаруженных датчиков
  for (uint8_t index = 0; index < deviceCount; index++)
  {    sensors.getAddress(temperatureSensors[index], index);  }

  //////////////////////////////////////
  // строчка для номера порта по умолчанию
  // можно вписать «8266»:
  // ArduinoOTA.setPort(8266);
  // строчка для названия хоста по умолчанию;
  // можно вписать «esp8266-[ID чипа]»:
  // ArduinoOTA.setHostname("myesp8266");
  // строчка для аутентификации
  // (по умолчанию никакой аутентификации не будет):
  // ArduinoOTA.setPassword((const char *)"123");
  ArduinoOTA.onStart([]() {
     ui.stop();
     bot.detach();
    Serial.println("Start");
   
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  ArduinoOTA.begin();  Serial.println("Ready");
  Serial.print("IP address: ");   Serial.println(WiFi.localIP());
  //////////////////////////////////////////////////////////
  if (!LittleFS.begin()) Serial.println("FS Error");
  ui.start();  ui.enableOTA();  ui.attachBuild(build);  ui.attach(action);
  ui.log.start(50);   // размер буфера

   FDstat_t stat = data.read();   // прочитать данные из файла в переменную
  switch (stat) {
    case FD_FS_ERR: Serial.println("FS Error");
      break;
    case FD_FILE_ERR: Serial.println("Error");
      break;
    case FD_WRITE: Serial.println("Data Write");
      break;
    case FD_ADD: Serial.println("Data Add");
      break;
    case FD_READ: Serial.println("Data Read");
      break;
    default:
      break;
  }
 
  valrele1on.set(mydata.rele1on / 60, mydata.rele1on - mydata.rele1on / 60 * 60);
  valrele1off.set(mydata.rele1off / 60, mydata.rele1off - mydata.rele1off / 60 * 60);
  valrele2on.set(mydata.rele2on / 60, mydata.rele2on - mydata.rele2on / 60 * 60);
  valrele2off.set(mydata.rele2off / 60, mydata.rele2off - mydata.rele2off / 60 * 60);
  valrele3on.set(mydata.rele3on / 60, mydata.rele3on - mydata.rele3on / 60 * 60);
  valrele3off.set(mydata.rele3off / 60, mydata.rele3off - mydata.rele3off / 60 * 60);

   if (mydata.ch1) { 
      if  (TimerCount.getTime()-TimerCount.getLeft() > (mydata.rele1on * 60)) {reg.write(0, 0); reg.update(); val1Switch = 1;}
          else { reg.write(0, 1);  reg.update();   val1Switch = 0;}}
          
    if (mydata.ch2) { 
      if  (TimerCount.getTime()-TimerCount.getLeft() > (mydata.rele2on * 60)) {reg.write(1, 0); reg.update(); val2Switch = 1;}
          else { reg.write(1, 1);  reg.update();   val2Switch = 0;}}      
          
    if (mydata.ch3) { 
      if  (TimerCount.getTime()-TimerCount.getLeft() > (mydata.rele3on * 60)) {reg.write(2, 0); reg.update(); val3Switch = 1;}
          else { reg.write(2, 1);  reg.update();   val3Switch = 0;}}
  
}  

///////////// обработчик сообщений
void newMsg(FB_msg& msg) {
  if (msg.unix < startUnix) return; // игнорировать непрочитанные сообщения
  if (msg.text == "restart"+ver) res = 1;
  if (msg.OTA && msg.text == "update"+ver) bot.update();  // обновить прошивку с подписью update"+ver"
  ////////////////////////////////

  if (msg.text == "led"+ver+"on") {
    digitalWrite(LED_BUILTIN, LOW);
    bot.sendMessage("LED"+ver+"on");  }
    
  if (msg.text == "led"+ver+"off") {
    digitalWrite(LED_BUILTIN, HIGH);
    bot.sendMessage("LED"+ver+"off");  }
    
  if (msg.text == "Rele1"+ver+"on") {
    reg.write(0, 0);
    reg.update();
    val1Switch = 1;  }
    
  if (msg.text == "Rele1"+ver+"off") {
    reg.write(0, 1);
    reg.update();
    val1Switch = 0;  }
    
  if (msg.text == "Rele1"+ver+"on") {
    reg.write(1, 0);
    reg.update();
    val2Switch = 1;  }
    
  if (msg.text == "Rele1"+ver+"off") {
    reg.write(1, 1);
    reg.update();
    val2Switch = 0;  }
    
  if (msg.text == "Rele1"+ver+"on") {
    reg.write(2, 0);
    reg.update();
    val3Switch = 1;  }
    
  if (msg.text == "Rele1"+ver+"off") {
    reg.write(2, 1);
    reg.update();
    val3Switch = 0;  }

  if (msg.text == "timerstatus"+ver) {
    //if ((rele1on-rele1on/60*60)==0) bot.sendMessage( "Rele1on " + String(rele1on/60)+":00");
    if ((mydata.rele1on - mydata.rele1on / 60 * 60) >= 10) bot.sendMessage( "Rele1on " + String(mydata.rele1on / 60) + ":" + String(mydata.rele1on - mydata.rele1on / 60 * 60));
    if ((mydata.rele1on - mydata.rele1on / 60 * 60) < 10) bot.sendMessage( "Rele1on " + String(mydata.rele1on / 60) + ":0" + String(mydata.rele1on - mydata.rele1on / 60 * 60));

    //if ((rele1off-rele1off/60*60)==0) bot.sendMessage( "Rele1off " + String(rele1off/60)+":00");
    if ((mydata.rele1off - mydata.rele1off / 60 * 60) >= 10) bot.sendMessage( "Rele1off " + String(mydata.rele1off / 60) + ":" + String(mydata.rele1off - mydata.rele1off / 60 * 60));
    if ((mydata.rele1off - mydata.rele1off / 60 * 60) < 10) bot.sendMessage( "Rele1off " + String(mydata.rele1off / 60) + ":0" + String(mydata.rele1off - mydata.rele1off / 60 * 60));

    //if ((rele2on-rele2on/60*60)==0) bot.sendMessage( "Rele2on " + String(rele2on/60)+":00");
    if ((mydata.rele2on - mydata.rele2on / 60 * 60) >= 10) bot.sendMessage( "Rele2on " + String(mydata.rele2on / 60) + ":" + String(mydata.rele2on - mydata.rele2on / 60 * 60));
    if ((mydata.rele2on - mydata.rele2on / 60 * 60) < 10) bot.sendMessage( "Rele2on " + String(mydata.rele2on / 60) + ":0" + String(mydata.rele2on - mydata.rele2on / 60 * 60));

    //if ((rele2off-rele2off/60*60)==0) bot.sendMessage( "Rele2off " + String(rele2off/60)+":00");
    if ((mydata.rele2off - mydata.rele2off / 60 * 60) >= 10) bot.sendMessage( "Rele2off " + String(mydata.rele2off / 60) + ":" + String(mydata.rele2off - mydata.rele2off / 60 * 60));
    if ((mydata.rele2off - mydata.rele2off / 60 * 60) < 10) bot.sendMessage( "Rele2off " + String(mydata.rele2off / 60) + ":0" + String(mydata.rele2off - mydata.rele2off / 60 * 60));

    //if ((rele3on-rele3on/60*60)==0) bot.sendMessage( "Rele3on " + String(rele3on/60)+":00");
    if ((mydata.rele3on - mydata.rele3on / 60 * 60) >= 10) bot.sendMessage( "Rele3on " + String(mydata.rele3on / 60) + ":" + String(mydata.rele3on - mydata.rele3on / 60 * 60));
    if ((mydata.rele3on - mydata.rele3on / 60 * 60) < 10) bot.sendMessage( "Rele3on " + String(mydata.rele3on / 60) + ":0" + String(mydata.rele3on - mydata.rele3on / 60 * 60));

    //if ((rele3off-rele3off/60*60)==0) bot.sendMessage( "Rele3off " + String(rele3off/60)+":00");
    if ((mydata.rele3off - mydata.rele3off / 60 * 60) >= 10) bot.sendMessage( "Rele3off " + String(mydata.rele3off / 60) + ":" + String(mydata.rele3off - mydata.rele3off / 60 * 60));
    if ((mydata.rele3off - mydata.rele3off / 60 * 60) < 10) bot.sendMessage( "Rele3off " + String(mydata.rele3off / 60) + ":0" + String(mydata.rele3off - mydata.rele3off / 60 * 60));
    bot.sendMessage(String(mydata.ch1)+String(mydata.ch2)+String(mydata.ch3));
  }

  /////////////////////////
  if (msg.text == "info") {
    bot.sendMessage("TimerCount" + String(TimerCount.getTime()-TimerCount.getLeft()));
    bot.sendMessage("Correct: " + String(mydata.correct));
    bot.sendMessage( ver+": CPU Frequency = " + String(F_CPU / 1000000) + " MHz"); // Частота проца
    //  bot.sendMessage("SSID = "+String(WIFI_SSID)); // Точка доступа
    double vcc = (double)ESP.getVcc() / 1000; ////////////////////////// Вольтаж
    String Volt = "Battery_Vin = " + String(vcc);   bot.sendMessage(Volt);
    byte i;////Чтение температуры с сенсоров и отправка
    sensors.requestTemperatures();
    for (int i = 0; i < deviceCount; i++)
    {  bot.sendMessage(String(sensors.getTempC(temperatureSensors[i]), 2) + "°C");
      }} }

///////////подключение к WiFi
void connectWiFi() {
  delay(2000);  Serial.begin(115200);  Serial.println();
  if (lp.AP) {WiFi.mode(WIFI_AP);   WiFi.begin("", "");}
  else{
  WiFi.mode(WIFI_STA);
  WiFi.begin(lp.ssid, lp.passw);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    if (millis() > 10000) return; }
  Serial.print(ver+" Connected: ");
  Serial.println(lp.ssid);
  Serial.print("IP address: ");   Serial.println(WiFi.localIP());
}}
/////////////////////////////////////////


void printAddress(DeviceAddress deviceAddress) {
  for (uint8_t i = 0; i < 8; i++)
  { if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
} // Выводим адрес датчика в HEX формате

/////////////////////////////////////// конструктор страницы
void sinhr() {
  if ((TimerCount.getTime()-TimerCount.getLeft() >= 43200) && (TimerCount.getTime()-TimerCount.getLeft() <= 43204)) { // синхронизация времени в 12.00
      if (WiFi.status() == WL_CONNECTED) {  //если есть wifi обновляем время
      bot.sendMessage("Time "+ver+" is update...");
      if (bot.timeSynced()) { // если синхронизировано обновляем переменные
        FB_Time t = bot.getTime(7);
        mydata.correct = TimerCount.getTime()-TimerCount.getLeft() - (t.hour * 60 * 60 + t.minute * 60 + t.second);
        bot.sendMessage("Time updated " + t.timeString() + " at " + t.dateString());
        bot.sendMessage("Correct: " + String(mydata.correct));
       
      } else return; 
      } else return; }

  if (mydata.ch1) { if  ((TimerCount.getTime()-TimerCount.getLeft() >= mydata.rele1on * 60) && (TimerCount.getTime()-TimerCount.getLeft() <= mydata.rele1on * 60)) {
    reg.write(0, 0);
    reg.update();
    val1Switch = 1;
    bot.sendMessage("rele1on");
     }}
  
  if (mydata.ch2) { if  ((TimerCount.getTime()-TimerCount.getLeft() >= mydata.rele2on * 60) && (TimerCount.getTime()-TimerCount.getLeft() <= mydata.rele2on * 60)) {
    reg.write(1, 0);
    reg.update();
    val2Switch = 1;
    bot.sendMessage("rele2on");
     }}
    
  if (mydata.ch3) { if ((TimerCount.getTime()-TimerCount.getLeft() >= mydata.rele3on * 60) && (TimerCount.getTime()-TimerCount.getLeft() <= mydata.rele3on * 60)) {
    reg.write(2, 0);
    reg.update();
    val3Switch = 1;
    bot.sendMessage("rele3on");
     }}
    
  if (mydata.ch1) { if ((TimerCount.getTime()-TimerCount.getLeft() >= mydata.rele1off * 60) && (TimerCount.getTime()-TimerCount.getLeft() <= mydata.rele1off * 60)) {
    reg.write(0, 1);
    reg.update();
    val1Switch = 0;
    bot.sendMessage("rele1off");
     } }
    
  if (mydata.ch2) {if  ((TimerCount.getTime()-TimerCount.getLeft() >= mydata.rele2off * 60) && (TimerCount.getTime()-TimerCount.getLeft() <= mydata.rele2off * 60)) {
    reg.write(1, 1);
    reg.update();
    val2Switch = 0;
    bot.sendMessage("rele2off");
     } }
    
  if (mydata.ch3) { if  ((TimerCount.getTime()-TimerCount.getLeft() >= mydata.rele3off * 60) && (TimerCount.getTime()-TimerCount.getLeft() <= mydata.rele3off * 60)) {
    reg.write(2, 1);
    reg.update();
    val3Switch = 0;
    bot.sendMessage("rele3off");
     } } }



void loop() {
  sinhr();
 
  if (res) {   bot.sendMessage("Reboot...");   bot.tickManual();   ESP.restart();  }
  ArduinoOTA.handle();   ui.tick();   bot.tick();  
  
  if (TimerCount.getTime()-TimerCount.getLeft() == 300000) {bot.sendMessage("5 мин");}
  if (TimerCount.getTime()-TimerCount.getLeft() == 900000) {bot.sendMessage("15 мин");}  
  
        
       
}

/////////////////////////////////////// конструктор 
void build() {
  GP.BUILD_BEGIN(GP_DARK, 1000);//1900
  GP.setTimeout(5000);
  GP.UPDATE("led2,led3,led1");

  GP.BOX_BEGIN(GP_CENTER);
  GP.BLOCK_BEGIN(GP_DIV, "", "Timer 1");
  GP.SWITCH("sw1", val1Switch);
  GP.LED("led1", val1Switch) ;
  GP.PLAIN("___");
  GP.CHECK("ch1", mydata.ch1); 
  M_BOX(GP.LABEL("Timer 1 on"); GP.TIME("Timer1on", valrele1on); );
  M_BOX(GP.LABEL("Timer 1 off"); GP.TIME("Timer1off", valrele1off); );
  GP.BLOCK_END();

  M_BLOCK(
    GP_DIV, "", "Timer 2",
    GP.SWITCH("sw2", val2Switch);
    GP.LED("led2", val2Switch) ;
    GP.PLAIN("___");
    GP.CHECK("ch2", mydata.ch2); 
    M_BOX(GP.LABEL("Timer 2 on"); GP.TIME("Timer2on", valrele2on); );
    M_BOX(GP.LABEL("Timer 2 off"); GP.TIME("Timer2off", valrele2off); );  );

  M_BLOCK(
    GP_DIV, "", "Timer 3",
    GP.SWITCH("sw3", val3Switch);
    GP.LED("led3", val3Switch) ;
    GP.PLAIN("___");
    GP.CHECK("ch3", mydata.ch3); 
    M_BOX(GP.LABEL("Timer 3 on"); GP.TIME("Timer3on", valrele3on); );
    M_BOX(GP.LABEL("Timer 3 off"); GP.TIME("Timer3off", valrele3off); );  );

  GP.BOX_END();
  //////////////////////////////////
  GP.BOX_BEGIN(GP_CENTER);
  
   M_BLOCK(
    GP_DIV, "", "Timer 4",
    M_BOX(GP.SPINNER("spn4", mydata.val4Spin,0,100,1,0,GP_GREEN,"80px",0); GP.BUTTON_MINI("Go4", "Go"); GP.CHECK("ch4", mydata.ch4););
    GP.TIME("Timer4on", valrele4on); 
      );
      
  M_BLOCK(
    GP_DIV, "", "Timer 5",
    M_BOX(GP.SPINNER("spn5", mydata.val5Spin,0,100,1,0,GP_GREEN,"80px",0); GP.BUTTON_MINI("Go5", "Go"); GP.CHECK("ch5", mydata.ch5););
    GP.TIME("Timer5on", valrele5on); 
      );

  M_BLOCK(
    GP_DIV, "", "Timer 6",
    M_BOX(GP.SPINNER("spn6", mydata.val6Spin,0,100,1,0,GP_GREEN,"80px",0); GP.BUTTON_MINI("Go6", "Go"); GP.CHECK("ch6", mydata.ch6););
    GP.TIME("Timer6on", valrele6on); 
      );

  M_BLOCK(
    GP_DIV, "", "Timer 7",
    M_BOX(GP.SPINNER("spn7", mydata.val7Spin,0,100,1,0,GP_GREEN,"80px",0); GP.BUTTON_MINI("Go7", "Go"); GP.CHECK("ch7", mydata.ch7););
    GP.TIME("Timer7on", valrele7on); 
      );    

    
  GP.BOX_END();
  //////////////////////////////////
  GP.BOX_BEGIN(GP_CENTER, "1000px");//1900
  GP.AJAX_PLOT_DARK("plot1", 1, 20, 5000, 250);
  GP.BOX_END();
  
 
  ////////////////////////

  GP.BOX_BEGIN(GP_CENTER);
               
    M_BLOCK(
    GP.FORM_BEGIN("/login");
    GP.TEXT("lg", "Login", lp.ssid);
    GP.BREAK();
    GP.PASS("ps", "Password", lp.passw);
    GP.BREAK();
    GP.TEXT("token", "bot token", lp.tok);
    GP.BREAK();
    GP.TEXT("id", "chat id", lp.id);
    GP.BREAK();
    GP.SUBMIT("Submit");
    GP.FORM_END(););
    
  

   
  M_BLOCK(
    GP.AREA_LOG(10);  
    GP.BUTTON_MINI("Save", "Save");); // сохраненеие в еепром
   
  M_BLOCK(
  M_BOX(GP.PLAIN("AP");
  GP.CHECK("ch10", lp.AP);
  GP.BUTTON_MINI("Reboot", "Reboot"); // перезагрузка 
  GP.FILE_UPLOAD("file_upl");    // кнопка загрузки
  GP.FOLDER_UPLOAD("folder_upl"););// кнопка загрузки
  GP.FILE_MANAGER(&LittleFS);    // файловый менеджер
  GP.BUTTON_LINK("/ota_update", "fimeware"););
  
  GP.BOX_END();
  
  GP.BOX_BEGIN(GP_CENTER);
  GP.EMBED("/data.txt","1000px");
  GP.BOX_END();
  GP.BUILD_END();
}

/////////////////////////////////////////////////
void action() {

  // одна из форм была submit
  if (ui.form()) {
    // проверяем, была ли это форма "/update"
    if (ui.form("/login")) {
      // забираем значения и обновляем переменные
      ui.copyStr("lg", lp.ssid);  // копируем себе
      ui.copyStr("ps", lp.passw);
      ui.copyStr("token", lp.tok);
      ui.copyStr("id", lp.id);
      EEPROM.put(0, lp);              // сохраняем
      EEPROM.commit();                // записываем
    }}

      

  if (ui.uploadEnd()) {
    Serial.print("Uploaded file: ");
    Serial.print(ui.fileName());      // имя файла
    Serial.print(", from: ");
    Serial.println(ui.uploadName());  // имя формы загрузки
    // файл сохранится В КО  ЕНЬ, С ИМЕНЕМ fileName()
    // или с сохранением пути вложенных папок
  }

  if (ui.click()) {

    
    if (ui.clickTime("Timer1on", valrele1on));
    if (ui.clickTime("Timer1off", valrele1off));
    if (ui.clickTime("Timer2on", valrele2on));
    if (ui.clickTime("Timer2off", valrele2off));
    if (ui.clickTime("Timer3on", valrele3on));
    if (ui.clickTime("Timer3off", valrele3off));
    if (ui.clickBool("ch1", mydata.ch1));
    if (ui.clickBool("ch2", mydata.ch2));
    if (ui.clickBool("ch3", mydata.ch3));
    if (ui.clickBool("ch4", mydata.ch4));
    if (ui.clickBool("ch5", mydata.ch5));
    if (ui.clickBool("ch6", mydata.ch6));
    if (ui.clickBool("ch7", mydata.ch7));
    if (ui.clickBool("ch10", lp.AP));


    

    if (ui.clickBool("sw1", val1Switch)) {
      reg.write(0, !val1Switch);
      reg.update();    }
      
    if (ui.clickBool("sw2", val2Switch)) {
      reg.write(1, !val2Switch);
      reg.update();    }
      
    if (ui.clickBool("sw3", val3Switch)) {
      reg.write(2, !val3Switch);
      reg.update();    }

    if (ui.click("btn")) {
      // отправляем обратно в "монитор" содержимое поля, оно пришло по клику кнопки
      ui.log.println(ui.getString("btn")); Serial.println(ui.getString("btn"));     }
      
    if (ui.click("Reboot")) {  ui.log.println("Reboot...."); bot.tickManual(); ESP.restart();  }

    if (ui.click("Save")) {

      mydata.rele1on = valrele1on.hour * 60 + valrele1on.minute;
      mydata.rele1off = valrele1off.hour * 60 + valrele1off.minute;
      mydata.rele2on = valrele2on.hour * 60 + valrele2on.minute;
      mydata.rele2off = valrele2off.hour * 60 + valrele2off.minute;
      mydata.rele3on = valrele3on.hour * 60 + valrele3on.minute;
      mydata.rele3off = valrele3off.hour * 60 + valrele3off.minute;
      
      data.updateNow();
   
      ui.log.println(String(valrele1on.hour) + ":" + String(valrele1on.minute)+"   "+(String(mydata.ch1)));
      ui.log.println(String(valrele1off.hour) + ":" + String(valrele1off.minute));
      ui.log.println(String(valrele2on.hour) + ":" + String(valrele2on.minute)+"   "+(String(mydata.ch2)));
      ui.log.println(String(valrele2off.hour) + ":" + String(valrele2off.minute)); 
      ui.log.println(String(valrele3on.hour) + ":" + String(valrele3on.minute)+"   "+(String(mydata.ch3)));
      ui.log.println(String(valrele3off.hour) + ":" + String(valrele3off.minute));
      } }
    
  if (ui.update()) {
    if (ui.update("plot1")) {  sensors.requestTemperatures();  ui.answer(sensors.getTempC(temperatureSensors[0]), 2); }
    ui.updateBool("led1", val1Switch); ui.updateBool("led2", val2Switch); ui.updateBool("led3", val3Switch);
    }}
