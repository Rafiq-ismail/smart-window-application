#include <Arduino.h>
#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <WebServer.h>
#include "secrets.h"
#define MQ1_PIN 34
#define MQ2_PIN 35
#define MQ3_PIN 32
#define MQ4_PIN 36
#define HIGH_TEMP_THRESHOLD 33.0

// ======================================================
// WIFI SETTINGS
// ======================================================

const char* FIREBASE_URL =
  "https://smartwindow-131e5-default-rtdb.asia-southeast1.firebasedatabase.app";

  // ======================================================
// LOCAL HTTP SERVER
// ======================================================

WebServer server(80);

// ======================================================
// DHT22
// ======================================================

#define DHTTYPE DHT22

#define DHT1_PIN 4
#define DHT2_PIN 5
#define DHT3_PIN 26
#define DHT4_PIN 14

DHT dht1(DHT1_PIN, DHTTYPE);
DHT dht2(DHT2_PIN, DHTTYPE);
DHT dht3(DHT3_PIN, DHTTYPE);
DHT dht4(DHT4_PIN, DHTTYPE);

// ======================================================
// RAIN SENSOR
// ======================================================

#define RAIN_PIN 27

// LOW  = rain detected
// HIGH = no rain

// ======================================================
// ACTUATOR 1
// ======================================================

#define A1_RPWM 25
#define A1_LPWM 33

// ======================================================
// ACTUATOR 2
// ======================================================

#define A2_RPWM 21
#define A2_LPWM 22

// ======================================================
// ACTUATOR 3
// ======================================================

#define A3_RPWM 16
#define A3_LPWM 17

// ======================================================
// STEPPER MOTOR
// ======================================================

#define STEP_PIN 23
#define DIR_PIN 18

int stepperSteps = 800;
int stepDelay = 3000;
void moveStepper(bool direction, int steps);
void stepperMoveToPosition(int targetPosition);
// ======================================================
// ACTUATOR SETTINGS
// ======================================================

#define ACTUATOR_MOVE_TIME 1000
#define ACTUATOR_DIRECTION_DELAY 50

// Estimated actuator positions (0% = closed, 100% = open)
int window1Position = 0;
int window2Position = 0;
int window3Position = 0;

// ======================================================
// AUTO MODE STATE
// ======================================================

bool autoModeEnabled = true;

// ======================================================
// MQ ANALOG BASELINE
// ======================================================

int mq1Baseline = 0;
int mq2Baseline = 0;
int mq3Baseline = 0;

bool mqBaselineReady = false;

// MQ consecutive detection
int mq1HighCount = 0;
int mq2HighCount = 0;
int mq3HighCount = 0;

bool mq1SmokeState = false;
bool mq2SmokeState = false;
bool mq3SmokeState = false;

const int MQ_REQUIRED_HIGH_COUNT = 2;

int mq1LowCount = 0;
int mq2LowCount = 0;
int mq3LowCount = 0;

const int MQ_REQUIRED_LOW_COUNT = 2;

// ======================================================
// WIFI FUNCTION
// ======================================================

void connectWiFi() {

  Serial.println();
  Serial.println("================================");
  Serial.println("CONNECTING TO WIFI");
  Serial.println("================================");

  WiFi.mode(WIFI_STA);

  Serial.println();
Serial.println("Scanning WiFi networks...");

int networkCount = WiFi.scanNetworks();

Serial.print("Networks found: ");
Serial.println(networkCount);

for (int i = 0; i < networkCount; i++) {
  Serial.print(i + 1);
  Serial.print(". ");
  Serial.print(WiFi.SSID(i));
  Serial.print(" | RSSI: ");
  Serial.print(WiFi.RSSI(i));
  Serial.print(" dBm | Channel: ");
  Serial.println(WiFi.channel(i));
}

Serial.println();
Serial.println("Trying to connect...");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long startTime = millis();

  while (WiFi.status() != WL_CONNECTED &&
         millis() - startTime < 20000) {

    Serial.print(".");
    delay(500);
  }

  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {

    Serial.println("WIFI CONNECTED");

    Serial.print("SSID: ");
    Serial.println(WiFi.SSID());

    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());

    Serial.print("RSSI: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  }

  else {

    Serial.println("WIFI CONNECTION FAILED");
  }
}

// ======================================================
// PUSH NOTIFICATION - RENDER + FCM
// ======================================================

void sendPushNotification(String title, String body, String type) {

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("NOTIFICATION FAILED -> WiFi not connected");
    return;
  }

  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient http;

  const char* notificationUrl =
      "https://smartwindow-notification-server.onrender.com/send-notification";

  Serial.println();
  Serial.println("Sending push notification to Render...");

  http.setConnectTimeout(5000);
  http.setTimeout(10000);

  if (!http.begin(client, notificationUrl)) {
    Serial.println("NOTIFICATION FAILED -> Cannot start HTTP connection");
    return;
  }

  http.addHeader("Content-Type", "application/json");
  http.addHeader("x-api-key", NOTIFICATION_API_KEY);

String json = "{";
json += "\"title\":\"" + title + "\",";
json += "\"body\":\"" + body + "\",";
json += "\"type\":\"" + type + "\",";
json += "\"deviceId\":\"esp32_01\"";
json += "}";

  int httpResponseCode = http.POST(json);

  Serial.print("Notification HTTP response: ");
  Serial.println(httpResponseCode);

  if (httpResponseCode >= 200 && httpResponseCode < 300) {

    Serial.println("PUSH NOTIFICATION SENT");

  } else {

    Serial.println("PUSH NOTIFICATION FAILED");

    if (httpResponseCode > 0) {
      Serial.println(http.getString());
    }
  }

  http.end();
}

// ======================================================
// FIREBASE - ALL SENSOR DATA
// ======================================================

void sendAllSensorsToFirebase(
  float t1, float h1,
  float t2, float h2,
  float t3, float h3,
  bool rainDetected,
  bool smokeDetected1,
  bool smokeDetected2,
    bool smokeDetected3
) {

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("FIREBASE ERROR: WiFi not connected");
    return;
  }

  HTTPClient http;

  String url =
      String(FIREBASE_URL) +
      "/devices/esp32_01/sensors.json";

  String json = "{";

  json += "\"room1\":{";
json += "\"temperature\":" + String(t1, 1) + ",";
json += "\"humidity\":" + String(h1, 1) + ",";
json += "\"smokeDetected\":";
json += smokeDetected1 ? "true" : "false";
json += "},";

  json += "\"room2\":{";
json += "\"temperature\":" + String(t2, 1) + ",";
json += "\"humidity\":" + String(h2, 1) + ",";
json += "\"smokeDetected\":";
json += smokeDetected2 ? "true" : "false";
json += "},";

