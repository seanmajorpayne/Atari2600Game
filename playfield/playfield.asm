    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

Start:
    CLEAN_START

    ldx #$70        ; Blue Background
    stx COLUBK

    lda #$1E        ; Yellow Playfield
    sta COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NextFrame:
    lda #2
    sta VSYNC
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 3
        sta WSYNC
    REPEND

    lda #0
    sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let TIA output 37 lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set CTRLPF register for playfield reflection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #%00000001
    stx CTRLPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Output Playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #0
    sta PF0
    sta PF1
    sta PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    ldx #%11111111
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    ldx #%01100000
    stx PF0
    ldx #%00000000
    stx PF1
    ldx #%10000000
    stx PF2

    REPEAT 164
        sta WSYNC
    REPEND

    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    ldx #%11111111
    stx PF2

    REPEAT 7
        sta WSYNC
    REPEND

    lda #0
    sta PF0
    sta PF1
    sta PF2

    REPEAT 7
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let the TIA output the 30 lines of overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #2
    sta VBLANK

    ldx #30
LoopOverscan:
    sta WSYNC
    dex
    bne LoopOverscan

    ldx #0
    sta VBLANK

    jmp NextFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Complete ROM size to 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC
    .word Start
    .word Start






