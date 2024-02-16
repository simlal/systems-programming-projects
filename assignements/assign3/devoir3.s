.global main

// ...
main:
    /*
        code ici
                  */

    mov     x0, 0
    bl      exit

.section ".bss"
                .align  16
acc             .skip   16
mem             .skip   16*4

.section ".rodata"
fmtAcc:         .asciz  "acc:    %016lX %016lX\n"
fmtMem:         .asciz  "mem[%lu]: %016lX %016lX\n"
/*
    autres données ici
                        */
