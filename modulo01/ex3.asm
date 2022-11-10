            .text
            .def EX3

EX3:
            mov.w   #2, R4
            mov.w   #-3, R5
            add.w   R4, R5
            jn      EX3_NEG
            jnz     EX3_NZERO
            ret
EX3_NEG:
            sub.w   #1, R5
            ret
EX3_NZERO:
            add.w   #1, R5
            ret
