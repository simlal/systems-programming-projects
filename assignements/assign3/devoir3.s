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
    adr     x19, acc                        
    // Init a 0 aux 2 adresses
    str     xzr, [x19]                        
    add     x19, x19, 8
    str     xzr, [x19]
    sub     x19, x19, 8

// Alloc memoire (n=4) de 128bits avec pointeur debut x20
mem_init:
    mov     x23, 4                      // taille mem (n)
    adr     x20, mem                         
    mov     x21, x20                    // Facilite reset *p apres sortie de boucle incrementation                         

mem_loop_init:                          // Init a 0 pour chaque element de mem
    cbz     x23, calc_loop_start               
    str     xzr, [x21]                        
    add     x21, x21, 8
    str     xzr, [x21]
    add     x21, x21, 8

    sub     x23, x23, 1                 // Decrementation du n
    b       mem_loop_init


// ###### Entrer dans boucle d'execution ######
// Utilise ss-prog: print_calc_ele(fmt, pointeurEle, index)

calc_loop_start:
// Affichage accumulateur (pAcc=x19)
    adr     x0, fmtAcc
    mov     x1, x19
    mov     x2, 4                       // 'Index' de 4 pour diff avec mem dans ss-prog print
    bl      print_calc_ele

// Affichage mem (pMem=x20) avec boucle
print_mem_init:
    mov     x21, x20                    // Facilite reset *p apres sortie de boucle incrementation                         
    mov     x22, 4                      // n=4
    mov     x23, 0                      // compteur i=0                           

print_mem_loop:
    cbz     x22, scan_input
    adr     x0, fmtMem
    mov     x1, x21
    mov     x2, x23                     
    bl      print_calc_ele

    add     x21, x21, 16                // mem[i+1] de 128 bits
    sub     x22, x22, 1                 // n--
    add     x23, x23, 1                 // i++
    
    b       print_mem_loop

//  Chercher code + op/effet avec entree (i=x21) et effet (j=x22)
scan_input:
    adr     x0, fmtOpeIn
    adr     x1, ope
    bl      scanf
    ldr     x21, ope                    // operation i=x21

    // Chercher effet 'j'
    adr     x0, fmtOpeIn
    adr     x1, ope
    bl      scanf
    ldr     x22, ope                    // effet j=x22
    
// ###### Logique 'switch case' pour choisir l'operation (i) a faire et entree (j) a appliquer

// Operation i=0 avec effet: acc <- j
eval_op0:
    cmp     x21, xzr
    b.ne    eval_op1

    // Charger la valeur de j a l'adresse pointee en memoire par acc
    str     x22, [x19]
    add     x19, x19, 8
    str     xzr, [x19]                  // 0 dans 2e registre car u long 64 bits en entree
    sub     x19, x19, 8

    b       calc_loop_start

// Operation i=1 avec effet: mem[j] <- acc
eval_op1:
    mov     x23, 1
    cmp     x21, x23
    b.ne    eval_op2

    // Copie adresses de acc meme
    mov     x23, x19
    mov     x24, x20
    // Chercher adresse de mem[j]
    mov     x25, 16                     // Saut de 16 bytes
    mul     x22, x22, x25
    add     x24, x24, x22               // Deplacer vers debut de mem[j]
    
    // Charger valeur de acc dans mem
    ldr     x25, [x23]
    str     x25, [x24]                  // Copie registre acc-1 dans mem[j]-1
    
    add     x23, x23, 8                 // Avance dans acc-2
    ldr     x25, [x23]
    add     x24, x24, 8                 // Avance dans mem[j]-2
    str     x25, [x24]                  // Copie acc-2 dans mem[j]-2

    b       calc_loop_start

eval_op2:

end:
    mov     x0, 0
    bl      exit

 // Test print debug
    //adr     x0, fmtOpeOut
    //mov     x1, x21
    //bl      printf


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
    ldr     x2, [x19]       // Registre 64bits poids fort
    ldr     x1, [x20]       // Registre 64bits poids plus faible
    b       call_printf    
set_mem_printf:
    // Set les arguments de mem pour printf
    mov     x1, x22
    ldr     x3, [x19]
    ldr     x2, [x20]
call_printf:
    bl      printf
    
    RESTORE
    ret

.section ".bss"
                .align  8
acc:            .skip   16
mem:            .skip   64                              //(16*4)
ope:            .skip   8       // long unsigned int 64 bits

.section ".rodata"
fmtAcc:         .asciz  "acc:    %016lX %016lX\n"
fmtMem:         .asciz  "mem[%lu]: %016lX %016lX\n"
fmtOpeIn:       .asciz  "%lu"
fmtOpeOut:      .asciz  "%lu\n"