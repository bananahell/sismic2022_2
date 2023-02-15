#include <msp430.h>
#include <stdint.h>

volatile uint16_t adcResult;

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  TA0CTL = MC__UP | TASSEL__SMCLK;
  TA0CCR0 = 10486 - 1;  // 100-1;
  TA0CCTL0 = CCIE;

  // zerar de enable conversion
  ADC12CTL0 = 0;
  // SHT=16 batidas de clock (3u segundos) e liga conversor AD
  ADC12CTL0 = ADC12SHT0_2 | ADC12ON;
  // guarda resultado no mem5 e usa bit SC como inicio a conv. e usa o timer
  // interno do adc12 e usa o MODCLK como clock do ADC @5Mhz e modo single
  // chanel e single conversion
  ADC12CTL1 =
      ADC12CSTARTADD_5 | ADC12SHS_0 | ADC12SHP | ADC12SSEL_0 | ADC12CONSEQ_0;
  // desligar sensor de temperatura pra ecnomia de energia, usa resolucao de 12
  // bits, fs ate 50ksps(remover para 200ksps)
  ADC12CTL2 = ADC12TCOFF | ADC12RES_2 | ADC12SR;
  // usa referencia padrao AVSS e AVCC e configura entrada no p6.6
  ADC12MCTL5 = ADC12SREF_0 | ADC12INCH_6;
  // usa interrupcao do mem5
  ADC12IE = ADC12IE5;

  __enable_interrupt();

  while (1) {
    __low_power_mode_0();
  }
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void ADC_TRIGGER() {
  ADC12CTL0 |= ADC12ENC;  // habilita o trigger
  ADC12CTL0 &= ~ADC12SC;  // gera flanco de subida no bit SC
  ADC12CTL0 |= ADC12SC;
}

#pragma vector = ADC12_VECTOR
__interrupt void ADC_RESULT() {
  adcResult = ADC12MEM5;
}
