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
    
//**************** Operation 1: Casses et substitutions ****************//
// Recoit x0: char* tabChar sous format ASCII (chaque char sur 1byte)
// x20: int taille
// w21: char en position actuelle
// w22: operation arithmetique sur char actuel ASCII
// w23: char pour swap au besoin
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

//**************** Operation 2: Hex-vers-Dec ****************//
// Recoit x0: char* tabChar sous format ASCII (1byte/char) commence tjrs par 0x
// x19: copie de x0 tabChar
// x20: index pour iteration inverse de la chaine SANS '0x'
// x21: qte bits de poids faible SANS '0x'
// x22: accumulateur pour conversion decimal
// w23: char en position actuel (a l'inverse)
// x24: init pour exposant 16
// x25 copie position x21
operation2:
    SAVE

// Initialisation et skip '0x'
    mov     x19, x0     // char* tabAscii
    mov     x20, 0      // int i = 0 pour indexage inverse
    mov     x21, 0      // int position bit poids faible = 0
    mov     x22, 0      // int acc = 0

    add     x19, x19, 2

// Boucle calcul de taille pour index
boucle_taille_op2:
    ldrb    w23, [x19]
    cbz     w23, reset_index_string_hex        
    add     x20, x20, 1
    add     x19, x19, 1
    b       boucle_taille_op2

reset_index_string_hex:
    sub     x19, x19, x20

// Lecture a partir de la fin en fct de la taille
boucle_lecture_inverse:
    cbz     x20, retour_hex_dec     // index == 0 donc fin de lecture inverse
    sub     x20, x20, 1     // --i
    ldrb    w23, [x19, x20]     // Lire char en position actuel a l'inverse

    // Check 0-9 vs A-F
    cmp     w23, 65
    b.lt    conv_chiffres
    
    sub     w23, w23, 55        // Conversion lettre A-F en hex ascii vers decimal
    b       init_calcul_exposant

conv_chiffres:
    sub     w23, w23, 48        // Conversion chiffres 0-9 vers dec

// Somme (chiffre-pos * 16 ^ position) avec boucle
init_calcul_exposant:
    mov     x24, 1 
    mov     x25, x21        // Copie pour calcul exposant
    cbz     x25, ajout_accumulateur    // Skip pour premiere position

boucle_calcul_exposant:
    lsl     x24, x24, 4     // Multiplier par 16
    sub     x25, x25, 1     // exposant--
    cbnz    x25, boucle_calcul_exposant

ajout_accumulateur:
    uxth    x23, w23        // Etendre sur 64 bits
    mul     x24, x24, x23       // 16**pos * charActuelEnInt
    add     x22, x22, x24

    add     x21, x21, 1     // Increment exposant
    b       boucle_lecture_inverse

retour_hex_dec:
    adr     x0, fmtOutInt
    mov     x1, x22
    bl      printf

    RESTORE
    ret

//**************** Operation 3: Bin-vers-Dec ****************//
// Recoit x0: char* tabChar sous format ASCII (1byte/char) commence tjrs par 0b
// x19: copie de x0 tabChar
// x20: index pour iteration inverse de la chaine SANS '0b'
// x21: qte bits de poids faible SANS '0b'
// x22: accumulateur pour conversion decimal
// w23: char en position actuel (a l'inverse)
// x24: init pour exposant 2
// w25: bit de signe
// x26 copie position x21


operation3:
    SAVE

    // Initialisation et skip '0x'
    mov     x19, x0     // char* tabAscii
    mov     x20, 0      // int i = 0 pour indexage inverse
    mov     x21, 0      // int position bit poids faible = 0
    mov     x22, 0      // int acc = 0

    ldrb    w25, [x19, 2]!      // char bitSigne avec *(tabAscii + 2) pre-increm


// Boucle calcul de taille pour index et iteration inverse
boucle_taille_op3:
    ldrb    w23, [x19]
    cbz     w23, reset_index_string_bin        
    add     x20, x20, 1
    add     x19, x19, 1
    b       boucle_taille_op3

reset_index_string_bin:
    sub     x19, x19, x20


