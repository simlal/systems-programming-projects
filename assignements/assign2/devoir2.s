.global main

// ...
main:

// Entrees et sauvegarde des 2 unsigned int avec stdlib de C
    adr     x0, fmtStrOut
    adr     x1, msgInput
    bl      printf

inputs:
    adr     x0, fmtLuIn
    adr     x1, num
    bl      scanf
    ldr     x19, num
    
    adr     x0, fmtLuIn
    adr     x1, num
    bl      scanf
    ldr     x20, num

// Loop entre x19 et x20 pour avoir la liste des entiers

// "Filter" si les nombres sont premiers, compter

// Palindrome check, compter

// Redirection vers le output

outputs:
    // Affichage des entrees (sortie)
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf
    adr     x0, fmtLuOut
    mov     x1, x20
    bl      printf

    // Fin
    mov     x0, 0
    bl      exit

.section ".bss"
                .align  8
num:            .skip   8                

.section ".rodata"
fmtLuIn:        .asciz  "%lu"
fmtLuOut:       .asciz  "%lu\n"
fmtStrOut:      .asciz  "%s"
msgInput:       .asciz  "Entrer 2 uint consecutivement:\n"
messageGen:     .asciz  "Sorties\n:"