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

// Affichage des entrees (sortie)
print_inputs:
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf
    adr     x0, fmtLuOut
    mov     x1, x20
    bl      printf

// Loop entre x19 et x20 pour avoir la liste des entiers
loop:
    // Affichage loop pour debug
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf
    // incrementation
    cmp     x19, x20
    b.eq    end
    add     x19, x19, 1
    b       loop


// "Filter" si les nombres sont premiers, compter

// Palindrome check, compter

// Redirection vers le output

end:
    // Fin
    adr     x0, fmtStrOut
    adr     x1, msgInput
    bl      printf
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