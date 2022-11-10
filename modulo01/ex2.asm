            .text
            .def EX2

EX2:
            mov.b   #2, R4
            mov.b   #3, R5
            mov.b   R4, R6
            dec     R5
EX2_loop:
            add.w   R6, R4
            dec     R5
            jnz     EX2_loop
            ret
