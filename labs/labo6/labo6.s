.global  main                       // #include <math.h>  // sqrt
                                    // #include <stdio.h> // printf, scanf
                                    //
// Donnée statiques                 // double ecart_type(double tab[], unsigned long n);
.section ".bss"                     // double    moyenne(double tab[], unsigned long n);
            .align  8               //
temp:       .skip   8               // static unsigned long temp;
notes:      .skip   8000            // static double notes[1000];
                                    //
.section ".rodata"                  //
fmtTaille:  .asciz  "%lu"           // static const char* fmtTaille = "%lu";
fmtDonnee:  .asciz  "%lf"           // static const char* fmtDonnee = "%lf";
fmtSortie:  .asciz  "%lf\n"         // static const char* fmtSortie = "%lf\n";
                                    //
.section ".text"                    //
main:                               // int main()
    // Lire la quantité de notes    // {
    adr     x0, fmtTaille           //
    adr     x1, temp                //
    bl      scanf                   //   scanf(fmtTaille, &temp);
    ldr     x19, temp               //   unsigned long n = temp;
                                    //
    // Lire les notes               //
    mov     x20, 0                  //   unsigned long i = 0;
    adr     x21, notes              //
main_boucle:                        //
    cmp     x20, x19                //
    b.hs    main_fin_boucle         //   while (i < n)
                                    //   {
    adr     x0, fmtDonnee           //
    mov     x1, x21                 //
    bl      scanf                   //     scanf(fmtDonnee, &notes[i]);
                                    //
    add     x20, x20, 1             //     i++;
    add     x21, x21, 8             //
    b       main_boucle             //   }
main_fin_boucle:                    //
                                    //
    // Calculer l'écart-type        //
    adr     x0, notes               //
    mov     x1, x19                 //
    bl      ecart_type              //
    fmov    d8, d0                  //   double ecart = ecart_type(notes, n);
                                    //
    // Afficher l'écart-type        //
    adr     x0, fmtSortie           //
    fmov    d0, d8                  //
    bl      printf                  //   printf(fmtSortie, ecart);
                                    //
    mov     x0, 0                   //
    bl      exit                    //   return 0;
                                    // }

/*******************************************************************************
  Entrée: adresse d'un tableau de nombres en virgule flottante double précision
          nombre d'éléments du tableau
  Sortie: écart-type des éléments du tableau (en tant que population)
  Usage:  x0 - tab (copie dans x20)
          x1 - n (copie dans x19)
          x21 - i
          d8 - moyenne
          d9 - acc
          d10 - val 
*******************************************************************************/
ecart_type:
    // Preserve les registres de l'appelant
    stp     x29, x30, [sp, -80]!    
    mov     x29, sp                 
    stp     x19, x20, [sp, 16]      
    stp     x21, xzr,  [sp, 32]
    stp     d8, d9,   [sp, 48]      
    stp     d9, d10,  [sp, 64]      
    

    // Chercher notes et moyenne pour appel moyenne
    mov     x20, x0         // x20: notes[n]
    mov     x19, x1         // x19: n (len(notes)
    bl      moyenne
    fmov    d8, d0          // d8: moyenne

    // Calculer ecart type             
    mov     x21, 0          // compteur i                      
    fmov    d9, xzr         // accumulateur a 0        
et_boucle:                     
    cmp     x21, x19                 
    b.hs    mult_racine             
    
    // Chercher notes[i] ou *(notes + (x19 * sizeof(long)))                                    
    ldr     d10, [x20, x21, lsl 3]        
    // Operations sur la note et accumulation
    fsub    d10, d10, d8
    fmul    d10, d10, d10              
    fadd    d9, d9, d10
                                    
    add     x21, x21, 1             
    b       et_boucle
// Division par n et racine carre
mult_racine:
    ucvtf   d10, x19         // cast float(n)
    fdiv    d9, d9, d10      
    fsqrt   d0, d9

    // Restaurer les registres appelant
    ldp     x19, x20, [sp, 16]
    ldp     x21, xzr, [sp, 32]
    ldp     d8, d9, [sp, 48]
    ldp     d9, d10, [sp, 64]
    ldp     x29, x30, [sp], 80

    ret

/*******************************************************************************
  Entrée: adresse d'un tableau de nombres en virgule flottante double précision
          nombre d'éléments du tableau
  Sortie: moyenne des éléments du tableau
  Usage:  x0  - tab      d8  - acc
          x1  - n        d9  - val
          x19 - i        d10 - n (en double)
*******************************************************************************/
moyenne:                            // double moyenne(double tab[], unsigned long n)
    // Préserver registres appelant // {
    stp     x29, x30, [sp, -64]!    //
    mov     x29, sp                 //
    stp     x19, xzr, [sp, 16]      //   /* on empile xzr pour compléter le double mot en trop */
    stp     d8, d9,   [sp, 32]      //   /* on empile d9 deux fois simplement car on ne peut pas
    stp     d9, d10,  [sp, 48]      //       utiliser xzr pour remplir le dernier double mot   */
                                    //
    // Calculer moyenne             //
    mov     x19, 0                  //   unsigned long i = 0;
    fmov    d8, xzr                 //   double acc = 0.0;  /* xzr car 0.0 pas supporté */
moyenne_boucle:                     //
    cmp     x19, x1                 //
    b.hs    moyenne_ret             //   while (i < n)
                                    //   {
    ldr     d9, [x0, x19, lsl 3]    //     double val = tab[i];
    fadd    d8, d8, d9              //     acc += val;
                                    //
    add     x19, x19, 1             //     i++;
    b       moyenne_boucle          //   }
moyenne_ret:                        //
    ucvtf   d10, x1                 //
    fdiv    d0, d8, d10             //   double moy = acc / n;
                                    //
    // Restaurer registres appelant //
    ldp     x19, xzr, [sp, 16]      //
    ldp     d8, d9,   [sp, 32]      //
    ldp     d9, d10,  [sp, 48]      //
    ldp     x29, x30, [sp], 64      //
                                    //
    ret                             //   return moy;
                                    // }
