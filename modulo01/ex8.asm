            .data

vetor:      .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

            .text
            .def sum8

sum8:
            push    R4
            mov.w   #vetor, R12
            mov.w   #10, R13
            clr R4
LOOP_START:
            add.b   @R12+, R4
            dec.w   R13
            jnz     LOOP_START
            mov.w   R4, R12
            pop     R4
            ret
