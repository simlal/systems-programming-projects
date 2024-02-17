.global main

// ###### Macros save/restore ###### //
.macro SAVE
    stp   x29, x30, [sp, -96]!
    mov   x29, sp
    stp   x27, x28, [sp, 16]
    stp   x25, x26, [sp, 32]
    stp   x23, x24, [sp, 48]
    stp   x21, x22, [sp, 64]
    stp   x19, x20, [sp, 80]
.endm

.macro RESTORE
    ldp   x27, x28, [sp, 16]
    ldp   x25, x26, [sp, 32]
    ldp   x23, x24, [sp, 48]
    ldp   x21, x22, [sp, 64]
    ldp   x19, x20, [sp, 80]
    ldp   x29, x30, [sp], 96
.endm


// ###### Point d'entree ###### // 

main:

// ###### Initialisation de acc et mem a 0 ######
acc_init:
    // Alloc memoire 128bits avec pointeur debut x19
    mov     x22, 0    // Constante 0 pour fill init                           
    adr     x19, acc                        
    mov     x20, x19
    // Init a 0 aux 2 adresses
    str     x22, [x20]                        
    add     x20, x20, 8
    str     x22, [x20]
    
    // Affichage
    adr     x0, fmtAcc
    mov     x1, x19
    mov     x2, 4    // 'Index' de 4 pour diff avec mem dans ss-prog print
    bl      print_calc_ele

// Alloc memoire (n=4) de 128bits avec pointeur debut x20
mem_init:
    mov     x22, 0    // Constante 0 pour fill init
    mov     x23, 4    // n=4
    mov     x24, 0    // compteur i                           
    adr     x20, mem                         
    mov     x21, x20    // Copie pour incrementation                         
// Init a 0 pour chaque element de mem
mem_loop_init:
    cbz     x23, end               
    str     x22, [x21]                        
    add     x21, x21, 8
    str     x22, [x21]
    add     x21, x21, 8

    // Appel printf
    adr     x0, fmtMem
    mov     x1, x20
    mov     x2, x24
    bl      print_calc_ele
    
    sub     x23, x23, 1     // Decrementation du n
    add     x24, x24, 1     // Incrementation index i
    b       mem_loop_init

// ###### Entrer dans boucle d'execution ###### // 
// TODO

end:
    mov     x0, 0
    bl      exit

// ###### Ss-programme pour affichage d'un element ###### //

// Affichage print_calc_ele(x0=format-type, x1=adresse-data, x2=indice)
print_calc_ele:
    SAVE
    
    // Chercher les deux pointeurs de long uint 
    mov     x19, x1    
    add     x20, x19, 8
    // Validation index pour appel printf 2vs3 args
    mov     x21, 4
    mov     x22, x2    // flag de acc (4) ou mem[i]
    cmp     x22, x21
    b.lt    set_mem_printf    
    // Set les arguments de acc pour printf
    ldr     x1, [x19]
    ldr     x2, [x20]
    b       call_printf    
set_mem_printf:
    // Set les arguments de mem pour printf
    mov     x1, x22
    ldr     x2, [x19]
    ldr     x3, [x20]
call_printf:
    bl      printf
    
    RESTORE
    ret

.section ".bss"
                .align  16
acc:            .skip   16
mem:            .skip   64                              //(16*4)

.section ".rodata"
fmtAcc:         .asciz  "acc:    %016lX %016lX\n"
fmtMem:         .asciz  "mem[%lu]: %016lX %016lX\n"
