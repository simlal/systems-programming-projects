.global main

main:
// Test sans stdin
// non_man_inputs:
//     ldr     x19, =5000
//     ldr     x20, =15000

// Capture des entrees de uint >= 2
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
                                            // et pas de check palindrome
    // Incrementation diviseur et boucle
    add     x22, x22, 1
    b       prime_loop_start

// Fin de boucle premier (inner-loop)
add_prime:
    add     x21, x21, 1                     // ++Total de nombre premier sinon skip
    b       one_digit_palindrome            // Pas necessaire mais plus clair

one_digit_palindrome:
    // Palindrome check pour int entre 2-9
    cmp     x19, 10
    b.ge    palindrome_loop_init            // Passe
    add     x25, x25, 1                     // Ajout total palindrome

palindrome_loop_init:
    // Skip algo palindrome si one digit
    cmp     x19, 10
    b.lt    input_loop_increment

    // Initialisation pour renverser le nombre
    mov     x22, 10                         // Constante pour divison et modulo b10
    mov     x26, x19                        // Copie nb a renverser
    mov     x27, 0                          // Conteneur nb renverse

palindrome_loop:
    udiv    x28, x26, x22                    // Extraction des chiffres poids + fort
    msub    x26, x28, x22, x26               // Extraction du chiffre poids faible
    mul     x27, x27, x22                    // Ajustement de la base10 en fonction de pos
    add     x27, x27, x26                   // Somme avec iteration(s) precendente(s)
    mov     x26, x28                        // Recule de 1 chiffre de poids fort
    cbnz    x26, palindrome_loop            // Si 0 on sort de boucle

    // Comparaison x19 et x27 (x19 inverse)
    cmp     x19, x27
    b.ne    input_loop_increment            // Skip si x19 != x27 apres renversement
    add     x25, x25, 1

// Incrementation et fin outer loop liste de int
input_loop_increment:
    add     x19, x19, 1
    cmp     x19, x20                        
    b.eq    end
    b       input_loop_start

// Affichage des totaux et sortie
end:
    adr     x0, fmtLuOut
    mov     x1, x21                         // Tot premiers
    bl      printf

    adr     x0, fmtLuOut
    mov     x1, x25                        // Premier ET palindrome
    bl      printf

    mov     x0, 0
    bl      exit

.section ".bss"
                .align  8
num:            .skip   8                

.section ".rodata"
fmtLuIn:        .asciz  "%lu"
fmtLuOut:       .asciz  "%lu\n"
