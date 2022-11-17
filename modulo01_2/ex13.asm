; R14 = Numero usado
; R15 = Quantidade do numero

            .text
            .def MENOR

MENOR:
            push    R14
            push    R15
            mov.b   #0xFF, R14
            mov.w   #0, R15
MENOR_LOOP:
            cmp.w   #0, R13
            jeq     MENOR_BYEBYE
            dec.w   R13
            cmp.b   @R12, R14
            jeq     MENOR_EQUAL
            jlo     MENOR_MENOR
            mov.b   @R12+, R14
            mov.w   #1, R15
            jmp     MENOR_LOOP

MENOR_EQUAL:
            inc.w   R15
            inc.w   R12
            jmp     MENOR_LOOP

MENOR_MENOR:
            inc.w   R12
            jmp     MENOR_LOOP

MENOR_BYEBYE:
            mov.w   R14, R12
            mov.w   R15, R13
            pop     R15
            pop     R14
            ret
