.include "macros_save_restore.s"
.global main

.section ".rodata"                     //
fmtNum:     .asciz  "%ld"              // const char* fmtNum    = "%ld";
fmtSortie:  .asciz  "%ld\n"            // const char* fmtSortie = "%ld\n";
                                       //
.section ".bss"                        //
            .align  8                  //
temp:       .skip   8                  // long temp;
nombres:    .skip   100*8              // long nombres[100];
                                       //
.section ".text"                       //
/*******************************************************************************
  Effet:  lit un tableau d'entiers de 64 bits,
          puis affiche un mode du tableau
  Usage:  x19 -- n    x20 -- x
*******************************************************************************/
main:                                   // int main()
        adr     x0, nombres             // {
        bl      lire_tab                //
        mov     x19, x0                 //   long n = lire_tab(nombres);
                                        //
        adr     x0, nombres             //
        mov     x1, x19                 //
        bl      mode                    //
        mov     x20, x0                 //   long x = mode(nombres, n);
                                        //
        adr     x0, fmtSortie           //
        mov     x1, x20                 //
        bl      printf                  //   printf(fmtSortie, x);
                                        //
        mov     w0, 0                   //
        bl      exit                    //   return 0;
                                        // }
                                        //
/*******************************************************************************
  Entrée: tableau d'entiers de 64 bits
  Effet:  lit une taille n, puis n entiers stockés dans le tableau
  Sortie: n
  Usage:  x19 -- tab    x20 -- n    x21 -- i
*******************************************************************************/
lire_tab:                               // long lire_tab(long tab[])
        SAVE                            // {
        mov     x19, x0                 //
                                        //
        adr     x0, fmtNum              //
        adr     x1, temp                //
        bl      scanf                   //   scanf(fmtNum, &temp);
        ldr     x20, temp               //   long n = temp;
        mov     x21, x20                //   long i = n;
                                        //
lire_tab_boucle:                        //
        cbz     x21, lire_tab_ret       //   while (i != 0)
        adr     x0, fmtNum              //   {
        mov     x1, x19                 //
        bl      scanf                   //     scanf(fmtNum, tab);
                                        //
        add     x19, x19, 8             //     tab++;
        sub     x21, x21, 1             //     i--;
        b       lire_tab_boucle         //   }
                                        //
lire_tab_ret:                           //
        mov     x0, x20                 //
        RESTORE                         //
        ret                             //   return n;
                                        // }
                                        //
/*******************************************************************************
  Entrée: tableau d'entiers de 64 bits, taille n du tableau, entier x
  Sortie: nombre d'occurrences de x dans le tableau
  Usage:  x19 -- num_x    x20 -- *tab
*******************************************************************************/
num_occ:                                // long num_occ(long tab[], long n, long x)
        SAVE                            // {
        mov     x19, x0                 //
        mov     x0, 0                   //   long num_x = 0;
                                        //
num_occ_boucle:                         //
        cbz     x1, num_occ_ret         //   while (n != 0)
        ldr     x20, [x19], 8           //   {
        cmp     x20, x2                 //
        b.ne    num_occ_prochain        //     if (*tab == x)
        add     x0, x0, 1               //       num_x++;
num_occ_prochain:                       //
        sub     x1, x1, 1               //     n--;
        b       num_occ_boucle          //   }
                                        //
num_occ_ret:                            //
        RESTORE                         //
        ret                             //   return num_x;
                                        // }
                                        //
/*******************************************************************************
  Entrée: tableau d'entiers de 64 bits (x0), taille n > 0 du tableau (x1)
  Sortie: un mode du tableau
  Usage:  x19 -- n    x20 --  tab     x21 -- *tab 
*******************************************************************************/
mode:                                   // long mode(long tab[], long n)
        SAVE                            // {
        mov     x19, x1                 //  
        mov     x25, x1                 //   // copie pour compteur n; 
        mov     x20, x0                 //   long *tab = tab;
        mov     x21, x0                 //   iterator i = tab.begin();
        mov     x22, 0                  //   long maxCount = 0;
        mov     x23, 0                  //   long mode = 0;
        
mode_boucle:
        cbz     x25, mode_ret            //   while (n != 0)
                                        //   {
        mov     x0, x20                 //     // x0 = tab
        mov     x1, x19                 //     // x1 = n
        ldr     x2, [x21]               //     long x = *tab[i]
        bl      num_occ                 //     
        mov     x24, x0                 //     long num_x = num_occ(tab, n, x);

        cmp     x24, x22                //     if (num_x > maxCount)
        b.le    mode_prochain           //     {
        mov     x22, x24                //       maxCount = num_x;
        mov     x23, x2                 //       mode = x;
                                        //     }
mode_prochain:
        sub     x25, x25, 1             //     n--;
        add     x21, x21, 8             //     i++;
        b       mode_boucle             //   }

mode_ret:
        mov     x0, x23                 //   return maxValue;
        RESTORE                         //
        ret                             // }                    
