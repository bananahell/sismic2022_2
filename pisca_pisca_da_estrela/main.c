#include <msp430.h>

void initConfig() {
  // P1.0 = LED1 (vermelho)
  P1REN &= ~BIT0;
  P1DIR |= BIT0;

  // P4.7 = LED2 (verde)
  P4REN &= ~BIT7;
  P4DIR |= BIT7;

  // Timer A0 com mode up e Aclk
  TA0CTL = TASSEL__ACLK | MC__UP | TACLR;

  TA0CCR0 = 0x80 - 1;
  TA0CCR3 = (TA0CCR0 >> 4) - 1;
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  initConfig();

  while (1) {
    while (!(TA0CCTL3 & CCIFG)) {}
    TA0CCTL3 &= ~CCIFG;
    P1OUT ^= BIT0;
    while (!(TA0CCTL0 & CCIFG)) {}
    TA0CCTL0 &= ~CCIFG;
    P4OUT ^= BIT7;
  }
}
