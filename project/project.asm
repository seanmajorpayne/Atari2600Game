    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include header files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables at memory addr $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg.u Variables
    org $80

P0XPos          byte
P0YPos          byte
EnemyXPos       byte
EnemyYPos       byte
P0Ptr           word
P0ColorPtr      word
BomberPtr       word
BomberColorPtr  word

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0_HEIGHT = 9   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Start code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg Code
    org $F000

Start:
    CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initialize BG, Field, & Player variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #10
    sta P0YPos

    lda #60
    sta P0XPos

    lda #83
    sta EnemyYPos

    lda #54
    sta EnemyXPos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Player sprite & color pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #<P0Bitmap
    sta P0Ptr

    lda #>P0Bitmap
    sta P0Ptr+1

    lda #<P0Color
    sta P0ColorPtr

    lda #>P0Color
    sta P0ColorPtr+1

    lda #<BomberBitmap
    sta BomberPtr

    lda #>BomberBitmap
    sta BomberPtr+1

    lda #<BomberColor
    sta BomberColorPtr

    lda #>BomberColor
    sta BomberColorPtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  VSync
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Frame:

    ldx #2
    stx VSYNC
    stx VBLANK

    ldx #3
VerticalSync:
    stx WSYNC
    dex
    bne VerticalSync

    ldx #0
    stx VSYNC

    ldx #37
VerticalBlank:
    stx WSYNC
    dex
    bne VerticalBlank

    ldx #0
    stx VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Scanline:
    lda #$84
    sta COLUBK
    lda #$C2
    sta COLUPF
    lda #%00000001
    sta CTRLPF
    lda #$F0
    sta PF0
    lda #$FC
    sta PF1
    lda #0
    sta PF2

    ldx #96
.GameLineLoop:
.InsideP0:
    txa
    sec
    sbc P0YPos
    cmp P0_HEIGHT
    bcc .DrawP0Sprite
    lda #0

.DrawP0Sprite
    tay
    lda (P0Ptr),Y
    sta WSYNC
    sta GRP0
    lda (P0ColorPtr),Y
    sta COLUP0

.InsideBomber:
    txa
    sec
    sbc EnemyYPos
    cmp P0_HEIGHT
    bcc .DrawP1Sprite
    lda #0

.DrawP1Sprite
    tay
    lda #%0000101
    sta NUSIZ1               ; stretch player1 sprite
    lda (BomberPtr),Y
    sta WSYNC
    sta GRP1
    lda (BomberColorPtr),Y
    sta COLUP1
    
    dex
    bne .GameLineLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #2
    stx VBLANK

    ldx #30
Overscan:
    stx WSYNC
    dex
    bne Overscan

    ldx #0
    stx VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Start new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    jmp Frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Graphics Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0Bitmap:
    .byte #%00000000    ;Clear byte
    .byte #%00010000    ;$0E
    .byte #%11111110    ;$0E
    .byte #%01111100    ;$0E
    .byte #%00111000    ;$82
    .byte #%00111000    ;$82
    .byte #%00010000    ;$0E
    .byte #%00010000    ;$0E
    .byte #%00010000    ;$40

P0TurnBitmap:
    .byte #%00000000    ;Clear byte
    .byte #%00010000    ;$0E
    .byte #%01111100    ;$0E
    .byte #%00111000    ;$0E
    .byte #%00111000    ;$82
    .byte #%00111000    ;$82
    .byte #%00010000    ;$0E
    .byte #%00010000    ;$0E
    .byte #%00010000    ;$40

BomberBitmap
    .byte #%00000000    ;Clear byte
    .byte #%01010100    ;$0E
    .byte #%01010100    ;$30
    .byte #%11111110    ;$30
    .byte #%11111110    ;$30
    .byte #%00111000    ;$30
    .byte #%00111000    ;$30
    .byte #%00010000    ;$30
    .byte #%00010000    ;$40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Color Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0Color:
    .byte #$00
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$82
    .byte #$82
    .byte #$0E
    .byte #$0E
    .byte #$40

BomberColor
    .byte #$00
    .byte #$0E
    .byte #$30
    .byte #$30
    .byte #$30
    .byte #$30
    .byte #$30
    .byte #$30
    .byte #$40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Finish ROM with 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC
    .word Start
    .word Start
