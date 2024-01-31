.global main

// ...
main:

// Entrees et sauvegarde des 2 unsigned int avec stdlib de C
    adr     x0, fmtStrOut
    adr     x1, msgInput
    bl      printf

temp_inputs:
    mov     x19, 10
    mov     x20, 20
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
    mov     x21, 0                          // Total nb premiers
    mov     x25, 0                          // Total palindromes
    add     x20, x20, 1                     // Loop finale dans boucle dernier ele

// Outer loop entre x19 et x20 pour avoir la liste des entiers
input_loop_start:
    mov     x22, 2                          // Iterateur pour division premier
    udiv    x24, x19, x22                   // Reduction boucle premier max (n/2)     

prime_loop_start:
    cmp     x22, x24                        // Valide si on sort de boucle prime
    b.gt    add_prime                       // et ajout au total sinon test prime-remainder

    // Test nb premier avec le reste de la division de x19 / innerloop (2->x19/2)
    udiv    x23, x19, x22    
    msub    x23, x22, x23, x19              // remainder = (divisor*quotient) - dividend
    cbz     x23, input_loop_increment       // Si remainder != 0, skip au prochain int a tester

    // Incremente le diviseur test premier
    add     x22, x22, 1
    b       prime_loop_start

// Fin de boucle premier (inner-loop)
add_prime:
    add     x21, x21, 1                     // ++Total de nombre premier sinon skip
    b       input_loop_increment

// Palindrome check
//palindrome_check:
//    cmp     x19, 10
//    b.lt    10

// Incrementation liste int + palindrome check + fin outer loop
input_loop_increment:
    adr     x0, fmtLuOut
    mov     x1, x19
    bl      printf

    adr     x0, fmtLuOut
    mov     x1, x24
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
