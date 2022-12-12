;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

RT_TAM:     .equ    6
CONF2:      .equ    4
CONF3:      .equ    1

RT_TAM_: .equ    26
CONF2_:  .equ    13
CONF3_:  .equ    20

MAIN:
            mov.w   #MSG, R5
            mov.w   #GSM, R6
            call    #ENIGMA
            mov.w   #GSM, R5
            mov.w   #DCF, R6
            call    #ENIGMA
            jmp     $

ENIGMA:
            push    R7                      ; R7 = Uso variado
            push    R15                     ; R15 = letra ou num de agora
            mov.w   #0, R8                  ; Inicializa o contador de letras

ENIGMA_LOOP:
            mov.b   @R5+, R15               ; Peguei uma letra da frase
            cmp.w   #0, R15                 ; Se eh zero, fim da frase
            jz      ENIGMA_QUIT
CHECA_SIMBOLO:
            cmp.w   #'A', R15               ; Se for menor que 'A'
            jl      ESCREVE_CIFRA           ; so escreve na cifra
            cmp.w   #'[', R15               ; ou maior que 'Z'
            jge     ESCREVE_CIFRA           ; so escreve na cifra
TRATA_LETRA:
            sub.w   #'A', R15               ; Subtraio por 'A'
ROTORES_IN:
            mov.w   #CONF2_, R7
            call    #COLOCA_CONFIG          ; Coloca na config 2
            mov.w   #RT2_, R7
            call    #LETRA_RT               ; Rodo a letra no rotor 2
            mov.w   #CONF3_, R7
            call    #COLOCA_CONFIG          ; Coloca na config 3
            mov.w   #RT3_, R7
            call    #LETRA_RT               ; Rodo a letra no rotor 3
REFLETOR:
            mov.w   #RF1_, R7
            call    #LETRA_RF               ; Rodo a letra no refletor
ROTORES_OUT:
            mov.w   #RT3_, R7
            call    #PROCURA_RT             ; Procuro a letra no rotor 3
            mov.w   #CONF3_, R7
            call    #TIRA_CONFIG            ; Tira da config 3
            mov.w   #RT2_, R7
            call    #PROCURA_RT             ; Procuro a letra no rotor 2
            mov.w   #CONF2_, R7
            call    #TIRA_CONFIG            ; Tira da config 2
            add.w   #'A', R15               ; Somo 'A' de novo
ESCREVE_CIFRA:
            mov.b   R15, 0(R6)              ; Coloco a nova letra
            inc.w   R6                      ; Vai pra proxima letra na cifra
            jmp     ENIGMA_LOOP

COLOCA_CONFIG:
            add.w   R7, R15                 ; Coloco a letra na config
            cmp.w   #RT_TAM_, R15
            jl      CHECK_CONFIG_IN         ; Checa se eh menor que o maximo
            sub.w   #RT_TAM_, R15            ; Subtrai do maximo se nao
CHECK_CONFIG_IN:
            ret

TIRA_CONFIG:
            sub.w   R7, R15                 ; Tiro a letra da config
            cmp.w   #0, R15
            jge     CHECK_CONFIG_OUT        ; Checa se eh maior ou zero
            add.w   #RT_TAM_, R15            ; Soma do maximo se sim
CHECK_CONFIG_OUT:
            ret

LETRA_RT:
            add.w   R7, R15                 ; Acho o endereco no rotor
            mov.b   @R15, R15               ; Pego o valor do rotor
            ret

LETRA_RF:
            add.w   R7, R15                 ; Acho o endereco no refletor
            mov.b   @R15, R15               ; Pego o valor do refletor
            ret

PROCURA_RT:
            push    R7                      ; Vou iterar no rotor
            push    R8
            mov.w   #0, R8                  ; Contador de indice no rotor
LOOP_PROCURA:
            cmp.b   @R7+, R15               ; Se achou o numero procurado
            jeq     FIM_LOOP_PROCURA        ; Retorn o indice dele no rotor
            inc.w   R8                      ; Procurar no proximo indice
            jmp     LOOP_PROCURA
FIM_LOOP_PROCURA:
            mov.w   R8, R15
            pop     R8
            pop     R7
            ret

ENIGMA_QUIT:
            pop     R15
            pop     R7
            ret

            .data

MSG:        .byte   "NTIADV QJOBD ADCIJUBN J CNRBUJT ZDBJLLD. VJ D VJAYDB PIUVJB N VDTIGND OJ NALU-BDLDB, PIJ JY ZNUV JWUGUJALJ J UALJBJVVNALJ, ZNV ZNUV OUWUGUT, VD WNTNB GDZ D QJOBD!", 0
GSM:        .byte   "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 0
DCF:        .byte   "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ", 0

RT1:        .byte   2, 4, 1, 5, 3, 0
RT2:        .byte   1, 5, 3, 2, 0, 4
RT3:        .byte   4, 0, 5, 2, 3, 1
RT4:        .byte   3, 4, 1, 5, 2, 0
RT5:        .byte   5, 2, 3, 4, 1, 0

RF1:        .byte   3, 5, 4, 0, 2, 1
RF2:        .byte   4, 5, 3, 2, 0, 1
RF3:        .byte   3, 2, 1, 0, 5, 4

RT1_:       .byte   20, 6, 21, 25, 11, 15, 16, 18, 0, 7, 1, 22, 9, 17, 24, 5
            .byte   8, 23, 19, 13, 12, 14, 3, 2, 10, 4
RT2_:       .byte   12, 18, 25, 22, 2, 23, 9, 5, 3, 6, 15, 14, 24, 11, 19, 4
            .byte   8, 21, 17, 7, 16, 1, 0, 10, 13, 20
RT3_:       .byte   23, 21, 18, 2, 15, 14, 0, 25, 3, 8, 4, 17, 7, 24, 5, 10
            .byte   11, 20, 22, 1, 12, 9, 16, 6, 19, 13
RT4_:       .byte   22, 21, 7, 0, 16, 3, 4, 8, 2, 9, 23, 20, 1, 11, 25, 5, 24
            .byte   14, 12, 6, 18, 13, 10, 19, 17, 15
RT5_:       .byte   20, 17, 13, 11, 25, 16, 23, 3, 19, 4, 24, 5, 1, 12, 8, 9
            .byte   15, 22, 6, 0, 21, 7, 14, 18, 2, 10

RF1_:       .byte   14, 11, 25, 4, 3, 22, 20, 18, 15, 13, 12, 1, 10, 9, 0, 8
            .byte   24, 23, 7, 21, 6, 19, 5, 17, 16, 2
RF2_:       .byte   1, 0, 16, 25, 6, 24, 4, 23, 14, 13, 17, 18, 19, 9, 8, 22
            .byte   2, 10, 11, 12, 21, 20, 15, 7, 5, 3
RF3_:       .byte   21, 7, 5, 19, 18, 2, 16, 1, 14, 22, 24, 17, 20, 25, 8, 23
            .byte   6, 11, 4, 3, 12, 0, 9, 15, 10, 13

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
