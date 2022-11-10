            .text
            .def EX4_2

EX4_2:
            push    R6
            mov.b   6(R1), R6
            dec     4(R1)
EX4_2_loop:
            add.w   R6, 6(R1)
            dec     4(R1)
            jnz     EX4_2_loop
            pop     R6
            ret
