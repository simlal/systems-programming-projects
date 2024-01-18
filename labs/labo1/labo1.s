.global main

// Entrée: lit trois entiers positifs de 64 bits: a, b, c
// Sortie: "valide"   si a ≤ b ≤ c et a² + b² = c²
//         "invalide" sinon
// Usage des registres:
//   x19 -- a  ...
main:
    // Lectures des entrees                      
    adr     x0, fmtEntree           
    adr     x1, nombre              
    bl      scanf                     
    ldr     x19, nombre     // a dans x19

    adr     x0, fmtEntree
    adr     x1, nombre
    bl      scanf
    ldr     x20, nombre     // b dans x20

    // Lire c
    adr     x0, fmtEntree
    adr     x1, nombre
    bl      scanf
    ldr     x21, nombre     // c dans x21

    // affichage de l'entree clavier
    adr     x0, fmtSortie
    mov     x1, x19
    bl      printf
    adr     x0, fmtSortie
    mov     x1, x20
    bl      printf
    adr     x0, fmtSortie
    mov     x1, x21
    bl      printf

    // Verif si triplet trier ordre croissanc
    cmp     x19, x20
    b.hs    invalide        // si a >= b  goto invalide    
    cmp     x20, x21
    b.hs    invalide        // si b >= c goto invalide
        
    // Validation pythagore sachant a < b < c
    // carre sur chaque valeur
    mul     x19, x19, x19
    mul     x20, x20, x20
    mul     x21, x21, x21
    
    add     x22, x19, x20   // somme de b2+c2 dans nouveau reg
    cmp     x22, x21
    b.ne   invalide

    // Affichage valide croissant + pythagore
    adr     x0, msgValide
    bl      printf
    b       fin
    
invalide:
    // Affichage invalide
    adr     x0, msgInvalide
    bl      printf
    b       fin

fin:
    // Quitter
    mov   x0, 0                     //
    bl    exit                      //

.section ".bss"
                .align  8
nombre:         .skip   8

.section ".rodata"
fmtEntree:      .asciz  "%lu"
fmtSortie:      .asciz  "%lu\n"
msgValide:      .asciz  "valide\n"
msgInvalide:    .asciz  "invalide\n"
