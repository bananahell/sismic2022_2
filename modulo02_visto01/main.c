#include <msp430.h>

void debounce() {
  volatile int i = 50000;
  while (i--) {}
}

void initConfig() {
  // P1.0 = LED1 (vermelho)
  P1REN &= ~BIT0;
  P1DIR |= BIT0;

  // P2.1 = botao S1
  P2OUT |= BIT1;
  P2REN |= BIT1;
  P2DIR &= ~BIT1;
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  initConfig();

  while (1) {
    debounce();
    while (P2IN & BIT1) {}
    P1OUT ^= BIT0;
    debounce();
    while (!(P2IN & BIT1)) {}
  }
}
