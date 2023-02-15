#include <msp430.h>

void initConfig() {
  UCA1CTL1 = UCSWRST;
  UCA1CTL1 |= UCSSEL__SMCLK;

  UCA1BRW = 6;
  UCA1MCTL = UCOS16 | UCBRF_13;

  P4SEL |= BIT4;
  P4SEL |= BIT5;

  UCA1CTL1 &= ~UCSWRST;

  UCA1IE |= UCRXIE;
}

void uartPrint(char* str) {
  while (*str) {
    while (!(UCA1IFG & UCTXIFG)) {}
    UCA1TXBUF = *str++;
  }
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  __delay_cycles(1000000);

  initConfig();

  uartPrint("hello world\n\r\0");

  return 0;
}
