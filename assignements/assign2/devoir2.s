.global main

// ...
main:

// Entrees et sauvegarde des 2 unsigned int avec stdlib de C
    adr     x0, fmtStrOut
    adr     x1, msgInput
    bl      printf

temp_inputs:
    mov     x19, 2
    mov     x20, 30
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

initialisation:
    mov     x21, 0                          // Total prime num
    add     x20, x20, 1                     // Loop finale dans boucle dernier ele

// Outer loop entre x19 et x20 pour avoir la liste des entiers
input_loop_start:
    mov     x22, 2                          // Iterateur pour division premier
    mov     x24, 1                          // Flag pour nb premier (1 == prime)
    udiv    x25, x19, x22                   // Reduction boucle premier (n/2 == n)     

prime_loop_start:
    cmp     x22, x25                        // Valide si on sort de boucle prime
    b.gt    check_prime                     // et flag prime a ete modif

    udiv    x23, x19, x22    
    msub    x23, x22, x23, x19              // x23 remainder = (divisor*quotient) - dividend
    
    // Si remainder != 0, skip au prochain int a tester
    cbz     x23, not_prime

    // Incremente le diviseur test premier
    add     x22, x22, 1
    b       prime_loop_start

// Set flag a 0 (non-prime) et continue la boucle externe
not_prime:
    mov     x24, 0
    b       input_loop_increment

// Fin de boucle premier
check_prime:
    cbz     x24, input_loop_increment
    add     x21, x21, 1                     // ++Total de nombre premier sinon skip

// Incrementation liste int et test de fin de boucle
input_loop_increment:
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf

    adr     x0, fmtLuOut
    mov     x1, x25
    bl      printf

    add     x19, x19, 1
    
    cmp     x19, x20                        // Fin outer loop liste de int
    b.eq    end
    b       input_loop_start

// Palindrome check, compter

// Redirection vers le output

end:
    // Fin
    adr     x0, fmtStrOut
    adr     x1, msgSep
    bl      printf
    
    adr     x0, fmtLuOut
    mov     x1, x21    // Prime count
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
