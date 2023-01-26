#include <msp430.h>

#include "libs/i2c.h"
#include "libs/lcd.h"

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  i2cConfig();

  lcdConfig();
  lcdPrint("FINALMENTE");

  return 0;
}
