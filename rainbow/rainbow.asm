    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

Start:
    CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NextFrame:
    lda #2          ; same as binary value %00000010
    sta VBLANK      ; turn on VBLANK
    sta VSYNC       ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    sta WSYNC       ; first scanline
    sta WSYNC       ; second
    sta WSYNC       ; third

    lda #0
    sta VSYNC       ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let the TIA output the 37 VBLANK scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #37
LoopVBlank:
    sta WSYNC
    dex
    bne LoopVBlank

    lda #0
    sta VBLANK      ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Render visible scanlines (192)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #192
LoopVisible:
    stx COLUBK
    sta WSYNC
    dex
    bne LoopVisible

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let the TIA output the 30 lines of overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #2
    sta VBLANK

    ldx #30
LoopOverscan:
    sta WSYNC
    dex
    bne LoopOverscan

    lda #0
    sta VBLANK

    jmp NextFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Complete ROM size to 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC
    .word Start
    .word Start
