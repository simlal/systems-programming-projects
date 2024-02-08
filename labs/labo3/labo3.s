.global main
main:
// Lire la taille et le contenu de la carte
read_map_size:
    adr     x0, fmtNum 
    adr     x1, temp
    bl      scanf
    ldr     x19, temp           // Dimension m de carte (x19)

    adr     x0, fmtNum 
    adr     x1, temp
    bl      scanf
    ldr     x20, temp           // Dimension n de carte (x20)


// Lecture de carte

// init array carte
    adr     x21, carte
    mov     x22, 0          // iterateur de array i=0
    mul     x23, x19, x20   // taille max pour fin iteration
    
read_map:
    // Lecture de stdin pour 1 char de 1 byte
    adr     x0, fmtChar
    mov     x1, x21
    bl      scanf

    // Saut de 1 ele sur le pointeur de carte et iterateur
    add     x21, x21, 1
    add     x22, x22, 1
    cmp     x22, x23
    b.lt    read_map
    
    // Reset pointeur debut carte et iterateur
    adr     x21, carte
    mov     x22, 0
    mov     x24, 0          // Compteur de mouvement

traverse_map:
    ldrb    w1, [x21, x22]  // Get valeurs a l'adresse actuelle
    add     x24, x24, 1     // Increment de 1 movement

    // char '>' (62) -> i++
    cmp     w1, 62
    b.eq    go_right    

    // char '<' (60) -> i--
    cmp     w1, 60
    b.eq    go_left

    // char 'v' (118) -> i += n
    cmp     w1, 118
    b.eq    go_down
    
    // char '^' (94) -> i -= n
    cmp     w1, 94
    b.eq    go_up

    // char '*' (42) -> end
    cmp     w1, 42
    b.eq    possible_end   

go_right:
    add     x22, x22, 1
    b       check_and_loop

go_left:
    sub     x22, x22, 1
    b       check_and_loop

go_down:
    add     x22, x22, x20
    b       check_and_loop

go_up:
    sub     x22, x22, x20
    b       check_and_loop

// Validation completion de carte
check_and_loop:    
    cmp     x24, x23        // nb_mouve > m*n = impossible
    b.gt    impossible_end 
    
    b    traverse_map       // Retour dans boucle de lecture

// Output pour fin possible ou non
impossible_end:
    adr     x0, fmtStr
    adr     x1, msgBoucle
    bl      printf
    
    mov     x0, 0
    bl      exit

possible_end:
    sub     x24, x24, 1     // Retrait de 1 car * ne compte pas comme un mouvement
    
    // Affichage de x24 
    adr     x0, msgAtteint
    mov     x1, x24
    bl      printf

    mov     x0, 0
    bl      exit

.section ".rodata"
    fmtNum:         .asciz "%lu"
    fmtChar:        .asciz " %c" // l'espace est importante, ne pas l'enlever
    fmtStr:         .asciz "%s"
    msgAtteint:     .asciz "Cible atteinte en %lu déplacements.\n"
    msgBoucle:      .asciz "La cible ne sera jamais atteinte.\n"
.section ".bss"
    temp:           .skip 8
    carte:          .skip 10000     // dimension max 100x100
