
#include <SoftwareSerial.h>
#include <Servo.h> 

Servo servo;
//SoftwareSerial ble(30,31);


void setup() {
  Serial3.begin(9600);
  //ble.begin(9600);
  digitalWrite(12,HIGH);
  servo.attach(9);
  servo.write(152);
}


String op = "";

void loop() {
  //servo.write(155);
 // return;
//  
   // servo.write(142);
   // delay(700);
   // servo.write(148);
   // delay(700);
   // return;
  
 if( Serial3.available() > 0 ){
    op += char(Serial3.read());
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
  
    Serial3.println(x+20);
    Serial3.println("begin");
    Serial3.println(x);

    servo.write(155);
    delay(x);
    servo.write(152);
    //ble.println("svgfinish");
  }
  op = "";
}











