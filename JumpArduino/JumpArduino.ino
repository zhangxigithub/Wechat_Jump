
#include <SoftwareSerial.h>
#include <Servo.h> 

Servo servo;
SoftwareSerial ble(7,8);

void setup() {

  ble.begin(9600);
  digitalWrite(12,HIGH);
  servo.attach(9);
  servo.write(142);
}


String op = "";

void loop() {
//  
//    servo.write(142);
//    delay(700);
//    servo.write(148);
//    delay(700);
//    return;
  
 if( ble.available() > 0 ){
    op += char(ble.read());
    delay(3);
  }
  if(op.endsWith("#") == false)
  {
    return;
  }

  String action = op.substring(0,1);


  if (action == "m")
  {
    int x      = op.substring(1,5).toInt();
  
    ble.println(x+20);
    ble.println("begin");
    ble.println(x);

    servo.write(148);
    delay(x);
    servo.write(142);
    //ble.println("svgfinish");
  }
  op = "";
}











