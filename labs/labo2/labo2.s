.global main

// ...
main:

inputs:
    // Entree des 2 signed ints 16-bits
    adr     x0, fmtEntree
    adr     x1, digit
    bl      scanf
    adr     x19, digit
    ldrsh   x19, [x19]                      // Etend le bit poids fort(signe sur 32bits)

    adr     x0, fmtEntree
    adr     x1, digit
    bl      scanf
    adr     x20, digit
    ldrsh   x20, [x20]                      // Etend bit signe sur 32 bits

    // Affichage des entrees
    adr     x0, fmtSortie
    mov     x1, x19
    bl      printf
    
    adr     x0, fmtSortie
    mov     x1, x20
    bl      printf

init_loop:
    mov     x21, 2                          // Constante pour decalage de bits
    mov     x24, 0                          // Container pour calcul multiplication

loop_mult:
    cbz     x20, end                        // Sortie de boucle
    
    udiv    x22, x20, x21                   // Division de b / 2    
    msub    x23, x21, x22, x20              // Reste de b / 2
    
    cbz     x23, bit_shift                  // current b % 2 == 0 donc pas += current a
    add     x24, x19, x24                   // Somme de a dans container multiplication

bit_shift:
    add     x19, x19, x19                   // Decalage de a vers la "droite" en b2 (a*2)
    udiv    x20, x20, x21                   // Decalage de b vers la "gauche" en b2 (b/2)
    bl      loop_mult        

// Affichage resultat en 32bit (%d) et sortie
end:
    adr     x0, fmtSortie
    mov     x1, x24
    bl      printf

    mov     x0, 0
    bl      exit

.section ".bss"
                    .align  2               // Aligne par step de 2 bytes
digit:              .skip   2               // Reserve 2 bytes pour stdin                    

.section ".rodata"
fmtEntree:          .asciz  "%hd"           // half-decimal en C donc 2bytes=16bits
fmtSortie:          .asciz  "%d\n"          // decimal en C donc affichage sur 32bits
