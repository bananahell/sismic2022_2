; R5 = Mensagem em claro
; R6 = Mensagem cifrada
; R7 = Trama do Rotor 1
; R8 = Char que vou trabalhar

            .text
            .def EXP1

EXP1:
            push    R5
            push    R6
            push    R7
            push    R8
            mov.w   #EXP1_MSG, R5
            mov.w   #EXP1_GSM, R6
            mov.w   #EXP1_RT1, R7

ENIGMA1:
            mov.b   @R5+, R8
            cmp.w   #0, R8                  ; Se eh zero, fim da frase
            jz      EXP1_QUIT
            sub.w   #65, R8                 ; Subtraio por 'A'
            add.w   R7, R8                  ; Acho o endereco no rotor
            mov.b   @R8, R8                 ; Pego o valor do rotor
            add.w   #65, R8                 ; Somo 'A' de novo
            mov.b   R8, 0(R6)               ; Coloco a nova letra
            inc.w   R6
            jmp     ENIGMA1

EXP1_QUIT:
            pop     R8
            pop     R7
            pop     R6
            pop     R5
            ret

            .data

EXP1_MSG:   .byte   "CABECAFEFACAFAD", 0    ; Mensagem em claro
EXP1_GSM:   .byte   "XXXXXXXXXXXXXXX", 0    ; Mensagem cifrada
EXP1_RT1:   .byte   2, 4, 1, 5, 3, 0        ; Trama do Rotor 1

; Resposta: BCEDBCADACBCACF