json += "\"room3\":{";
json += "\"temperature\":" + String(t3, 1) + ",";
json += "\"humidity\":" + String(h3, 1) + ",";
json += "\"smokeDetected\":";
json += smokeDetected3 ? "true" : "false";
json += "},";

  json += "\"rain\":{";
  json += "\"detected\":";
  json += rainDetected ? "true" : "false";
  json += "}";

  json += "}";

  Serial.println();
  Serial.println("Sending ALL sensor data to Firebase...");
  Serial.println(json);

 http.setConnectTimeout(1500);
http.setTimeout(2000);

http.begin(url);
http.addHeader("Content-Type", "application/json");

int httpResponseCode = http.PUT(json);

  Serial.print("Firebase HTTP response: ");
  Serial.println(httpResponseCode);

  if (httpResponseCode == 200) {
    Serial.println("ALL SENSOR DATA SENT TO FIREBASE");
  } else {
    Serial.println("FIREBASE SEND FAILED");
  }

  http.end();
}

// ======================================================
// FIREBASE - READ WINDOW 1 COMMAND
// ======================================================

void readWindow1Command() {

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected");
    return;
  }

  WiFiClientSecure client;

  client.setInsecure();
  client.setHandshakeTimeout(30);

  const char* host = "www.google.com";

  Serial.println();
  Serial.println("Testing TLS to Google...");

  if (client.connect(host, 443)) {

    Serial.println("GOOGLE TLS CONNECTION SUCCESS");

  } else {

    Serial.println("GOOGLE TLS CONNECTION FAILED");
  }

  client.stop();
}
// ======================================================
// ACTUATOR FUNCTIONS
// ======================================================

void actuatorStop(int rpwm, int lpwm) {

  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);
}

void actuatorExtend(int rpwm, int lpwm) {

  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);

  delay(ACTUATOR_DIRECTION_DELAY);

  digitalWrite(lpwm, LOW);
  digitalWrite(rpwm, HIGH);

  delay(ACTUATOR_MOVE_TIME);

  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);
}

void actuatorRetract(int rpwm, int lpwm) {

  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);

  delay(ACTUATOR_DIRECTION_DELAY);

  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, HIGH);

  delay(ACTUATOR_MOVE_TIME);

  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);
}
// ======================================================
// DOUBLE PANEL WINDOW - ACTUATOR 1 + ACTUATOR 2
// ======================================================

void doubleWindowOpen() {

  Serial.println("DOUBLE WINDOW -> OPENING BOTH PANELS");

  // Stop both actuators first
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, LOW);

  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, LOW);

  delay(ACTUATOR_DIRECTION_DELAY);

  // Start Actuator 1
  digitalWrite(A1_LPWM, LOW);
  digitalWrite(A1_RPWM, HIGH);

  // Start Actuator 2
  digitalWrite(A2_LPWM, LOW);
  digitalWrite(A2_RPWM, HIGH);

  // Both actuators are moving during this same delay
  delay(ACTUATOR_MOVE_TIME);

  // Stop both together
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, LOW);

  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, LOW);

  Serial.println("DOUBLE WINDOW -> OPEN COMPLETE");
}


void doubleWindowClose() {

  Serial.println("DOUBLE WINDOW -> CLOSING BOTH PANELS");

  // Stop both actuators first
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, LOW);

  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, LOW);

  delay(ACTUATOR_DIRECTION_DELAY);

  // Start Actuator 1
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, HIGH);

  // Start Actuator 2
  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, HIGH);

  // Both actuators are moving during this same delay
  delay(ACTUATOR_MOVE_TIME);

  // Stop both together
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, LOW);

  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, LOW);

  Serial.println("DOUBLE WINDOW -> CLOSE COMPLETE");
}void doubleWindowMoveToPosition(int targetPosition) {

  // Keep target between 0% and 100%
  targetPosition = constrain(targetPosition, 0, 100);

  int difference = targetPosition - window1Position;

  // Already at target
  if (difference == 0) {
    Serial.println("DOUBLE WINDOW -> Already at target position");
    return;
  }

  // Calculate movement duration
  unsigned long movementTime =
      (ACTUATOR_MOVE_TIME * abs(difference)) / 100;

  // Stop both actuators first
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, LOW);

  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, LOW);

  delay(ACTUATOR_DIRECTION_DELAY);

  if (difference > 0) {

    Serial.print("DOUBLE WINDOW -> OPENING TO ");
    Serial.print(targetPosition);
    Serial.println("%");

    // A1 + A2 OPEN together
    digitalWrite(A1_LPWM, LOW);
    digitalWrite(A1_RPWM, HIGH);

    digitalWrite(A2_LPWM, LOW);
    digitalWrite(A2_RPWM, HIGH);

  } else {

    Serial.print("DOUBLE WINDOW -> CLOSING TO ");
    Serial.print(targetPosition);
    Serial.println("%");

    // A1 + A2 CLOSE together
    digitalWrite(A1_RPWM, LOW);
    digitalWrite(A1_LPWM, HIGH);

    digitalWrite(A2_RPWM, LOW);
    digitalWrite(A2_LPWM, HIGH);
  }

  // Both move simultaneously
  delay(movementTime);

  // Stop both
  digitalWrite(A1_RPWM, LOW);
  digitalWrite(A1_LPWM, LOW);

  digitalWrite(A2_RPWM, LOW);
  digitalWrite(A2_LPWM, LOW);

  window1Position = targetPosition;

  Serial.print("DOUBLE WINDOW -> Estimated position: ");
  Serial.print(window1Position);
  Serial.println("%");
}
void actuatorMoveToPosition(
    int rpwm,
    int lpwm,
    int &currentPosition,
    int targetPosition) {

  // Keep target between 0% and 100%
  targetPosition = constrain(targetPosition, 0, 100);

  // Calculate how much movement is needed
  int difference = targetPosition - currentPosition;

  // Already at target position
  if (difference == 0) {
    Serial.println("Actuator already at target position");
    return;
  }

  // Convert percentage difference into movement time
  unsigned long movementTime =
      (ACTUATOR_MOVE_TIME * abs(difference)) / 100;

  // Stop before changing direction
  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);

  delay(ACTUATOR_DIRECTION_DELAY);

  if (difference > 0) {
    // OPEN / EXTEND
    Serial.print("Moving OPEN to ");
    Serial.print(targetPosition);
    Serial.println("%");

    digitalWrite(lpwm, LOW);
    digitalWrite(rpwm, HIGH);
  } else {
    // CLOSE / RETRACT
    Serial.print("Moving CLOSE to ");
    Serial.print(targetPosition);
    Serial.println("%");

    digitalWrite(rpwm, LOW);
    digitalWrite(lpwm, HIGH);
  }

  delay(movementTime);

  // Stop actuator
  digitalWrite(rpwm, LOW);
  digitalWrite(lpwm, LOW);

  // Save estimated position
  currentPosition = targetPosition;

  Serial.print("Estimated position: ");
  Serial.print(currentPosition);
  Serial.println("%");
}

void stopAllActuators() {

  actuatorStop(A1_RPWM, A1_LPWM);
  actuatorStop(A2_RPWM, A2_LPWM);
  actuatorStop(A3_RPWM, A3_LPWM);
}

// ======================================================
// LOCAL HTTP SERVER FUNCTIONS
// ======================================================

void handleRoot() {
  server.send(
    200,
    "text/plain",
    "SmartWindow ESP32 POSITION TEST V2"
  );
}

void handleWindow1Open() {

  Serial.println("HTTP -> WINDOW 1 OPEN");

  bool rainDetected = (digitalRead(RAIN_PIN) == LOW);
  bool smokeDetected = (digitalRead(MQ1_PIN) == LOW);

  // Safety priority while Auto Mode is active
  if (autoModeEnabled && (rainDetected || smokeDetected)) {

    Serial.println(
      "WINDOW 1 OPEN BLOCKED -> RAIN/SMOKE SAFETY ACTIVE"
    );

    server.send(
      409,
      "text/plain",
      "Window 1 Open Blocked - Rain/Smoke Safety Active"
    );

    return;
  }

  doubleWindowOpen();

  window1Position = 100;

  server.send(
    200,
    "text/plain",
    "Window 1 Open Command Executed"
  );
}

void handleWindow2Open() {

  Serial.println("HTTP -> WINDOW 2 OPEN");

  bool rainDetected = (digitalRead(RAIN_PIN) == LOW);
  bool smokeDetected = (digitalRead(MQ2_PIN) == LOW);

  // Safety priority while Auto Mode is active
  if (autoModeEnabled && (rainDetected || smokeDetected)) {

    Serial.println(
      "WINDOW 2 OPEN BLOCKED -> RAIN/SMOKE SAFETY ACTIVE"
    );

    server.send(
      409,
      "text/plain",
      "Window 2 Open Blocked - Rain/Smoke Safety Active"
    );

    return;
  }

  actuatorExtend(A3_RPWM, A3_LPWM);

  window2Position = 100;

  server.send(
    200,
    "text/plain",
    "Window 2 Open Command Executed"
  );
}

void handleWindow2Position() {

  if (!server.hasArg("percent")) {
    server.send(
      400,
      "text/plain",
      "Missing percent parameter"
    );
    return;
  }

  int targetPosition = server.arg("percent").toInt();

  if (targetPosition < 0 || targetPosition > 100) {
    server.send(
      400,
      "text/plain",
      "Percent must be between 0 and 100"
    );
    return;
  }

  Serial.print("HTTP -> WINDOW 2 POSITION: ");
  Serial.print(targetPosition);
  Serial.println("%");

  actuatorMoveToPosition(
    A3_RPWM,
    A3_LPWM,
    window2Position,
    targetPosition
  );

  String response =
      "Window 2 Position = " +
      String(window2Position) +
      "%";

  server.send(
    200,
    "text/plain",
    response
  );
}

void handleWindow2Close() {
  Serial.println("HTTP -> WINDOW 2 CLOSE");

  actuatorRetract(A3_RPWM, A3_LPWM);

  window2Position = 0;

  server.send(200, "text/plain", "Window 2 Close Command Executed");
}

void handleWindow3Open() {

  Serial.println("HTTP -> WINDOW 3 OPEN");

  bool rainDetected = (digitalRead(RAIN_PIN) == LOW);
  bool smokeDetected = (digitalRead(MQ3_PIN) == LOW);

  // Safety priority while Auto Mode is active
  if (autoModeEnabled && (rainDetected || smokeDetected)) {

    Serial.println(
      "WINDOW 3 OPEN BLOCKED -> RAIN/SMOKE SAFETY ACTIVE"
    );

    server.send(
      409,
      "text/plain",
      "Window 3 Open Blocked - Rain/Smoke Safety Active"
    );

    return;
  }

moveStepper(HIGH, stepperSteps);

  window3Position = 100;

  server.send(
    200,
    "text/plain",
    "Window 3 Open Command Executed"
  );
}

void handleWindow3Close() {
  Serial.println("HTTP -> WINDOW 3 CLOSE");

  moveStepper(LOW, stepperSteps);

  window3Position = 0;

  server.send(200, "text/plain", "Window 3 Close Command Executed");
}

void handleWindow3Position() {

  if (!server.hasArg("percent")) {
    server.send(
      400,
      "text/plain",
      "Missing percent parameter"
    );
    return;
  }

  int targetPosition = server.arg("percent").toInt();

  if (targetPosition < 0 || targetPosition > 100) {
    server.send(
      400,
      "text/plain",
      "Percent must be between 0 and 100"
    );
    return;
  }

  Serial.print("HTTP -> WINDOW 3 POSITION: ");
  Serial.print(targetPosition);
  Serial.println("%");

 stepperMoveToPosition(targetPosition);

  String response =
      "Window 3 Position = " +
      String(window3Position) +
      "%";

  server.send(
    200,
    "text/plain",
    response
  );
}

void handleWindow1Close() {

  Serial.println("HTTP -> WINDOW 1 CLOSE");

doubleWindowClose();

  window1Position = 0;

  server.send(200, "text/plain", "Window 1 Close Command Executed");
}

void handleWindow1Position() {

  if (!server.hasArg("percent")) {
    server.send(
      400,
      "text/plain",
      "Missing percent parameter"
    );
    return;
  }

  int targetPosition = server.arg("percent").toInt();

  if (targetPosition < 0 || targetPosition > 100) {
    server.send(
      400,
      "text/plain",
      "Percent must be between 0 and 100"
    );
    return;
  }

  Serial.print("HTTP -> WINDOW 1 POSITION: ");
  Serial.print(targetPosition);
  Serial.println("%");

doubleWindowMoveToPosition(targetPosition);

  String response =
      "Window 1 Position = " +
      String(window1Position) +
      "%";

  server.send(
    200,
    "text/plain",
    response
  );
}

// ======================================================
// AUTO MODE HTTP FUNCTIONS
// ======================================================

void handleAutoModeOn() {

  autoModeEnabled = true;

  Serial.println("HTTP -> AUTO MODE ON");

  server.send(
    200,
    "text/plain",
    "Auto Mode ON"
  );
}

void handleAutoModeOff() {

  autoModeEnabled = false;

  Serial.println("HTTP -> AUTO MODE OFF");

  server.send(
    200,
    "text/plain",
    "Auto Mode OFF"
  );
}

void handleAutoModeStatus() {

  Serial.println("HTTP -> AUTO MODE STATUS");

  if (autoModeEnabled) {

    server.send(
      200,
      "text/plain",
      "ON"
    );

  } else {

    server.send(
      200,
      "text/plain",
      "OFF"
    );
  }
}

// ======================================================
// STEPPER FUNCTION
// ======================================================

void moveStepper(bool direction, int steps) {

  digitalWrite(DIR_PIN, direction);

  Serial.print("DIR COMMAND = ");
  Serial.println(direction ? "HIGH" : "LOW");

  delay(1000);

  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(stepDelay);

    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(stepDelay);
  }
}
void stepperMoveToPosition(int targetPosition) {

  targetPosition = constrain(targetPosition, 0, 100);

  int difference = targetPosition - window3Position;

  if (difference == 0) {
    Serial.println("STEPPER WINDOW -> Already at target position");
    return;
  }

  int stepsToMove =
      (stepperSteps * abs(difference)) / 100;

  if (difference > 0) {

    Serial.print("STEPPER WINDOW -> OPENING TO ");
    Serial.print(targetPosition);
    Serial.println("%");

    moveStepper(HIGH, stepsToMove);

  } else {

    Serial.print("STEPPER WINDOW -> CLOSING TO ");
    Serial.print(targetPosition);
    Serial.println("%");

    moveStepper(LOW, stepsToMove);
  }

  window3Position = targetPosition;

  Serial.print("STEPPER WINDOW -> Estimated position: ");
  Serial.print(window3Position);
  Serial.println("%");
}
// ======================================================
// SENSOR DISPLAY
// ======================================================

void showSensors() {

  float t1 = dht1.readTemperature();
  float h1 = dht1.readHumidity();

  float t2 = dht2.readTemperature();
  float h2 = dht2.readHumidity();

  float t3 = dht3.readTemperature();
  float h3 = dht3.readHumidity();

  float t4 = dht4.readTemperature();
float h4 = dht4.readHumidity();

  int rainState = digitalRead(RAIN_PIN);



  Serial.println();
  Serial.println("======================================");
  Serial.println("SMART WINDOW SENSOR STATUS");
  Serial.println("======================================");

  Serial.println("ROOM 1");

  if (isnan(t1) || isnan(h1)) {

    Serial.println("DHT22 ERROR");
  }

  else {

    Serial.print("Temperature: ");
    Serial.print(t1, 1);
    Serial.println(" C");

    Serial.print("Humidity: ");
    Serial.print(h1, 1);
    Serial.println(" %");
  }

  Serial.println("------------------------------");

  Serial.println("ROOM 2");

  if (isnan(t2) || isnan(h2)) {

    Serial.println("DHT22 ERROR");
  }

  else {

    Serial.print("Temperature: ");
    Serial.print(t2, 1);
    Serial.println(" C");

    Serial.print("Humidity: ");
    Serial.print(h2, 1);
    Serial.println(" %");
  }

  Serial.println("------------------------------");

  Serial.println("ROOM 3");

  if (isnan(t3) || isnan(h3)) {

    Serial.println("DHT22 ERROR");
  }

  else {

    Serial.print("Temperature: ");
    Serial.print(t3, 1);
    Serial.println(" C");

    Serial.print("Humidity: ");
    Serial.print(h3, 1);
    Serial.println(" %");
  }

  Serial.println("------------------------------");

    Serial.println("ROOM 4");

  if (isnan(t4) || isnan(h4)) {

    Serial.println("DHT22 ERROR");
  }

  else {

    Serial.print("Temperature: ");
    Serial.print(t4, 1);
    Serial.println(" C");

    Serial.print("Humidity: ");
    Serial.print(h4, 1);
    Serial.println(" %");
  }

  Serial.println("------------------------------");

  if (rainState == LOW) {

    Serial.println("RAIN STATUS: RAIN DETECTED");
  }

  else {

    Serial.println("RAIN STATUS: NO RAIN");
  }

  Serial.println("------------------------------");

  if (WiFi.status() == WL_CONNECTED) {

    Serial.println("WIFI STATUS: CONNECTED");

    Serial.print("IP: ");
    Serial.println(WiFi.localIP());

    Serial.print("RSSI: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  }

  else {

    Serial.println("WIFI STATUS: DISCONNECTED");
  }

  Serial.println("======================================");
}

// ======================================================
// COMMAND MENU
// ======================================================

void showCommands() {

  Serial.println();
  Serial.println("======================================");
  Serial.println("SMART WINDOW MANAGEMENT SYSTEM");
  Serial.println("======================================");

  Serial.println();
  Serial.println("SENSOR:");
  Serial.println("DATA = Show sensor data");

  Serial.println();
  Serial.println("ACTUATOR 1:");
  Serial.println("1E = Extend");
  Serial.println("1R = Retract");
  Serial.println("1S = Stop");

  Serial.println();
  Serial.println("ACTUATOR 2:");
  Serial.println("2E = Extend");
  Serial.println("2R = Retract");
  Serial.println("2S = Stop");

  Serial.println();
  Serial.println("ACTUATOR 3:");
  Serial.println("3E = Extend");
  Serial.println("3R = Retract");
  Serial.println("3S = Stop");

  Serial.println();
  Serial.println("STEPPER:");
  Serial.println("SF = Forward");
  Serial.println("SR = Reverse");

  Serial.println();
  Serial.println("SYSTEM:");
  Serial.println("SA = Stop all actuators");
  Serial.println("WIFI = Show WiFi status");
  Serial.println("HELP = Show commands");

  Serial.println("======================================");
}


int readMQAverage(int pin) {
  const int sampleCount = 10;
  long total = 0;

  for (int i = 0; i < sampleCount; i++) {
    total += analogRead(pin);
    delay(5);
  }

  return total / sampleCount;
}

void calibrateMQBaseline() {

  Serial.println();
  Serial.println("======================================");
  Serial.println("CALIBRATING MQ BASELINE");
  Serial.println("Keep air around sensors clean...");
  Serial.println("======================================");

  long total1 = 0;
  long total2 = 0;
  long total3 = 0;

  const int calibrationSamples = 20;

  for (int i = 0; i < calibrationSamples; i++) {

    total1 += readMQAverage(MQ1_PIN);
    total2 += readMQAverage(MQ2_PIN);
    total3 += readMQAverage(MQ3_PIN);

    delay(100);
  }

  mq1Baseline = total1 / calibrationSamples;
  mq2Baseline = total2 / calibrationSamples;
  mq3Baseline = total3 / calibrationSamples;

  mqBaselineReady = true;

  Serial.println();
  Serial.println("========== MQ BASELINE ==========");

  Serial.print("MQ1 Baseline: ");
  Serial.println(mq1Baseline);

  Serial.print("MQ2 Baseline: ");
  Serial.println(mq2Baseline);

  Serial.print("MQ3 Baseline: ");
  Serial.println(mq3Baseline);

  Serial.println("=================================");
}

// ======================================================
// FIREBASE BACKGROUND TASK
// ======================================================

TaskHandle_t firebaseTaskHandle = NULL;



void firebaseTask(void *parameter) {

  while (true) {

    if (WiFi.status() == WL_CONNECTED) {

      float t1 = dht1.readTemperature();
      float h1 = dht1.readHumidity();

      float t2 = dht2.readTemperature();
      float h2 = dht2.readHumidity();

      float t3 = dht3.readTemperature();
      float h3 = dht3.readHumidity();

      bool rainDetected = (digitalRead(RAIN_PIN) == LOW);

      if (
        !isnan(t1) && !isnan(h1) &&
        !isnan(t2) && !isnan(h2) &&
        !isnan(t3) && !isnan(h3)
      ) {

int mq1Raw = readMQAverage(MQ1_PIN);
int mq2Raw = readMQAverage(MQ2_PIN);
int mq3Raw = readMQAverage(MQ3_PIN);

Serial.println();
Serial.println("========== MQ ANALOG DATA ==========");

Serial.print("MQ1 Room 1: ");
Serial.println(mq1Raw);

Serial.print("MQ2 Room 2: ");
Serial.println(mq2Raw);

Serial.print("MQ3 Room 3: ");
Serial.println(mq3Raw);

Serial.println("====================================");



// ======================================================
// MQ DYNAMIC DELTA DETECTION
// ======================================================

const int MQ1_DELTA_THRESHOLD = 12;
const int MQ2_DELTA_THRESHOLD = 15;
const int MQ3_DELTA_THRESHOLD = 10;

int mq1Delta = mq1Raw - mq1Baseline;
int mq2Delta = mq2Raw - mq2Baseline;
int mq3Delta = mq3Raw - mq3Baseline;

// ======================================================
// MQ CONSECUTIVE DETECTION
// ======================================================

if (mqBaselineReady) {

  // ================= MQ1 =================
  if (!mq1SmokeState) {

    // Currently NO smoke -> check for smoke
    if (mq1Delta >= MQ1_DELTA_THRESHOLD) {
      mq1HighCount++;
    } else {
      mq1HighCount = 0;
    }

    mq1LowCount = 0;

    // Need 2 HIGH readings to activate
    if (mq1HighCount >= MQ_REQUIRED_HIGH_COUNT) {
      mq1SmokeState = true;
      mq1HighCount = 0;
      mq1LowCount = 0;
    }

  } else {

    // Currently smoke -> check for recovery
    if (mq1Delta < MQ1_DELTA_THRESHOLD) {
      mq1LowCount++;
    } else {
      mq1LowCount = 0;
    }

    mq1HighCount = 0;

    // Need 2 LOW readings to clear
    if (mq1LowCount >= MQ_REQUIRED_LOW_COUNT) {
      mq1SmokeState = false;
      mq1HighCount = 0;
      mq1LowCount = 0;
    }
  }


  // ================= MQ2 =================
  if (!mq2SmokeState) {

    if (mq2Delta >= MQ2_DELTA_THRESHOLD) {
      mq2HighCount++;
    } else {
      mq2HighCount = 0;
    }

    mq2LowCount = 0;

    if (mq2HighCount >= MQ_REQUIRED_HIGH_COUNT) {
      mq2SmokeState = true;
      mq2HighCount = 0;
      mq2LowCount = 0;
    }

  } else {

    if (mq2Delta < MQ2_DELTA_THRESHOLD) {
      mq2LowCount++;
    } else {
      mq2LowCount = 0;
    }

    mq2HighCount = 0;

    if (mq2LowCount >= MQ_REQUIRED_LOW_COUNT) {
      mq2SmokeState = false;
      mq2HighCount = 0;
      mq2LowCount = 0;
    }
  }


  // ================= MQ3 =================
  if (!mq3SmokeState) {

    if (mq3Delta >= MQ3_DELTA_THRESHOLD) {
      mq3HighCount++;
    } else {
      mq3HighCount = 0;
    }

    mq3LowCount = 0;

    if (mq3HighCount >= MQ_REQUIRED_HIGH_COUNT) {
      mq3SmokeState = true;
      mq3HighCount = 0;
      mq3LowCount = 0;
    }

  } else {

    if (mq3Delta < MQ3_DELTA_THRESHOLD) {
      mq3LowCount++;
    } else {
      mq3LowCount = 0;
    }

    mq3HighCount = 0;

    if (mq3LowCount >= MQ_REQUIRED_LOW_COUNT) {
      mq3SmokeState = false;
      mq3HighCount = 0;
      mq3LowCount = 0;
    }
  }
}

bool smokeDetected1 = mq1SmokeState;
bool smokeDetected2 = mq2SmokeState;
bool smokeDetected3 = mq3SmokeState;

Serial.println();
Serial.println("========== MQ ANALOG STATUS ==========");

// MQ1
Serial.print("MQ1: ");
Serial.print(mq1Raw);
Serial.print(" | Baseline: ");
Serial.print(mq1Baseline);
Serial.print(" | Delta: ");
Serial.print(mq1Delta);
Serial.print(" | HighCount: ");
Serial.print(mq1HighCount);
Serial.print(" | LowCount: ");
Serial.print(mq1LowCount);
Serial.print(" | Smoke: ");
Serial.println(smokeDetected1 ? "YES" : "NO");

// MQ2
Serial.print("MQ2: ");
Serial.print(mq2Raw);
Serial.print(" | Baseline: ");
Serial.print(mq2Baseline);
Serial.print(" | Delta: ");
Serial.print(mq2Delta);
Serial.print(" | HighCount: ");
Serial.print(mq2HighCount);
Serial.print(" | LowCount: ");
Serial.print(mq2LowCount);
Serial.print(" | Smoke: ");
Serial.println(smokeDetected2 ? "YES" : "NO");

// MQ3
Serial.print("MQ3: ");
Serial.print(mq3Raw);
Serial.print(" | Baseline: ");
Serial.print(mq3Baseline);
Serial.print(" | Delta: ");
Serial.print(mq3Delta);
Serial.print(" | HighCount: ");
Serial.print(mq3HighCount);
Serial.print(" | LowCount: ");
Serial.print(mq3LowCount);
Serial.print(" | Smoke: ");
Serial.println(smokeDetected3 ? "YES" : "NO");

Serial.println("======================================");

sendAllSensorsToFirebase(
  t1, h1,
  t2, h2,
  t3, h3,
  rainDetected,
  smokeDetected1,
  smokeDetected2,
  smokeDetected3
);


      } else {

        Serial.println(
          "DHT22 ERROR - Background Firebase update skipped"
        );
      }
    }

    // Wait 10 seconds before next Firebase upload
    vTaskDelay(pdMS_TO_TICKS(10000));
  }
}

void handleStepperOpen() {

  Serial.println("HTTP -> STEPPER SLIDING WINDOW OPEN");

  bool rainDetected = (digitalRead(RAIN_PIN) == LOW);
  bool smokeDetected = (digitalRead(MQ3_PIN) == LOW);

  // Safety priority while Auto Mode is active
  if (autoModeEnabled && (rainDetected || smokeDetected)) {

    Serial.println(
      "WINDOW 4 OPEN BLOCKED -> RAIN/MQ3 SMOKE SAFETY ACTIVE"
    );

    server.send(
      409,
      "application/json",
      "{\"success\":false,\"message\":\"Window 4 Open Blocked - Rain/Smoke Safety Active\"}"
    );

    return;
  }

  moveStepper(HIGH, stepperSteps);

  server.send(
    200,
    "application/json",
    "{\"success\":true,\"action\":\"stepper_open\"}"
  );
}

void handleStepperClose() {
  Serial.println("HTTP -> STEPPER SLIDING WINDOW CLOSE");

  moveStepper(LOW, stepperSteps);

  server.send(
    200,
    "application/json",
    "{\"success\":true,\"action\":\"stepper_close\"}"
  );
}



// ======================================================
// SETUP
// ======================================================

void setup() {

  Serial.begin(115200);

  analogReadResolution(12);

  delay(1000);

  // ---------------- WIFI ----------------

  connectWiFi();

  // ---------------- SENSORS ----------------

  dht1.begin();
  dht2.begin();
  dht3.begin();
  dht4.begin();

  pinMode(RAIN_PIN, INPUT);

// ---------------- MQ-135 ROOM 1 & ROOM 2 ----------------

pinMode(MQ1_PIN, INPUT);
pinMode(MQ2_PIN, INPUT);
pinMode(MQ3_PIN, INPUT);
pinMode(MQ4_PIN, INPUT);

delay(3000);
calibrateMQBaseline();

Serial.println("MQ-135 ROOM 1 READY");
Serial.println("MQ-135 ROOM 2 READY");
Serial.println("MQ-135 ROOM 3 READY");
Serial.println("MQ-135 ROOM 4 READY");

  // ---------------- ACTUATORS ----------------

  pinMode(A1_RPWM, OUTPUT);
  pinMode(A1_LPWM, OUTPUT);

  pinMode(A2_RPWM, OUTPUT);
  pinMode(A2_LPWM, OUTPUT);

  pinMode(A3_RPWM, OUTPUT);
  pinMode(A3_LPWM, OUTPUT);

  stopAllActuators();

  // ---------------- STEPPER ----------------

  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);

  digitalWrite(STEP_PIN, LOW);
  digitalWrite(DIR_PIN, LOW);

  Serial.println();
Serial.println("ESP32 STARTED SUCCESSFULLY");
Serial.println("FIRMWARE POSITION TEST V3 - FIREBASE AUTO OFF");

showCommands();

// ---------------- HTTP SERVER ----------------

server.on("/", handleRoot);

server.on("/window1/open", handleWindow1Open);
server.on("/window1/close", handleWindow1Close);
server.on("/window1/position", handleWindow1Position);

server.on("/window2/open", handleWindow2Open);
server.on("/window2/close", handleWindow2Close);
server.on("/window2/position", handleWindow2Position);

server.on("/window3/open", handleWindow3Open);
server.on("/window3/close", handleWindow3Close);
server.on("/window3/position", handleWindow3Position);

// Stepper sliding window routes
server.on("/stepper/open", handleStepperOpen);
server.on("/stepper/close", handleStepperClose);

// Auto Mode routes
server.on("/automode/on", handleAutoModeOn);
server.on("/automode/off", handleAutoModeOff);
server.on("/automode/status", handleAutoModeStatus);

server.begin();

// ---------------- FIREBASE BACKGROUND TASK ----------------

xTaskCreatePinnedToCore(
  firebaseTask,          // Task function
  "FirebaseTask",        // Task name
  8192,                  // Stack size
  NULL,                  // Parameter
  1,                     // Low priority
  &firebaseTaskHandle,   // Task handle
  0                      // Run on Core 0
);

Serial.println();
Serial.println("HTTP SERVER STARTED");

Serial.print("Open: http://");
Serial.println(WiFi.localIP());
}

// ======================================================
// LOOP
// ======================================================

void loop() {

  int testMQ3 = analogRead(32);

Serial.print("DIRECT GPIO32 ADC = ");
Serial.println(testMQ3);

delay(1000);

   // ====================================================
  // LOCAL HTTP SERVER
  // ====================================================

  server.handleClient();

  // ====================================================
  // WIFI AUTO RECONNECT
  // ====================================================
  

  static unsigned long lastWiFiCheck = 0;

  if (millis() - lastWiFiCheck > 10000) {

    lastWiFiCheck = millis();

    if (WiFi.status() != WL_CONNECTED) {

      Serial.println();
      Serial.println("WiFi disconnected.");

      Serial.println("Trying to reconnect...");

      WiFi.disconnect();
      delay(500);

     WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    }
  }

  // ====================================================
// LOCAL RAIN AUTO CLOSE
// ====================================================

static bool lastRainState = false;

bool currentRainState = (digitalRead(RAIN_PIN) == LOW);

// Trigger only when rain changes from DRY -> WET
if (currentRainState && !lastRainState && autoModeEnabled) {

  Serial.println();
  Serial.println("================================");
  Serial.println("RAIN DETECTED -> AUTO CLOSE");
  Serial.println("================================");

 // Window 1 - Double Panel (A1 + A2)
Serial.println("AUTO CLOSE -> WINDOW 1 DOUBLE PANEL");
doubleWindowClose();
window1Position = 0;

// Window 2 - Single Panel (A3)
Serial.println("AUTO CLOSE -> WINDOW 2");
actuatorRetract(A3_RPWM, A3_LPWM);
window2Position = 0;

// Window 3 - Sliding Window (Stepper)
Serial.println("AUTO CLOSE -> WINDOW 3 STEPPER");
moveStepper(LOW, stepperSteps);
window3Position = 0;

  Serial.println("RAIN AUTO CLOSE COMPLETE");
Serial.println("DEBUG -> ABOUT TO SEND RAIN PUSH");

sendPushNotification(
  "Rain Detected",
  "Rain detected. Windows have been closed automatically.",
  "rain"
);

Serial.println("DEBUG -> RAIN PUSH FUNCTION FINISHED");

}

lastRainState = currentRainState;

// ====================================================
// LOCAL SMOKE / GAS AUTO CLOSE - ROOM 1
// ====================================================

static bool lastSmokeState = false;

// MQ-135 module active LOW:
// LOW  = smoke/gas detected
// HIGH = normal
bool currentSmokeState = false;

// Trigger only when NORMAL -> DETECTED
if (currentSmokeState && !lastSmokeState && autoModeEnabled) {

  Serial.println();
  Serial.println("================================");
  Serial.println("SMOKE/GAS DETECTED -> AUTO CLOSE");
  Serial.println("================================");

  Serial.println("AUTO CLOSE -> WINDOW 1");

  doubleWindowClose();
  window1Position = 0;

  Serial.println("SMOKE AUTO CLOSE COMPLETE");

Serial.println("DEBUG -> ABOUT TO SEND ROOM 1 SMOKE PUSH");

sendPushNotification(
  "Smoke Detected - Room 1",
  "Smoke or gas detected in Room 1. Window 1 has been closed automatically.",
  "smoke"
);

Serial.println("DEBUG -> ROOM 1 SMOKE PUSH FINISHED");
}

// Save current state for edge detection
lastSmokeState = currentSmokeState;

// ====================================================
// LOCAL SMOKE / GAS AUTO CLOSE - ROOM 2
// ====================================================

static bool lastSmokeState2 = false;

// MQ-135 Room 2 active LOW:
// LOW  = smoke/gas detected
// HIGH = normal
bool currentSmokeState2 = false;

// Trigger only when NORMAL -> DETECTED
if (currentSmokeState2 && !lastSmokeState2 && autoModeEnabled) {

  Serial.println();
  Serial.println("================================");
  Serial.println("SMOKE/GAS ROOM 2 -> AUTO CLOSE");
  Serial.println("================================");

  Serial.println("AUTO CLOSE -> WINDOW 2");

  actuatorRetract(A3_RPWM, A3_LPWM);
  window2Position = 0;

  Serial.println("ROOM 2 SMOKE AUTO CLOSE COMPLETE");

Serial.println("DEBUG -> ABOUT TO SEND ROOM 2 SMOKE PUSH");

sendPushNotification(
  "Smoke Detected - Room 2",
  "Smoke or gas detected in Room 2. Window 2 has been closed automatically.",
  "smoke"
);

Serial.println("DEBUG -> ROOM 2 SMOKE PUSH FINISHED");
}

// Save current state for edge detection
lastSmokeState2 = currentSmokeState2;

// ====================================================
// LOCAL SMOKE / GAS AUTO CLOSE - ROOM 3
// ====================================================

static bool lastSmokeState3 = false;

// MQ Room 3 active LOW:
// LOW  = smoke/gas detected
// HIGH = normal
bool currentSmokeState3 = false;

// Trigger only when NORMAL -> DETECTED
if (currentSmokeState3 && !lastSmokeState3 && autoModeEnabled) {

  Serial.println();
  Serial.println("================================");
  Serial.println("SMOKE/GAS ROOM 3 -> AUTO CLOSE");
  Serial.println("================================");

Serial.println("AUTO CLOSE -> WINDOW 3 STEPPER");

moveStepper(LOW, stepperSteps);
window3Position = 0;

Serial.println("ROOM 3 SMOKE AUTO CLOSE COMPLETE");

Serial.println("DEBUG -> ABOUT TO SEND ROOM 3 SMOKE PUSH");

sendPushNotification(
  "Smoke Detected - Room 3",
  "Smoke or gas detected in Room 3. Window 3 has been closed automatically.",
  "smoke"
);

Serial.println("DEBUG -> ROOM 3 SMOKE PUSH FINISHED");
}

// Save current state for edge detection
lastSmokeState3 = currentSmokeState3;

// ====================================================
// LOCAL HIGH TEMPERATURE AUTO OPEN - ALL ROOMS
// ====================================================

static unsigned long lastTemperatureCheck = 0;

static bool highTemperatureTriggered1 = false;
static bool highTemperatureTriggered2 = false;
static bool highTemperatureTriggered3 = false;

if (millis() - lastTemperatureCheck >= 5000) {

  lastTemperatureCheck = millis();

  float room1Temperature = dht1.readTemperature();
  float room2Temperature = dht2.readTemperature();
  float room3Temperature = dht3.readTemperature();

  // ==================================================
  // ROOM 1 -> WINDOW 1
  // ==================================================

  if (!isnan(room1Temperature)) {

    Serial.print("Room 1 Temperature: ");
    Serial.print(room1Temperature);
    Serial.println(" C");

    if (room1Temperature < HIGH_TEMP_THRESHOLD) {
      highTemperatureTriggered1 = false;
    }

    if (
      autoModeEnabled &&
      room1Temperature >= HIGH_TEMP_THRESHOLD &&
      !currentRainState &&
      !currentSmokeState &&
      !highTemperatureTriggered1
    ) {

      Serial.println();
      Serial.println("HIGH TEMPERATURE ROOM 1 -> AUTO OPEN W1");

      doubleWindowOpen();
      window1Position = 100;

      highTemperatureTriggered1 = true;

Serial.println("WINDOW 1 TEMPERATURE AUTO OPEN COMPLETE");

Serial.println("DEBUG -> ABOUT TO SEND ROOM 1 HIGH TEMP PUSH");

sendPushNotification(
  "High Temperature - Room 1",
  "High temperature detected in Room 1. Window 1 has been opened automatically.",
  "temperature"
);

Serial.println("DEBUG -> ROOM 1 HIGH TEMP PUSH FINISHED");
    }
  }

  // ==================================================
  // ROOM 2 -> WINDOW 2
  // ==================================================

  if (!isnan(room2Temperature)) {

    Serial.print("Room 2 Temperature: ");
    Serial.print(room2Temperature);
    Serial.println(" C");

    if (room2Temperature < HIGH_TEMP_THRESHOLD) {
      highTemperatureTriggered2 = false;
    }

    if (
      autoModeEnabled &&
      room2Temperature >= HIGH_TEMP_THRESHOLD &&
      !currentRainState &&
      !currentSmokeState2 &&
      !highTemperatureTriggered2
    ) {

      Serial.println();
      Serial.println("HIGH TEMPERATURE ROOM 2 -> AUTO OPEN W2");

      actuatorExtend(A3_RPWM, A3_LPWM);
      window2Position = 100;

      highTemperatureTriggered2 = true;

Serial.println("WINDOW 2 TEMPERATURE AUTO OPEN COMPLETE");

Serial.println("DEBUG -> ABOUT TO SEND ROOM 2 HIGH TEMP PUSH");

sendPushNotification(
  "High Temperature - Room 2",
  "High temperature detected in Room 2. Window 2 has been opened automatically.",
  "temperature"
);

Serial.println("DEBUG -> ROOM 2 HIGH TEMP PUSH FINISHED");
    }
  }

  // ==================================================
  // ROOM 3 -> WINDOW 3
  // ==================================================

  if (!isnan(room3Temperature)) {

    Serial.print("Room 3 Temperature: ");
    Serial.print(room3Temperature);
    Serial.println(" C");

    if (room3Temperature < HIGH_TEMP_THRESHOLD) {
      highTemperatureTriggered3 = false;
    }

    if (
      autoModeEnabled &&
      room3Temperature >= HIGH_TEMP_THRESHOLD &&
      !currentRainState &&
      !currentSmokeState3 &&
      !highTemperatureTriggered3
    ) {

      Serial.println();
     Serial.println("HIGH TEMPERATURE ROOM 3 -> AUTO OPEN W3");

Serial.println("AUTO OPEN -> WINDOW 3 STEPPER");

moveStepper(HIGH, stepperSteps);
window3Position = 100;

highTemperatureTriggered3 = true;

Serial.println("WINDOW 3 TEMPERATURE AUTO OPEN COMPLETE");

Serial.println("DEBUG -> ABOUT TO SEND ROOM 3 HIGH TEMP PUSH");

sendPushNotification(
  "High Temperature - Room 3",
  "High temperature detected in Room 3. Window 3 has been opened automatically.",
  "temperature"
);

Serial.println("DEBUG -> ROOM 3 HIGH TEMP PUSH FINISHED");
    }
  }
}

// ====================================================
// FIREBASE WINDOW 1 COMMAND CHECK
// ====================================================

static unsigned long lastCommandCheck = 0;

if (millis() - lastCommandCheck >= 15000) {

  lastCommandCheck = millis();

   /*readWindow1Command();*/
}

  // ====================================================
  // SERIAL COMMANDS
  // ====================================================

  if (Serial.available() > 0) {

    String command = Serial.readStringUntil('\n');

    command.trim();
    command.toUpperCase();

    if (command.length() == 0) {
      return;
    }

// SENSOR DATA
if (command == "DATA") {

  showSensors();

  // Read Room 1
  float t1 = dht1.readTemperature();
  float h1 = dht1.readHumidity();

  // Read Room 2
  float t2 = dht2.readTemperature();
  float h2 = dht2.readHumidity();

  // Read Room 3
  float t3 = dht3.readTemperature();
  float h3 = dht3.readHumidity();

  // Read Rain Sensor
  bool rainDetected = (digitalRead(RAIN_PIN) == LOW);

  // Make sure all DHT22 sensors are valid
  if (
    !isnan(t1) && !isnan(h1) &&
    !isnan(t2) && !isnan(h2) &&
    !isnan(t3) && !isnan(h3)
  ) {

int mq1State = digitalRead(MQ1_PIN);
int mq2State = digitalRead(MQ2_PIN);
int mq3State = digitalRead(MQ3_PIN);
int mq4State = digitalRead(MQ4_PIN);

// MQ sensors active LOW:
// LOW  = detected
// HIGH = normal
bool smokeDetected1 = (mq1State == LOW);
bool smokeDetected2 = (mq2State == LOW);
bool smokeDetected3 = (mq3State == LOW);

sendAllSensorsToFirebase(
  t1, h1,
  t2, h2,
  t3, h3,
  rainDetected,
  smokeDetected1,
  smokeDetected2,
  smokeDetected3
);

  } else {

    Serial.println(
      "DHT22 ERROR - Firebase data not sent"
    );
  }
}
// DOUBLE PANEL WINDOW TEST
else if (command == "DO") {

  Serial.println();
  Serial.println("DOUBLE WINDOW -> OPEN TEST");

  doubleWindowOpen();

  Serial.println("DOUBLE WINDOW -> OPEN TEST COMPLETE");
}

else if (command == "DC") {

  Serial.println();
  Serial.println("DOUBLE WINDOW -> CLOSE TEST");

  doubleWindowClose();

  Serial.println("DOUBLE WINDOW -> CLOSE TEST COMPLETE");
}
    // ACTUATOR 1
    else if (command == "1E") {

      stopAllActuators();

      Serial.println("ACTUATOR 1 -> EXTEND");

      doubleWindowOpen();

      Serial.println("ACTUATOR 1 -> AUTO STOP");
    }

    else if (command == "1R") {

      stopAllActuators();

      Serial.println("ACTUATOR 1 -> RETRACT");

      actuatorRetract(A1_RPWM, A1_LPWM);

      Serial.println("ACTUATOR 1 -> AUTO STOP");
    }

    else if (command == "1S") {

      actuatorStop(A1_RPWM, A1_LPWM);

      Serial.println("ACTUATOR 1 -> STOP");
    }

    // ACTUATOR 2
    else if (command == "2E") {

      stopAllActuators();

      Serial.println("ACTUATOR 2 -> EXTEND");

      actuatorExtend(A2_RPWM, A2_LPWM);

      Serial.println("ACTUATOR 2 -> AUTO STOP");
    }

    else if (command == "2R") {

      stopAllActuators();

      Serial.println("ACTUATOR 2 -> RETRACT");

      actuatorRetract(A2_RPWM, A2_LPWM);

      Serial.println("ACTUATOR 2 -> AUTO STOP");
    }

    else if (command == "2S") {

      actuatorStop(A2_RPWM, A2_LPWM);

      Serial.println("ACTUATOR 2 -> STOP");
    }

    // ACTUATOR 3
    else if (command == "3E") {

      stopAllActuators();

      Serial.println("ACTUATOR 3 -> EXTEND");

      actuatorExtend(A3_RPWM, A3_LPWM);

      Serial.println("ACTUATOR 3 -> AUTO STOP");
    }

    else if (command == "3R") {

      stopAllActuators();

      Serial.println("ACTUATOR 3 -> RETRACT");

      actuatorRetract(A3_RPWM, A3_LPWM);

      Serial.println("ACTUATOR 3 -> AUTO STOP");
    }

    else if (command == "3S") {

      actuatorStop(A3_RPWM, A3_LPWM);

      Serial.println("ACTUATOR 3 -> STOP");
    }

    // STEPPER
    else if (command == "SF") {

      stopAllActuators();

      Serial.println("STEPPER -> FORWARD");

      moveStepper(HIGH, stepperSteps);

      Serial.println("STEPPER -> DONE");
    }

    else if (command == "SR") {

      stopAllActuators();

      Serial.println("STEPPER -> REVERSE");

      moveStepper(LOW, stepperSteps);

      Serial.println("STEPPER -> DONE");
    }

    // STOP ALL
    else if (command == "SA") {

      stopAllActuators();

      Serial.println("ALL ACTUATORS -> STOP");
    }

    // WIFI STATUS
    else if (command == "WIFI") {

      if (WiFi.status() == WL_CONNECTED) {

        Serial.println();
        Serial.println("WIFI CONNECTED");

        Serial.print("SSID: ");
        Serial.println(WiFi.SSID());

        Serial.print("IP: ");
        Serial.println(WiFi.localIP());

        Serial.print("RSSI: ");
        Serial.print(WiFi.RSSI());
        Serial.println(" dBm");
      }

      else {

        Serial.println("WIFI DISCONNECTED");
      }
    }

    // HELP
    else if (command == "HELP") {

      showCommands();
    }

    else {

      Serial.println();

      Serial.print("UNKNOWN COMMAND: ");
      Serial.println(command);

      Serial.println("Type HELP");
    }
  }

int mq1State = digitalRead(MQ1_PIN);
int mq2State = digitalRead(MQ2_PIN);
int mq3State = digitalRead(MQ3_PIN);
int mq4State = digitalRead(MQ4_PIN);

Serial.print("MQ Room 1: ");
Serial.print(mq1State);

Serial.print(" | MQ Room 2: ");
Serial.print(mq2State);

Serial.print(" | MQ Room 3: ");
Serial.print(mq3State);

Serial.print(" | MQ Room 4: ");
Serial.println(mq4State);

delay(1000);
}