// Lecture a partir de la fin en fct de la taille
boucle_lecture_inverse_op3:
    cbz     x20, conversion_signe     // index == 0 donc fin de lecture inverse
    sub     x20, x20, 1     // --i
    ldrb    w23, [x19, x20]     // char valeurBit = tabAscii[i]

    // Complement ou non en fonction de bite de signe
    cmp     w25, 49     // bitSigne == 1 ?
    b.ne    conversion_chiffres_op3       // *(tablAscii + 2) != 1 donc entier non-signe
    
    // Faire le complement pour nb negatif
    cmp     w23, 49
    b.ne    avant_complement_zero
    mov     w23, 48     // if tabAscii[i] == 1 -> tabAscii[i] = 0
    b       conversion_chiffres_op3

avant_complement_zero:
    mov     w23, 49     // else tabAscii[i] = 1 (donc 0 avant)

conversion_chiffres_op3:
    sub     w23, w23, 48
    
// Somme (chiffre-pos * 2 ^ position) avec boucle
init_calcul_exposant_op3:
    mov     x24, 1 
    mov     x26, x21        // Copie pour calcul exposant
    cbz     x26, ajout_accumulateur_op3    // Skip pour premiere position

boucle_calcul_exposant_op3:
    lsl     x24, x24, 1     // Multiplier par 2
    sub     x26, x26, 1     // exposant--
    cbnz    x26, boucle_calcul_exposant_op3

ajout_accumulateur_op3:
    uxth    x23, w23        // Etendre sur 64 bits
    mul     x24, x23, x24       // 2^position * valeurBit
    add     x22, x22, x24

    add     x21, x21, 1     // Increment exposant
    b       boucle_lecture_inverse_op3

// Soustraire 1 et faire la negation de l'accumulateur
conversion_signe:
    cmp     w25, 49
    b.ne    retour_bin_dec_pos
    add     x22, x22, 1
    neg     x22, x22

    adr     x0, fmtOutSignedInt
    mov     x1, x22
    bl      printf
    b       fin_op3

retour_bin_dec_pos:
    adr     x0, fmtOutInt
    mov     x1, x22
    bl      printf

fin_op3:

    RESTORE
    ret
    
//**************** Operation 4: Chiffrement par decalage ****************//
// Recoit x0: char* tabChar sous format ASCII avec lettres MAJ et [, \, ou ]
// x19: copie de x0 tabChar
// x20: taille de la chaine pour iteration
// w21: char en position actuelle
// w22: char temp pour operations de decalage
// w23: char temp pour operations de decalage

operation4:
    SAVE

    // Initialisation
    mov     x19, x0     // char* tabAscii
    mov     x20, 0      // uint taille = 0

    // Boucle iteration debut vers fin
boucle_op4:
    ldrb    w21, [x19, x20]      // char currentChar = *tabAscii
    cbz     w21, retour_chiffrement

// Decalage circulaire 5 bits-pf vers la droite sur 32bits
// Simule decalage 2 vers la gauche et 3 vers la droite
ss_op4_ii:
    and     w22, w21, 0b00011111        // Sauvegarde 5 dernier bits pf
    lsl     w23, w22, 2                 // Decale 2 pos vers la gauche
    lsr     w22, w22, 3                 // Decale 3 pos vers la droite
    orr     w22, w22, w23               // On combine les 2 decalages
    bic     w21, w21, 0b00011111        // Efface 5 bits-pf sur original
    orr     w21, w21, w22               // Ajoute les 5 bits-pf decalés avec w22 comme masque
    b       increm_chiffrement

    // Decalage circulaire de 7 positions vers l'arriere
ss_op4_i:
    cmp     w21, 91
    b.ge    increm_chiffrement      // currentChar post-transfo (i) n'est pas une lettre

    mov     w22, 71     // limite de 'G' pour decalage circulaire
    cmp     w21, w22
    b.le    skip_circ

    // Decalage de 7 pos vers l'arriere
    sub     w21, w21, 7
    b       increm_chiffrement
skip_circ:
    add     w21, w21, 19

increm_chiffrement:
    strb    w21, [x19, x20]       // *tabAscii = currentChar
    add     x20, x20, 1     // taille++
    b       boucle_op4

