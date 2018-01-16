#include <Servo.h> 

Servo servo;


void setup() {
  Serial3.begin(9600);

  servo.attach(9);
  servo.write(152);
}


String op = "";

void loop() {

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

    servo.write(155);
    delay(x);
    servo.write(152);
  }
  op = "";
}











