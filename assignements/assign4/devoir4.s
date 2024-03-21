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

    mov     x19, x0         // char* pCurrentChar (ou x0 = tabChar)
    mov     x21, 0          // uint taille = 0
    mov     x22, 0          // uint k = 0

boucle_op0:
    ldrb    w20, [x19]      // char currentChar = *pCurrentChar
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
operation1:
    SAVE

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