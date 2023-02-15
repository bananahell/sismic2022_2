#include <msp430.h>
#include <stdint.h>

#define BUFFER_SIZE 16

struct {
  uint8_t buffer[BUFFER_SIZE];
  uint8_t read;
  uint8_t write;
  uint8_t size;
} rx;

uint8_t rxBuff[BUFFER_SIZE];

void initConfig() {
  rx.read = 0;
  rx.write = 0;
  rx.size = 0;

  UCA1CTL1 = UCSWRST;
  UCA1CTL0 = UCMODE_0;
  UCA1CTL1 |= UCSSEL__SMCLK;

  // errado? (38400 sem oversampling)
  // so usei 38400 porque achei documentacao assim pro bluetooth
  // 2^20 / 38400 = 27,3067 < 32
  // sem oversampling
  // BRW = 27, BRS = 0,306667 * 8 = 2,45333 => 2
  // UCA1BRW = 27;
  // UCA1MCTL = UCBRS_2;

  // certo? (38400 com os)
  // 2^20 / 38400 / 16 = 1,70667
  // BRW = 1, BRF = 0,70667 * 16 = 11,30667 => 11
  // UCA0BRW = 1;
  // UCA0MCTL = UCBRF_13 | UCOS16;

  // certo? (9600 com oversampling)
  // todo mundo na sala do zele fala que eh 9600
  // 2^20 / 9600 / 16 = 6,83
  // BRW = 6, BRF = 0,83 * 16 = 13,2 => 13
  UCA1BRW = 6;
  UCA1MCTL = UCBRF_13 | UCOS16;

  P4SEL |= BIT0;  // Transmit data � USCI_A0 UART mode
  P4SEL |= BIT3;  // Receive data � USCI_A0 UART mode

  PMAPKEYID = 0x02D52;
  P4MAP0 = PM_UCA1TXD;
  P4MAP3 = PM_UCA1RXD;

  UCA1CTL1 &= ~UCSWRST;

  UCA1IE = UCRXIE;
}

void uartPrint(char* str) {
  while (*str) {
    while (!(UCA1IFG & UCTXIFG)) {}
    UCA1TXBUF = *str++;
  }
}

int8_t uartRead(char* str) {
  if (rx.size > 0) {
    uint8_t readChars = rx.size;
    while (rx.size) {
      *str++ = rx.buffer[rx.read++];
      rx.read &= 0x0F;
      rx.size--;
    }
    return readChars;
  } else {
    return -1;
  }
}

int main() {
  WDTCTL = WDTPW | WDTHOLD;  // stop watchdog timer

  __delay_cycles(1000000);

  initConfig();

  __enable_interrupt();

  uartPrint("aloha\r\n");

  volatile uint8_t msg[10];

  while (1) {
    while (rx.size != 10) {}
    uartRead(msg);
  }
}

#pragma vector = USCI_A1_VECTOR
__interrupt void uart_a1() {
  if (rx.size < BUFFER_SIZE) {
    rx.buffer[rx.write++] = UCA1RXBUF;
    rx.write &= 0x0F;
    rx.size++;
  } else {
    UCA1IFG &= ~UCRXIFG;
  }
}
