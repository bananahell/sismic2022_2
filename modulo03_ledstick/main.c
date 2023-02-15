#include <msp430.h>
#include <stdint.h>

#include "libs/i2c.h"
#include "libs/lcd.h"

volatile uint16_t adcResultX;
volatile uint16_t adcResultY;

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

  TA0CTL = MC__UP | TASSEL__ACLK;
  TA0CCR0 = 128 - 1;
  TA0CCR1 = TA0CCR0 >> 1;
  TA0CCTL1 = OUTMOD_6;

  ADC12CTL0 = 0;

  ADC12CTL0 = ADC12SHT0_2 | ADC12ON;

  ADC12CTL1 =
      ADC12CSTARTADD_4 | ADC12SHS_1 | ADC12SHP | ADC12SSEL_0 | ADC12CONSEQ_3;

  ADC12CTL2 = ADC12TCOFF | ADC12RES_0 | ADC12SR;

  ADC12MCTL4 = ADC12SREF_0 | ADC12INCH_1;

  ADC12MCTL5 = ADC12SREF_0 | ADC12INCH_2 | ADC12EOS;

  ADC12IE = ADC12IE5;

  P6SEL |= BIT1 | BIT2;

  ADC12CTL0 |= ADC12ENC;
  ADC12CTL0 &= ~ADC12SC;
  ADC12CTL0 |= ADC12SC;

  __enable_interrupt();

  while (1) {
    __low_power_mode_0();
  }
}

#pragma vector = ADC12_VECTOR
__interrupt void ADC_RESULT() {
  adcResultX = ADC12MEM4;
  adcResultY = ADC12MEM5;
}
