#include <msp430.h>

#define A_CLK 0

// HALF_MSEC = (0.5 / 1000) * CLK_FREQ
// TWOHALF_MSEC = (2.5 / 1000) * CLK_FREQ
#if A_CLK == 0
#define CLK_FREQ 32768
#define CLK_HALF_MSEC 17
#define CLK_TWOHALF_MSEC 81
#define CLK_SEL TASSEL__ACLK
#define COUNTER_DELAY 50
#else
#define CLK_FREQ 1048576
#define CLK_HALF_MSEC 525
#define CLK_TWOHALF_MSEC 2621
#define CLK_SEL TASSEL__SMCLK
#define COUNTER_DELAY 4
#endif

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
  TA0CTL = CLK_SEL | MC__UP | TACLR;
  TA0CCTL3 = OUTMOD_6;

  TA0CCR0 = CLK_TWOHALF_MSEC + 1;
  TA0CCR3 = CLK_HALF_MSEC - 1;
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  int counter;

  initConfig();

  while (1) {
    debounce();
    while ((P2IN & BIT1) && (P1IN & BIT1)) {}

    if (!(P2IN & BIT1)) {
      P1OUT |= BIT0;
      debounce();
      counter = 0;
      while (!(P2IN & BIT1)) {
        if ((TA0CCR3 < CLK_TWOHALF_MSEC) && (counter % COUNTER_DELAY == 0)) {
          TA0CCR3++;
        }
        counter++;
      }
      P1OUT &= ~BIT0;

    } else {
      P4OUT |= BIT7;
      debounce();
      counter = 0;
      while (!(P1IN & BIT1)) {
        if ((TA0CCR3 > CLK_HALF_MSEC) && (counter % (COUNTER_DELAY * 4) == 0)) {
          TA0CCR3--;
        }
        counter++;
      }
      P4OUT &= ~BIT7;
    }
  }
}
