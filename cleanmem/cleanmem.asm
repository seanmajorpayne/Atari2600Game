    processor 6502

    seg code
    org $F000       ; Define the code origin at $F000 (Start of ROM code)

Start:
    sei             ; Disable Interrupts
    cld             ; Disable the BCD Decimal math mode
    ldx #$FF        ; Loads the X Register with #$FF (Last RAM Position)
    txs             ; Transfer X register to (S)tack Pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; All Ram Space & TIA Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #0          
    ldx #$FF        

MemLoop:
    sta $0,X        ; Store value of A inside memory address $0 + X
    dex
    bne MemLoop

    sta $0, X       ; Making sure the $00 address is also cleared

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4kb
; All Ram Space & TIA Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (Unused in the VCS)