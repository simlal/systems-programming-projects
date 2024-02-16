.global main

main:

// Initialisation acc et mem
acc_mem_init:
    mov     x2, 0                           // init a 0 pour acc    
    mov     x3, 0                           
    adr     x1, acc                         // unsigned long int *pAcc;
    str     x2, [x1]                        
    add     x1, x1, 8
    str     x3, [x1]                        // *pAcc = 0;
    
// Affichage initial en hex
    adr     x0, fmtAcc
    mov     x1, x2
    mov     x2, x3
    bl      printf


end:
    mov     x0, 0
    bl      exit

.section ".bss"
                .align  16
acc:            .skip   16
mem:            .skip   64                              //(16*4)

.section ".rodata"
fmtAcc:         .asciz  "acc:    %016lX %016lX\n"
fmtMem:         .asciz  "mem[%lu]: %016lX %016lX\n"