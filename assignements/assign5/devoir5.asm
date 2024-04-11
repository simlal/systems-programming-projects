;; Macros pour l'émulateur ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .inesprg 1
    .ineschr 1
    .inesmir 0
    .inesmap 0

;; Variables (allouées dans la mémoire principale à partir de 0x0000) ;;;;;;;;;;
    .rsset  $0000
posX:           .rs 1               ; Position horizontale de Mario (1 octet)
posY:           .rs 1               ; Position verticale de Mario
attrsTuile      .rs 1               ; Attributs de tuile
offsetXTuileG   .rs 1               ; Offset en X lors de reflex-horiz tuile G
offsetXTuileD   .rs 1               ; Offset en X lors de reflex-horiz tuile D
boutonG         .rs 1               ; Etat du bouton fleche gauche
boutonD         .rs 1               ; Etat du bouton fleche droite
boutonB         .rs 1               ; Etat du bouton B

;; Segment de code du jeu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank   0                   ;
    .org    $C000               ; Adresse du segment de code du jeu
                                ;
; Point d'entrée (appelé lors d'une interruption RESET)
main:                           ; main() {
    sei                         ;   Désactiver les interruptions IRQ
    cld                         ;   Désactiver le mode décimal (non supporté)
    lda     #%00000000          ;   Désactiver temporairement les interruptions
    sta     $2000               ;
                                ;
    ldx     #$FF                ;
    txs                         ;   Initialiser la pile d'exécution: s = 0xFF
                                ;
    jsr     init_variables      ;   Initialiser les variables
    jsr     init_palette        ;   Initialiser les palettes de couleur
    jsr     init_arriere        ;   Initialiser l'arrière-plan
                                ;
    lda     #%10010000          ;
    sta     $2000               ;   Réactiver les interruptions
    lda     #%00011000          ;
    sta     $2001               ;   Activer les tuiles et l'arrière-plan
                                ;
boucle:                         ;   Boucle infinie
    jmp     boucle              ; }

; Sous-routine de mise à jour: appelée par interruption à chaque
; rafraîchissement vertical de l'affichage
update:
    ; À FAIRE: copier les tuiles de Mario vers le processeur d'images

    jsr     lire_manette
    jsr     deplacer_mario
    jsr     update_mario

    rti

init_variables:
    ; posX = pos de mario en x au centre
    lda     #119
    sta     posX

    ; posY = pos de mario en y sur le sol
    lda     #157
    sta     posY

    ; boutonG = bouton gauche a 0
    lda     %0
    sta     boutonG
    ; boutonD = bouton droit a 0
    lda     %0
    sta     boutonD
    ; boutonA = bouton B a 0
    lda     %0
    sta     boutonB

    ; Attributs de tuile a sans reflexion, en avant plan et palette0
    lda     #%00000000
    sta     attrsTuile

    ; Initialise les offsetX pour aucune reflex
    lda     #0
    sta     offsetXTuileG
    lda     #8
    sta     offsetXTuileD

    rts

lire_manette:
    ; Demander une lecture des boutons de la manette
    lda     #1 
    sta     $4016 
    lda     #0
    sta     $4016

    ; Lire et stocker l'état des boutons
    ; Lire A et B
    lda     $4016       ; A
    lda     $4016       ; B
    and     #%00000001
    sta     boutonB

    ; Controles a skip
    lda     $4016       ; SELECT
    lda     $4016       ; START
    lda     $4016       ; UP
    lda     $4016       ; DOWN
    
    ; Lire Gauche et droite
    lda     $4016       ; GAUCHE
    and     #%00000001
    sta     boutonG

    lda     $4016       ; DROITE
    and     #%00000001
    sta     boutonD

    rts

deplacer_mario:
    ; Déplacer Mario si la flèche gauche ou droite a été appuyée
    lda     boutonG
    cmp     #1
    beq     deplacement_gauche

    lda     boutonD
    cmp     #1
    beq     deplacement_droite
    
    jmp     fin_deplacement     ; Aucune actions
    
deplacement_gauche:
    dec     posX        ; Deplacement de la tuile
    
    ; Reflection horiz
    lda     #%01000000
    sta     attrsTuile
    
    ; Positions relatives en X entre tuiles avec reflexion (inverse ordre)
    lda     #8
    sta     offsetXTuileG
    lda     #0
    sta     offsetXTuileD

    jmp     fin_deplacement

