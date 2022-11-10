; R5 = Mensagem em claro
; R6 = Mensagem cifrada
; R7 = Uso geral
; R8 = Uso geral
; R9 = Uso geral
; R10 = Uso geral
; R11 = Uso geral
; R12 = Uso geral
; 4(SP) = Trama do Anti-Rotor
; 2(SP) = Trama do Rotor
; 0(SP) = Tabela do Refletor

            .text
            .def EXP2

EXP2:
            push    R5
            push    R6
            push    R7
            push    R8
            push    R9
            push    R10
            push    R11
            push    R12
            push    #EXP2_ART1
            push    #EXP2_RT1
            push    #EXP2_RF1
            mov.w   #1, R5                  ; Quant de rotores
            mov.w   SP, R7
            add.w   #2, R7                  ; Endereco na pilha do rotor
            mov.w   SP, R8
            add.w   #4, R8                  ; Endereco na pilha do anti-rotor

EXP2_ANTIGEN:
            cmp.w   #0, R5                  ; Se zero, acabaram rotores
            jz      EXP2_START
            mov.w   #6, R6                  ; Tam dos rotores
            mov.w   @R7, R9                 ; Endereco na memo do rotor
            mov.w   @R8, R10                ; Endereco na memo do anti-rotor
            mov.w   #0, R12                 ; Contador
EXP2_ANTIROT:
            mov.b   @R9+, R11               ; Pego num do rotor
            add.w   R10, R11                ; Pego posicao do num no anti-rotor
            mov.b   R12, 0(R11)             ; Salvo o contador no anti-rotor
            inc.w   R12                     ; Contador olha proximo valor
            dec.w   R6
            jnz     EXP2_ANTIROT            ; Se zero, terminou rotor
            dec.w   R5                      ; Conta para o proximo rotor
            add.w   #2, R7                  ; Proximo rotor na pilha
            add.w   #2, R8                  ; Proximo anti-rotor na pilha
            jmp     EXP2_ANTIGEN

EXP2_START:
            mov.w   #EXP2_MSG, R5
            mov.w   #EXP2_GSM, R6

ENIGMA2:
            mov.b   @R5+, R7
            cmp.w   #0, R7                  ; Se zero, fim da frase
            jz      EXP2_QUIT
            sub.w   #65, R7                 ; Subtraio por 'A'
            add.w   2(SP), R7               ; Acho o endereco no rotor
            mov.b   @R7, R7                 ; Pego o valor do rotor
            add.w   0(SP), R7               ; Acho o endereco no refletor
            mov.b   @R7, R7                 ; Pego o valor do refletor
            add.w   4(SP), R7               ; Acho o endereco no anti-rotor
            mov.b   @R7, R7                 ; Pego o valor do anti-rotor
            add.w   #65, R7                 ; Somo 'A' de novo
            mov.b   R7, 0(R6)
            inc.w   R6
            jmp     ENIGMA2

EXP2_QUIT:
            pop     R3                      ; Tiro o refletor da pilha
            pop     R3                      ; Tiro o rotor da pilha
            pop     R12
            pop     R11
            pop     R10
            pop     R9
            pop     R8
            pop     R7
            pop     R6
            pop     R5
            ret

            .data

EXP2_MSG:   .byte   "CABECAFEFACAFAD", 0    ; Mensagem em claro
EXP2_GSM:   .byte   "XXXXXXXXXXXXXXX", 0    ; Mensagem cifrada
EXP2_DCF:   .byte   "XXXXXXXXXXXXXXX", 0    ; Mensagem decifrada
EXP2_RT1:   .byte   2, 4, 1, 5, 3, 0        ; Trama do Rotor
EXP2_ART1:  .byte   0, 0, 0, 0, 0, 0        ; Trama do Anti-Rotor
EXP2_RF1:   .byte   3, 5, 4, 0, 2, 1        ; Tabela do Refletor

; Resposta: DBAFDBEFEBDBEBC
