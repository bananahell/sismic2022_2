            .text
            .def EX1

EX1:
            mov.w   #0xFFF0, R4
            mov.w   #0xFFF0, R5
            add.w   R4, R5
            jc COM_CARRY
            ret
COM_CARRY:
            mov.w   #0xFFFF, R5
            ret
