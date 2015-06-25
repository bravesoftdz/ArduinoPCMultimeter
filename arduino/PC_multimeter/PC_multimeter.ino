/*
Multimeter
*/
byte modebyte=0;
byte eingang = 0;
byte pin = 3;
int wert=1;
void setup() {
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() >0) {
    modebyte = Serial.read();
    if (modebyte > 47 && modebyte < 54) {
      while (Serial.available() < 1) {}
      wert = analogRead(modebyte-48);
      if (wert<10) {Serial.print("0");}
      if (wert<100) {Serial.print("0");}
      if (wert<1000) {Serial.print("0");}
      Serial.print(wert);
    
    } else if (modebyte == 5) {
      Serial.write(6);
    } else if (modebyte == 80) { // pwm modulation am anfang ein P dann pinindex (siehe Case) und dann den byte wert der stärke
      //Serial.print('1');
      while (Serial.available() < 2) {}
      eingang = Serial.read()-48;
      //Serial.print('2');
      switch (eingang) {
        case 0:
          pin = 3;
          break;
        case 1:
          pin = 5;
          break;
        case 2:
          pin = 6;
          break;
        case 3:
          pin = 9;
          break;
        case 4:
          pin = 10;
          break;
        case 5:
          pin = 11;
          break;
      }
      //Serial.print('3');
      wert = Serial.read();
      analogWrite(pin,wert);
      //Serial.print('4');
    }
  }
}
