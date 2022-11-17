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
            .def EXP3

EXP3_RT_TAM:.equ    6
EXP3_CONF1: .equ    1

EXP3:
            push    R5
            push    R6
            push    R7
            push    R8
            push    R9
            push    R10
            push    R11
            push    R12
            push    #EXP3_ART1
            push    #EXP3_RT1
            push    #EXP3_RF1
            mov.w   #1, R5                  ; Quant de rotores
            mov.w   SP, R7
            add.w   #2, R7                  ; Endereco na pilha do rotor
            mov.w   SP, R8
            add.w   #4, R8                  ; Endereco na pilha do anti-rotor

EXP3_ANTIGEN:
            cmp.w   #0, R5                  ; Se zero, acabaram rotores
            jz      ENIGMA3_START
            mov.w   #6, R6                  ; Tam dos rotores
            mov.w   @R7, R9                 ; Endereco na memo do rotor
            mov.w   @R8, R10                ; Endereco na memo do anti-rotor
            mov.w   #0, R12                 ; Contador
EXP3_ANTIROT:
            mov.b   @R9+, R11               ; Pego num do rotor
            add.w   R10, R11                ; Pego posicao do num no anti-rotor
            mov.b   R12, 0(R11)             ; Salvo o contador no anti-rotor
            inc.w   R12                     ; Contador olha proximo valor
            dec.w   R6
            jnz     EXP3_ANTIROT            ; Se zero, terminou rotor
            dec.w   R5                      ; Conta para o proximo rotor
            add.w   #2, R7                  ; Proximo rotor na pilha
            add.w   #2, R8                  ; Proximo anti-rotor na pilha
            jmp     EXP3_ANTIGEN

ENIGMA3_START:
            mov.w   #EXP3_MSG, R5
            mov.w   #EXP3_GSM, R6
ENIGMA3:
            mov.b   @R5+, R7
            cmp.w   #0, R7                  ; Se zero, fim da frase
            jz      ENIGMA3_DCF_START
            sub.w   #65, R7                 ; Subtraio por 'A'
            add.w   #EXP3_CONF1, R7         ; Coloco a letra na config
            cmp.w   #EXP3_RT_TAM, R7
            jl      ENIGMA3_CONFIG_IN          ; Checa se eh maior que o maximo
            sub.w   #EXP3_RT_TAM, R7        ; Subtrai do maximo se sim
ENIGMA3_CONFIG_IN:
            add.w   2(SP), R7               ; Acho o endereco no rotor
            mov.b   @R7, R7                 ; Pego o valor do rotor
            add.w   0(SP), R7               ; Acho o endereco no refletor
            mov.b   @R7, R7                 ; Pego o valor do refletor
            add.w   4(SP), R7               ; Acho o endereco no anti-rotor
            mov.b   @R7, R7                 ; Pego o valor do anti-rotor
            sub.w   #EXP3_CONF1, R7         ; Coloco a letra na config de novo
            cmp.w   #0, R7
            jge     ENIGMA3_CONFIG_OUT         ; Checa se eh menor que o minimo
            add.w   #EXP3_RT_TAM, R7        ; Subtrai do maximo se sim
ENIGMA3_CONFIG_OUT:
            add.w   #65, R7                 ; Somo 'A' de novo
            mov.b   R7, 0(R6)
            inc.w   R6
            jmp     ENIGMA3

ENIGMA3_DCF_START:
            mov.w   #EXP3_GSM, R5
            mov.w   #EXP3_DCF, R6
ENIGMA3_DCF:
            mov.b   @R5+, R7
            cmp.w   #0, R7                  ; Se zero, fim da frase
            jz      EXP3_QUIT
            sub.w   #65, R7                 ; Subtraio por 'A'
            add.w   #EXP3_CONF1, R7         ; Coloco a letra na config
            cmp.w   #EXP3_RT_TAM, R7
            jl      ENIGMA3_DCF_CONFIG_IN   ; Checa se eh maior que o maximo
            sub.w   #EXP3_RT_TAM, R7        ; Subtrai do maximo se sim
ENIGMA3_DCF_CONFIG_IN:
            add.w   2(SP), R7               ; Acho o endereco no rotor
            mov.b   @R7, R7                 ; Pego o valor do rotor
            add.w   0(SP), R7               ; Acho o endereco no refletor
            mov.b   @R7, R7                 ; Pego o valor do refletor
            add.w   4(SP), R7               ; Acho o endereco no anti-rotor
            mov.b   @R7, R7                 ; Pego o valor do anti-rotor
            sub.w   #EXP3_CONF1, R7         ; Coloco a letra na config de novo
            cmp.w   #0, R7
            jge     ENIGMA3_DCF_CONFIG_OUT  ; Checa se eh menor que o minimo
            add.w   #EXP3_RT_TAM, R7        ; Subtrai do maximo se sim
ENIGMA3_DCF_CONFIG_OUT:
            add.w   #65, R7                 ; Somo 'A' de novo
            mov.b   R7, 0(R6)
            inc.w   R6
            jmp     ENIGMA3_DCF

EXP3_QUIT:
            pop     R3                      ; Tiro o refletor da pilha
            pop     R3                      ; Tiro o rotor da pilha
            pop     R3                      ; Tiro o anti-rotor da pilha
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

EXP3_MSG:   .byte   "CABECAFEFACAFAD", 0    ; Mensagem em claro
EXP3_GSM:   .byte   "XXXXXXXXXXXXXXX", 0    ; Mensagem cifrada
EXP3_DCF:   .byte   "XXXXXXXXXXXXXXX", 0    ; Mensagem decifrada
EXP3_RT1:   .byte   2, 4, 1, 5, 3, 0        ; Trama do Rotor
EXP3_ART1:  .byte   0, 0, 0, 0, 0, 0        ; Trama do Anti-Rotor
EXP3_RF1:   .byte   3, 5, 4, 0, 2, 1        ; Tabela do Refletor

; Resposta: DBAFDBEFEBDBEBC
