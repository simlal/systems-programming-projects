.include "macros.s"
.global  main

main:
    // Lecture de la chaine de characteres
    adr     x0, fmtLecture
    adr     x1, chaine
    bl      scanf
    adr     x19, chaine

    adr     x0, fmtInUint
    adr     x1, numOp
    bl      scanf
    
    ldr     x20, numOp          
    mov     x0, x19         // String dans x0 pour appel ss-prog

    // Aller au ss-prog choisit
cond_op0:
    cbnz    x20, cond_op1
    bl      operation0
    b       end
cond_op1:
    cmp     x20, 1
    b.ne   cond_op2
    bl      operation1
    b       end
cond_op2:
    cmp     x20, 2
    b.ne   cond_op3
    bl      operation2
    b       end
cond_op3:
    cmp     x20, 3
    b.ne   cond_op4
    bl      operation3
    b       end
cond_op4:
    cmp     x20, 4
    b.ne   cond_op5
    bl      operation4
    b       end
cond_op5:
    cmp     x20, 5
    b.ne   op_error
    bl      operation5
    b       end
op_error:
    adr     x0, fmtOutMsg
    adr     x1, MsgError
    bl      printf

end:
    mov     x0, 0
    bl      exit

//**************** Operation 0: Taille de chaine ****************//
operation0:
    SAVE

    mov     x19, x0         // char* tabChar (ou x0 = tabChar)
    mov     x21, 0          // uint taille = 0
    mov     x22, 0          // uint k = 0

boucle_op0:
    ldrb    w20, [x19]      // char currentChar = *tabChar
    cbz     w20, retour_taille    // while (currentChar != 0/null)  
    
    // currentChar sur 1 byte
    lsr     w23, w20, 7
    cbnz    w23, twobytes_check
    
    mov     x22, 1      // k=1
    b       increm_avance

// currentChar sur 2 bytes (k=2)
twobytes_check:
    and     w23, w20, 0b11100000
    cmp     w23, 0b11000000
    b.ne    threebytes_check
    
    mov     x22, 2      // k=2
    b       increm_avance

threebytes_check:
    and     w23, w20, 0b11110000
    cmp     w23, 0b11100000
    b.ne    fourbytes_check

    mov     x22, 3      // k=3
    b       increm_avance

fourbytes_check:
    and     w23, w20, 0b11111000
    cmp     w23, 0b11110000
    b.ne    increm_avance     

    mov     x22, 4      // k=4

increm_avance:
    add     x19, x19, x22    // Avance pCurrentChar de k byte(s)
    add     x21, x21, 1      // taille++
    b       boucle_op0

retour_taille:
    adr     x0, fmtOutInt
    mov     x1, x21
    bl      printf

    RESTORE
    ret
    
//**************** Operation 1: Taille de chaine ****************//
// Recoit x0: char* tabChar sous format ASCII (chaque char sur 1byte)
// x20: int taille
// w21: char en position actuelle
operation1:
    SAVE

    // Initialisation
    mov     x19, x0     // char* tabAscii
    mov     x20, 0      // uint taille = 0

// Boucle iterationr char par char
boucle_op1:
    ldrb    w21, [x19]      // char currentChar = *tabAscii
    cbz     w21, retour_leet        // char null donc fin de la string
    
    // Eval lettre majuscule par normalisation par 'A'=65
    sub     w22, w21, 65
    cmp     w22, 25
    b.ls    check_voyelle

    // Eval lettre minuscule par normalisation par 'a'=97
    sub     w22, w21, 97
    cmp     w22, 25
    b.ls    check_voyelle

    // Pas une lettre donc aucune modif
    b       increm_leet

// Modification des voyelles avec w23 pour changement
check_voyelle:
    cmp     w22, 0
    b.ne    switch_e
    mov     w23, 52     // char swapVal = '4'
    b       remplacement_leet
    
switch_e:
    cmp     w22, 4
    b.ne    switch_i
    mov     w23, 51     // char swapVal = '3'
    b       remplacement_leet

switch_i:
    cmp     w22, 8
    b.ne    switch_o
    mov     w23, 49     // char swapVal = '1'
    b       remplacement_leet

switch_o:
    cmp     w22, 14
    b.ne    consonne
    mov     w23, 48     // char swapVal = '0'
    b       remplacement_leet

consonne:
    b       check_parite

// Modification du casing en fonction de la position
check_parite:
    tbnz    x20, 0, impair_mod

    // Lettre en position pair, MAJ->min
    cmp     w21, 90
    b.gt    increm_leet    // deja minuscule
    
    // Faire le swap
    add     w23, w21, 32
    b       remplacement_leet

impair_mod:
    // Lettre pos impair, min->MAJ
    cmp     w21, 97
    b.lt    increm_leet     //deja MAJ

    // Faire le swap
    sub     w23, w21, 32

remplacement_leet:
    strb     w23, [x19]    // *tabAscii = swapVal

increm_leet:
    add     x20, x20, 1
    add     x19, x19, 1
    b       boucle_op1

retour_leet:
    sub     x19, x19, x20       // Remettre pointeur au premier charactere
    adr     x0, fmtOutMsg
    mov     x1, x19
    bl      printf

    RESTORE
    ret

//**************** Operation 2: Taille de chaine ****************//
operation2:
    SAVE

    RESTORE
    ret

//**************** Operation 3: Taille de chaine ****************//
operation3:
    SAVE

    RESTORE
    ret
    
//**************** Operation 4: Taille de chaine ****************//
operation4:
    SAVE

    RESTORE
    ret
    
//**************** Operation 5: Taille de chaine ****************//
operation5:
    SAVE

    RESTORE
    ret
    

.section ".data"
// Mémoire allouée pour une chaîne de caractères d'au plus 1024 octets
chaine:     .skip   1024
numOp:      .skip   8    


.section ".rodata"
// Format pour lire une chaîne de caractères d'une ligne (incluant des espaces)
fmtLecture:     .asciz  "%[^\n]s"
// Formattage pour I/O uint
fmtInUint:      .asciz  "%u"
fmtOutInt:      .asciz  "%u\n"


// Message d'erreur operation
fmtOutMsg:      .asciz  "%s\n"
MsgError:       .asciz  "Erreur! Entrer un code d'operation entre 0 et 5."