retour_chiffrement:

    adr     x0, fmtOutMsg
    mov     x1, x19
    bl      printf

    RESTORE
    ret
    
//**************** Operation 5: Permutations ****************//
// Ne fonctionne pas, mais tente de s'inspirer d'une version python
//def permute(to_permute):
//    if len(to_permute) == 0:
//        return []
//    elif len(to_permute) == 1:
//        return [to_permute]    // liste de 1 string
//    else:
//        permutations = [] 
//        for i in range(len(to_permute)):
//            char_actuel = to_permute[i]
//            to_permute_raccourci = to_permute[:i] + s[i+1:]
//            for perm_raccourci in permute(to_permute_raccourci):
//                permutations.append(char_actuel + perm_raccourci)   // Ajout de char_actuel + perm_raccourci
//        return permutations

// Recoit x0: char* tabChar sous format ASCII sans repetitions
// x19: copie de x0 tabChar
operation5:
    SAVE

    // Initialisation
    mov     x19, x0     // char* tabAscii
    mov     x20, 0      // int taille
    mov     x21, 0      // int i
    mov     x22, 0      // int j
    mov     x27, 1      // int nb_perm = 1

// Boucle calcul de taille
boucle_taille_op5:
    ldrb    w23, [x19]
    cbz     w23, check_besoin_permutation        
    add     x20, x20, 1
    add     x19, x19, 1
    b       boucle_taille_op5

check_besoin_permutation:
    cmp     x20, 2     // taille < 2 donc pas de permutation
    b.lt    retour_sans_permutation

debut_permutation:
    SAVE
    cmp     x21, x20     // si i == taille
    b.ge    imprime_permutation
    mov     x22, x21     // j = i

boucle_permutation:
    cmp     x22, x20     // int j (de i jusqu'a taille-1)
    b.ge    fin_permutation

    // Echange de tabAscii[i] et tabAscii[j]
    ldrb    w25, [x19, x21]     // char temp = tabAscii[i]
    ldrb    w26, [x19, x22]     // char tabAscii[i] = tabAscii[j]
    strb    w26, [x19, x21]
    strb    w25, [x19, x22]     // char tabAscii[j] = temp

    add     x21, x21, 1     // i++
    bl      debut_permutation         // recursion avec i+1
    sub     x21, x21, 1     // i--

    // On refait l'echange tabAscii[i] and tabAscii[j] 
    ldrb    w25, [x19, x21]     // char temp = tabAscii[i]
    ldrb    w26, [x19, x22]     // char tabAscii[i] = tabAscii[j]
    strb    w26, [x19, x21]
    strb    w25, [x19, x22]     // char tabAscii[j] = temp

    add     x22, x22, 1     // j++
    b       boucle_permutation

fin_permutation:
    RESTORE
    b     fin_op5

imprime_permutation:
    mov     x28, x19    // copie de tabAscii pour impression
    mul     x27, x27, x20     // nb perm x taille pour pointeur
    strb    wzr, [x19, x27]   // Ajout de char null pour fin de string
    
    add     x28, x28, x27     // pointeur sur debut de prochaine permut
    add     x27, x27, 1       // increment nb_perm
    
    adr     x0, fmtOutMsg
    mov     x1, x28
    bl      printf
    
    ret

retour_sans_permutation:
    adr     x0, fmtOutMsg
    adr     x1, MsgError
    bl      printf

fin_op5:
    RESTORE
    ret

.section ".data"
// Mémoire allouée pour une chaîne de caractères d'au plus 1024 octets
chaine:     .skip   1024
numOp:      .skip   8    


.section ".rodata"
// Format pour lire une chaîne de caractères d'une ligne (incluant des espaces)
fmtLecture:             .asciz  "%[^\n]s"
// Formattage pour I/O uint
fmtInUint:              .asciz  "%u"
fmtOutInt:              .asciz  "%u\n"
fmtOutSignedInt:        .asciz  "%d\n"


// Message d'erreur operation
fmtOutMsg:              .asciz  "%s\n"
MsgError:               .asciz  "Erreur! Entrer un code d'operation entre 0 et 5."
