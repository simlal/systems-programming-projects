.include "macros.s"
.global  main

main:                           // main()
    // Lire mots w0 et w1       // {
    //             à déchiffrer //
    adr     x0, fmtEntree       //
    adr     x1, temp            //
    bl      scanf               //   scanf("%X", &temp)
    ldr     w19, temp           //   w0 = temp
                                //
    adr     x0, fmtEntree       //
    adr     x1, temp            //
    bl      scanf               //   scanf("%X", &temp)
    ldr     w20, temp           //   w1 = temp
                                //
    // Déchiffrer w0 et w1      //
    mov     w0, w19             //
    mov     w1, w20             //
    ldr     w2, k0              //
    ldr     w3, k1              //
    ldr     w4, k2              //
    ldr     w5, k3              //
    bl      dechiffrer          //   w0, w1 = dechiffrer(w0, w1, w2, w3, w4, w5)
                                //
    // Afficher message secret  //
    mov     w19, w0             //
    mov     w20, w1             //
                                //
    adr     x0, fmtSortie       //
    mov     w1, w19             //
    mov     w2, w20             //
    bl      printf              //   printf("%c %c\n", w0, w1)
                                //
    // Quitter programme        //
    mov     x0, 0               //
    bl      exit                //   return 0
                                // }
/*******************************************************************************
  Procédure de déchiffrement de l'algorithme TEA
  Entrées: - mots w0 et w1 à déchiffrer (32 bits chacun)
           - clés w2, w3, w4 et w5      (32 bits chacune)
  Sortie: mots w0 et w1 déchiffrés
*******************************************************************************/
dechiffrer:
    // Sauvegarde des regs du main et chargement dans reg temps
    SAVE

    mov     w19, w0
    mov     w20, w1
    mov     w21, w2
    mov     w22, w3
    mov     w23, w4
    mov     w24, w5
    ldr     w25, delta                // la constante magique     
    mov     x26, 0                    // compteur i

boucle:
    cmp     x26, 32
    b.ge    fin_boucle
    adr     x0, fmtPrintInt
    mov     x1, x26
    bl      printf

    add     x26, x26, 1
    b       boucle 


fin_boucle:
    mov     w0, w19
    mov     w1, w20
    mov     w2, w21
    mov     w3, w22
    mov     w4, w23
    mov     w5, w24

    RESTORE
    ret






.section ".rodata"
k0:           .word   0xABCDEF01
k1:           .word   0x11111111
k2:           .word   0x12345678
k3:           .word   0x90000000
delta:        .word   0x9E3779B9

fmtEntree:    .asciz  "%X"
fmtSortie:    .asciz  "%c %c\n"
fmtPrintInt:  .asciz  "%u\n"

.section ".data"
            .align  4
temp:       .skip   4
