            .text
            .def EX4

EX4:
            push    R6
            mov.b   R12, R6
            dec     R13
EX4_loop:
            add.w   R6, R12
            dec     R13
            jnz     EX4_loop
            pop     R6
            ret
