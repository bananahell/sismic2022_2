#include <msp430.h>

void debounce() {
  volatile int i = 10000;
  while (i--) {}
}

void initConfig() {
  // P1.0 = LED1 (vermelho)
  P1REN &= ~BIT0;
  P1DIR |= BIT0;

  // P4.7 = LED2 (verde)
  P4REN &= ~BIT7;
  P4DIR |= BIT7;

  // P2.1 = botao S1
  P2OUT |= BIT1;
  P2REN |= BIT1;
  P2DIR &= ~BIT1;

  // P1.1 = botao S2
  P1OUT |= BIT1;
  P1REN |= BIT1;
  P1DIR &= ~BIT1;

  // P1.4 <-- Timer A0 canal 3
  P1REN &= ~BIT4;
  P1DIR |= BIT4;
  P1SEL |= BIT4;

  // Timer A0 com mode up e Aclk
  TA0CTL = TASSEL__ACLK | MC__UP | TACLR;
  TA0CCTL3 = OUTMOD_6;

  TA0CCR0 = 655 - 1;
  TA0CCR3 = 17 - 1;  // Vai de 81 - 1 a 17 - 1
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  int counter;

  initConfig();

  while (1) {
    debounce();
    while ((P2IN & BIT1) && (P1IN & BIT1)) {}

    if (!(P2IN & BIT1)) {
      if (TA0CCR3 < 81) {
        TA0CCR3++;
      }
      P1OUT |= BIT0;
      debounce();
      counter = 0;
      while (!(P2IN & BIT1)) {
        if ((TA0CCR3 < 81) && (counter % 100 == 0)) {
          TA0CCR3++;
        }
        counter++;
      }
      P1OUT &= ~BIT0;

    } else {
      if (TA0CCR3 > 17) {
        TA0CCR3--;
      }
      TA0CCR3--;
      P4OUT |= BIT7;
      debounce();
      counter = 0;
      while (!(P1IN & BIT1)) {
        if ((TA0CCR3 > 17) && (counter % 100 == 0)) {
          TA0CCR3--;
        }
        counter++;
      }
      P4OUT &= ~BIT7;
    }
  }
}