deplacement_droite:
    inc     posX

    ; Remise normale de la tuile
    lda     #%00000000
    sta     attrsTuile      ; Aucune reflexion

    ; Positions relatives en X entre tuiles (!= reflexion)
    lda     #0
    sta     offsetXTuileG
    lda     #8
    sta     offsetXTuileD
    jmp     fin_deplacement


fin_deplacement:
    rts

update_mario:
    ; Tuile 1 (bas x 0, droite x 0)
    lda     posY
    sta     $0200

    lda     #1
    sta     $0201

    lda     attrsTuile
    sta     $0202

    lda     posX
    clc
    adc     offsetXTuileG
    sta     $0203

    ; Tuile 2 (bas x 0, droite x 0)
    lda     posY
    sta     $0204

    lda     #2
    sta     $0205

    lda     attrsTuile
    sta     $0206

    lda     posX
    clc
    adc     offsetXTuileD
    sta     $0207

    ; Tuile 3 (bas x 1, droite x 0)
    lda     posY
    clc
    adc     #8
    sta     $0208

    lda     #3
    sta     $0209

    lda     attrsTuile
    sta     $020A
    
    lda     posX
    clc
    adc     offsetXTuileG
    sta     $020B

    ; Tuile 4 (bas x 1, droite x 1)
    lda     posY
    clc
    adc     #8
    sta     $020C

    lda     #4
    sta     $020D

    lda     attrsTuile
    sta     $020E
    
    lda     posX
    clc
    adc     offsetXTuileD
    sta     $020F

    ; Tuile 5 (bas x 2, droite x 0)
    lda     posY
    clc
    adc     #16
    sta     $0210

    lda     #5
    sta     $0211

    lda     attrsTuile
    sta     $0212

    lda     posX
    clc
    adc     offsetXTuileG
    sta     $0213

    ; Tuile 6 (bas x 2, droite x 1)
    lda     posY
    clc
    adc     #16
    sta     $0214

    lda     #6
    sta     $0215

    lda     attrsTuile
    sta     $0216

    lda     posX
    clc
    adc     offsetXTuileD
    sta     $0217

    ; Tuile 7 (bas x 3, droite x 0)
    lda     posY
    clc
    adc     #24
    sta     $0218

    lda     #7
    sta     $0219

    lda     attrsTuile
    sta     $021A

    lda     posX
    clc
    adc     offsetXTuileG
    sta     $021B

    ; Tuile 8 (bas x 3, droite x 1)
    lda     posY
    clc
    adc     #24
    sta     $021C

    lda     #8
    sta     $021D

    lda     attrsTuile
    sta     $021E

    lda     posX
    clc
    adc     offsetXTuileD
    sta     $021F

    lda     #$02
    sta     $4014

    rts

; Sous-routine qui initialise les palettes de couleurs
init_palette:                   ; init_palette()
    lda     #$3F                ; {
    sta     $2006               ;
    lda     #$00                ;
    sta     $2006               ;   i = 0x3F00 (palettes de couleur)
    ldx     #0                  ;   x = 0
                                ;
init_palette_boucle:            ;   do {
    lda     palettes, x         ;
    sta     $2007               ;     mem_video[i] = palettes[x]
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #32                 ;   }
    bne     init_palette_boucle ;   while (x < 32)
                                ;
    rts                         ; }
                                ;
                                ;
