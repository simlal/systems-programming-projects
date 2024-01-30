.global main

// ...
main:

// Entrees et sauvegarde des 2 unsigned int avec stdlib de C
    adr     x0, fmtStrOut
    adr     x1, msgInput
    bl      printf

inputs:
    mov     x19, 2
    mov     x20, 10
    mov     x21, 0
//inputs:
//    adr     x0, fmtLuIn
//    adr     x1, num
//    bl      scanf
//    ldr     x19, num
//    
//    adr     x0, fmtLuIn
//    adr     x1, num
//    bl      scanf
//    ldr     x20, num

// Affichage des entrees (sortie)
print_inputs:
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf
    adr     x0, fmtLuOut
    mov     x1, x20
    bl      printf

    adr     x0, fmtStrOut
    adr     x1, msgSep
    bl      printf

// Loop entre x19 et x20 pour avoir la liste des entiers
loop_input_range:
    mov     x22, 2    
    udiv    x23, x19, x22    
    msub    x23, x22, x23, x19    // remainder = (divisor*quotient) - dividend
    
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf    // print loop
    adr     x0, fmtLuOut
    mov     x1, x23
    bl      printf    // print remainder

    cbz     x23, skip_primecount
    add     x21, x21, 1    // ++Total de nombre premier sinon skip

skip_primecount:
    // Incrementation et test de fin de boucle
    add     x19, x19, 1
    cmp     x19, x20    
    b.eq    end
    b       loop_input_range

// "Filter" si les nombres sont premiers, compter

// Palindrome check, compter

// Redirection vers le output

end:
    // Fin
    adr     x0, fmtStrOut
    adr     x1, msgOut
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
msgSep:         .asciz  "######\n"
msgOut:         .asciz  "### FIN! ###\n"
