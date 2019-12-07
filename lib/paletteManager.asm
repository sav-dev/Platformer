PaletteManagerStart:

;****************************************************************
; PaletteManager                                                ;                           
; Responsible for loading palettes                              ;
;                                                               ;
; Background palette starts at $3F00 in PPU                     ;
; Sprite palette starts at $3F10 at PPU                         ;
;                                                               ;
;****************************************************************

pal_spr:
  .incbin "PlatformerGraphics\palettes\spr.bin"

pal_bg:
  .incbin "PlatformerGraphics\palettes\bg.bin"
  
;****************************************************************
; Name:                                                         ;
;   LoadSpritesPalette                                          ;
;                                                               ;
; Description:                                                  ;
;   Buffers the sprites to be drawn in NMI                      ;
;                                                               ;
; Variables used:                                               ;
;   X                                                           ;
;   b                                                           ;
;   c                                                           ;
;   genericPointer                                              ;
;****************************************************************

LoadSpritesPalette:
  LDA #$3F                 ; sprite palette starts at $3F10 (in PPU)
  STA b                    ; store the high target byte in b
  LDA #$10                 
  STA c                    ; store the low target byte in c
  LDA #LOW(pal_spr)
  STA genericPointer
  LDA #HIGH(pal_spr)
  STA genericPointer + $01
  JSR LoadPalette          ; load the palette
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadBgPalette                                               ;
;                                                               ;
; Description:                                                  ;
;   Buffers the bg. palette to be drawn in NMI                  ;
;                                                               ;
; Input parameters:                                             ;
;   paletteOffset                                               ;
;                                                               ;
; Variables used:                                               ;
;   X                                                           ;
;   b                                                           ;
;   c                                                           ;
;   genericPointer                                              ;
;****************************************************************

LoadBgPalette:
  LDA #$3F                 ; bg palette starts at $3F00 (in PPU)
  STA b                    ; store the high target byte in b
  LDA #$00                 
  STA c                    ; store the low target byte in c
  LDA #LOW(pal_bg)
  STA genericPointer
  LDA #HIGH(pal_bg)
  STA genericPointer + $01
  LDA genericPointer
  CLC
  ADC paletteOffset
  STA genericPointer
  LDA genericPointer + $01
  ADC #$00
  STA genericPointer + $01
  JSR LoadPalette          ; load the palette
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadPalette                                                 ;
;                                                               ;
; Description:                                                  ; 
;   Buffers a palette to be drawn in NMI                        ;
;   Palette pointer must be set                                 ;
;   POITAG - possible optimization - update this to use a       ;
;   "copy from ROM" flag if this is to be called frequently     ;
;                                                               ;
; Input parameters:                                             ;
;   X                                                           ;
;   b: high byte of the target address                          ;
;   c: low byte of the target address                           ;
;   genericPointer: pointer to the palette                      ;
;****************************************************************

LoadPalette:

  LDX bufferOffset            ; load buffer offset to the X register
  LDA #$10                    ; load $10 = 16 to the A register (we're drawing a palette == 16 bytes)
  STA drawBuffer, x           ; set that to byte 0 of the buffer segment
                              
  INX                         ; increment the X register (now X == 1)
  LDA b                       ; load the high byte of the target address
  STA drawBuffer, x           ; set that to byte 1 of the buffer segment
                              
  INX                         ; increment the X register (now X == 2)
  LDA c                       ; load the low byte of the target address
  STA drawBuffer, x           ; set that to byte 2 of the buffer segment   
                              
  INX                         ; increment the X register (now X == 3)
                                
  LDY #$00                    ; start out at 0                             
  .bufferedDrawLoop:          
    LDA [genericPointer], y   ; load a byte of the palette data  
    INX                       ; increment the X register
    STA drawBuffer, x         ; write to the buffer    
    INY                       ; Y = Y + 1
    CPY #$10                  ; compare Y to hex $10, decimal 16 - copying 16 bytes
    BNE .bufferedDrawLoop     ; loop if there's more data to be copied
                              
  INX                         ; increment the X register so it points to the next free byte in the buffer
  STX bufferOffset            ; update the buffer offset
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ClearPalettes                                               ;
;                                                               ;
; Description:                                                  ; 
;   Clears both palettes. Cannot be called with NMI enabled.    ; 
;                                                               ;
; Variables used:                                               ;
;   X                                                           ;
;****************************************************************

ClearPalettes:

  LDA $2002                  ; read PPU status to reset the high/low latch
  LDA #$3F                   ; palettes start at $3F00 (in PPU)
  STA $2006  
  LDA #$00
  STA $2006  
 
  LDX #$00
  LDA #$0F                   ; $0F = black
  
  .loop:
    STA $2007
    INX      
    CPX #$20                 ; copy $20 = 32 = 2x 16 bytes (both palettes)           
    BNE .loop
    
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

PaletteManagerEnd: