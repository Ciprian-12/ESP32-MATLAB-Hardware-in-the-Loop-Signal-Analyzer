#include <ESP32Servo.h>

Servo motor;
int tipSemnal = 1; 
float frecventa = 1.0; 
unsigned long timpStart = 0;
bool sistemActiv = true; // <-- Magia pentru Pornire/Oprire

void setup() {
  Serial.begin(115200);
  motor.attach(18);
  timpStart = micros();
}

void loop() {
  if (Serial.available() > 0) {
    String msg = Serial.readStringUntil('\n');
    msg.trim();
    
    if (msg == "S") tipSemnal = 1;
    else if (msg == "D") tipSemnal = 2;
    else if (msg == "T") tipSemnal = 3;
    else if (msg == "P") sistemActiv = true;   // Ascultă butonul PORNIRE
    else if (msg == "O") sistemActiv = false;  // Ascultă butonul OPRIRE
    else if (msg.startsWith("F:")) {
      frecventa = msg.substring(2).toFloat();
    }
  }

  int valoare = 0;

  // Generăm semnal doar dacă sistemul e pornit
  if (sistemActiv) {
    float t = (micros() - timpStart) / 1000000.0;
    
    if (tipSemnal == 1) valoare = 2000 + (sin(2 * PI * frecventa * t) * 1800);
    else if (tipSemnal == 2) valoare = (sin(2 * PI * frecventa * t) > 0) ? 3800 : 200;
    else if (tipSemnal == 3) valoare = 4000 * abs(2 * (frecventa * t - floor(frecventa * t + 0.5)));
    
    motor.write(map(valoare, 0, 4095, 0, 180));
  }

  Serial.println(valoare); // Dacă e oprit, va trimite pur și simplu "0"
  
  delay(4);
}