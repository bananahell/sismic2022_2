            .text
            .def MAIOR16

MAIOR16:
            push    R14
            push    R15
            mov.w   #0x8000, R14
            mov.w   #0, R15

MAIOR16_LOOP:
            cmp.w   #0, R13
            jeq     MAIOR16_BYEBYE
            sub.w   #2, R13
            cmp.w   @R12, R14
            jge     MAIOR16_MAIOR
            mov.w   @R12+, R14
            mov.w   #1, R15
            jmp     MAIOR16_LOOP

MAIOR16_MAIOR:
            jeq     MAIOR16_EQUAL
            add.w   #2, R12
            jmp     MAIOR16_LOOP

MAIOR16_EQUAL:
            inc.w   R15
            add.w   #2, R12
            jmp     MAIOR16_LOOP

MAIOR16_BYEBYE:
            mov.w   R14, R12
            mov.w   R15, R13
            pop     R15
            pop     R14
            ret