; Sous-routine qui initialise l'arrière-plan dans mem_video[0x2000, 0x23FF]
init_arriere:                   ; init_arriere()
    ; Init. tuiles              ; {
    lda     #$20                ;
    sta     $2006               ;
    lda     #$00                ;
    sta     $2006               ;   i = 0x2000 (arrière-plan)
                                ;
    ldx     #0                  ;   x = 0
                                ;
init_arriere_tuile0:            ;   do {
    lda     arriere0, x         ;
    sta     $2007               ;     mem_video[i] = arriere_sprites0[x]
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #0                  ;   }
    bne     init_arriere_tuile0 ;   while (x < 256)
                                ;
    ldx     #0                  ;   x = 0
                                ;
init_arriere_tuile1:            ;   do {
    lda     arriere1, x         ;
    sta     $2007               ;     mem_video[i] = arriere_sprites1[x]
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #0                  ;   }
    bne     init_arriere_tuile1 ;   while (x < 256)
                                ;
init_arriere_tuile2:            ;   do {
    lda     arriere2, x         ;
    sta     $2007               ;     mem_video[i] = arriere_sprites2[x]
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #0                  ;   }
    bne     init_arriere_tuile2 ;   while (x < 256)
                                ;
init_arriere_tuile3:            ;   do {
    lda     arriere3, x         ;
    sta     $2007               ;     mem_video[i] = arriere_sprites3[x]
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #192                ;   }
    bne     init_arriere_tuile3 ;   while (x < 192)
                                ;
    ; Init. attributs           ;
    ldx     #0                  ;   x = 0
                                ;
init_arriere_attr02:            ;   do {
    lda     #%00000000          ;
    sta     $2007               ;     mem_video[i] = 0b00000000 (tous palette 00)
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #48                 ;   }
    bne     init_arriere_attr02 ;   while (x < 3*16)
                                ;
    ldx     #0                  ;   x = 0
                                ;
init_arriere_attr3:             ;   do {
    lda     #%01010101          ;
    sta     $2007               ;     mem_video[i] = 0b01010101 (tous palette 01)
                                ;     i++           ; auto-incrémenté par le PPU
    inx                         ;     x++
    cpx     #16                 ;   }
    bne     init_arriere_attr3  ;   while (x < 16)
                                ;
    rts                         ; }

;; Segment de données statiques ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Palettes de couleur
palettes:                       ;
    .byte   $21, $20, $1A, $0E  ; Palette 0 de couleur de l'arrière-plan
    .byte   $21, $20, $16, $0E  ; Palette 1 de couleur de l'arrière-plan
    .byte   $21, $0E, $0E, $0E  ; Inutilisée
    .byte   $21, $0E, $0E, $0E  ; Inutilisée

    .byte   $21, $16, $27, $18  ; Palette 0 de couleur des tuiles
    .byte   $21, $0E, $0E, $0E  ; Inutilisée
    .byte   $21, $0E, $0E, $0E  ; Inutilisée
    .byte   $21, $0E, $0E, $0E  ; Inutilisée
            ; ^--- doivent tous être égaux (couleur d'arrière-plan)

; Tuiles d'arrière-plan (256 pixels x 240 pixels)
arriere0: ; Tuiles du haut du ciel (8 x 32 tuiles de 8 pixels)
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$13,$10,$1E,$03,$01,$0A,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

arriere1: ; Tuiles du bas du ciel (8 x 32 tuiles de 8 pixels)
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

arriere2: ; Tuiles des montagnes (8 x 32 tuiles de 8 pixels)
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$25,$32,$33,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$25,$32,$33,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$25,$31,$35,$27,$34,$25,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$25,$31,$35,$27,$34,$25,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$25,$31,$27,$27,$27,$27,$34,$25,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$25,$31,$27,$27,$27,$27,$34,$25,$25,$25,$25,$25,$25,$25,$25

    .byte $25,$31,$27,$35,$27,$27,$35,$27,$34,$25,$25,$25,$25,$25,$25,$25
    .byte $25,$31,$27,$35,$27,$27,$35,$27,$34,$25,$25,$25,$25,$25,$25,$25

    .byte $31,$27,$27,$27,$27,$27,$27,$27,$27,$34,$25,$25,$25,$25,$25,$25
    .byte $31,$27,$27,$27,$27,$27,$27,$27,$27,$34,$25,$25,$25,$25,$25,$25

arriere3: ; Tuiles du sol (6 x 32 tuiles de 8 pixels)
    .byte $B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6
    .byte $B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6

    .byte $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8
    .byte $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8

    .byte $B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6
    .byte $B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6

    .byte $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8
    .byte $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8

    .byte $B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6
    .byte $B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6,$B5,$B6

    .byte $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8
    .byte $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8

;; Table d'interruptions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank    1
    .org     $FFFA              ; Adresse du vecteur d'interruptions
    .word    update             ; Appelé lors d'une interruption NMI (VBLANK)
    .word    main               ; Appelé lors d'une interruption RESET
    .word    0                  ; Appelé lors d'une interruption IRQ (désactivé)

;; Segment des tuiles ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank    2
    .org     $0000
    .incbin  "tuiles.chr"
