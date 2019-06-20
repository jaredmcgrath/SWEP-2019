#define NO_PORTD_PINCHANGES // to indicate that port d will not be used for pin change interrupts
#include <PinChangeInt.h> //Needed with the above line to have more interrupts that dont interfere with the Xbee --- WAS PinChangeInt.h before, I couldn't find that library, but found PinChangeInterrupt instead
#include <SoftSerialFix.h>

SoftSerialFix XBee(4,5)

void setup() {
  // put your setup code here, to run once:
  XBee.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:

}
