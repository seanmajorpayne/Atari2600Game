    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80
P0Height byte
Player0XPos byte
Player0YPos byte

    seg Code
    org $F000

Reset:
    CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize Player & World Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #$00
    sta COLUBK

    lda #180
    sta Player0YPos

    lda #9
    sta P0Height

    lda #40
    sta Player0XPos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VSYNC & VBLANK Initialize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Frame:
    lda #2
    sta VSYNC
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #3
Sync:
    sta WSYNC
    dex
    bne Sync

    lda #0
    sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set Player Horizontal Position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda Player0XPos
    and #$7F            ; Position must be positive

    sta WSYNC
    sta HMCLR

    sec
DivideLoop:             ; Get remainder - 3 for fine position
    sbc #15
    bcs DivideLoop

    eor #7
    asl
    asl
    asl
    asl
    sta HMP0            ; set fine position
    sta RESP0           ; reset 15-step brute position
    sta WSYNC           ; wait for scanline
    sta HMOVE           ; apply find position offset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VBlank (37 - the 2 applied above)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #35
VerticalBlank:
    sta WSYNC
    dex
    bne VerticalBlank

    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Render visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #192
Scanline:
    txa
    sec
    sbc Player0YPos
    cmp P0Height
    bcc RenderBitmap
    lda #0

RenderBitmap:
    tay
    lda P0Bitmap,Y
    sta GRP0
    lda P0Color,Y
    sta COLUP0
    sta WSYNC
    dex
    bne Scanline

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #2
    sta VBLANK

    ldx #30
Overscan:
    sta WSYNC
    dex
    bne Overscan

    lda #0
    sta VBLANK

    dec Player0YPos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constrain horizontal position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda Player0XPos
    cmp #80
    bpl ResetXPos
    jmp IncrXPos

ResetXPos:
    ldx #40
    stx Player0XPos

IncrXPos:
    inc Player0XPos

    jmp Frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bitmaps & Colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0Bitmap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000

P0Color:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Finish player ROM to 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    word Reset
    word Reset

