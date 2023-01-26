#include <msp430.h>

// time = distance / speed_sound
#define SPEED_SOUND 343  // m/s
#define SOUND_2CM 59     // 58.309037900874635568513119533528 us
#define SOUND_10CM 292   // 291.54518950437317784256559766764 us
#define SOUND_30CM 875   // 874.63556851311953352769679300292 us
#define SOUND_50CM 1458  // 1457.72594752186588921282798834 us
#define SOUND_4M 11660   // 11661.80758017492711370262390671 us

// clocks = time * sm_frequency
#define SMCLK_FREQ 1048576
#define SM_2CM 124      // 61.865984 * 2
#define SM_10CM 611     // 305.707288629346304 * 2
#define SM_30CM 1834    // 917.121865889087488 * 2
#define SM_50CM 3057    // 1528.536443147780096 * 2
#define SM_400CM 24452  // 12226.39616 * 2

#define TRIG_100US 100  // 10.48576

#define CLK_FREQ 1048576
#define CLK_HALF_MSEC 525
#define CLK_TWOHALF_MSEC 2621

int leave;
int arrive;
int ready;

void initConfig() {
  // P1.0 = LED1 (vermelho)
  P1REN &= ~BIT0;
  P1DIR |= BIT0;

  // P4.7 = LED2 (verde)
  P4REN &= ~BIT7;
  P4DIR |= BIT7;

  // P1.2 <-- Timer A0 canal 1 (trig)
  P1REN &= ~BIT2;
  P1DIR |= BIT2;
  P1SEL |= BIT2;

  // P1.3 <-- Timer A0 canal 2 (echo)
  P1REN &= ~BIT3;
  P1DIR &= ~BIT3;
  P1SEL |= BIT3;

  // P1.4 <-- Timer A0 canal 3 (motor)
  P1REN &= ~BIT4;
  P1DIR |= BIT4;
  P1SEL |= BIT4;

  // Timer A0 com mode up e SMclk
  TA0CTL = TASSEL__SMCLK | MC__UP | TACLR;
  TA0CCTL1 = OUTMOD_6;
  TA0CCTL2 = CAP | CM_3 | CCIE;
  TA0CCTL3 = OUTMOD_6;

  __enable_interrupt();

  TA0CCR0 = 20000 - 1;
  TA0CCR1 = TRIG_100US - 1;
  TA0CCR3 = CLK_HALF_MSEC - 1;
}

#pragma vector = 52;
__interrupt void ISR() {
  TA0CCTL2 &= ~CCIFG;
  if (P1IN & BIT3) {
    leave = TA0CCR2;
  } else {
    arrive = TA0CCR2;
    ready = 1;
  }
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  int diff;
  int convert;

  ready = 0;

  initConfig();

  while (1) {
    if (ready) {
      diff = arrive - leave;
      convert = (diff / 7) - 1;
      convert = diff - convert;
      if (convert < CLK_HALF_MSEC) {
        TA0CCR3 = CLK_HALF_MSEC;
      } else if (convert > CLK_TWOHALF_MSEC) {
        TA0CCR3 = CLK_TWOHALF_MSEC;
      } else {
        TA0CCR3 = convert;
      }
      if (diff < SM_10CM) {
        P1OUT &= ~BIT0;
        P4OUT &= ~BIT7;
      } else if (diff >= SM_10CM && diff < SM_30CM) {
        P1OUT &= ~BIT0;
        P4OUT |= BIT7;
      } else if (diff >= SM_30CM && diff < SM_50CM) {
        P1OUT |= BIT0;
        P4OUT &= ~BIT7;
      } else {
        P1OUT |= BIT0;
        P4OUT |= BIT7;
      }
    }
    ready = 0;
  }
}
