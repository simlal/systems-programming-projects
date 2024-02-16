.global main

// ...
main:
    /*
        code ici
                  */

    mov     x0, 0
    bl      exit

.section ".rodata"
fmtAcc:         .asciz  "acc:    %016lX %016lX\n"
fmtMem:         .asciz  "mem[%lu]: %016lX %016lX\n"
/*
    autres données ici
                        */
