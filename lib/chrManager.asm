ChrManagerStart:

;****************************************************************
; ChrManager                                                    ;
; Responsible for chr loading                                   ;
;****************************************************************
  
;****************************************************************
; Name:                                                         ;
;   LoadChr                                                     ;
;                                                               ;
; Description:                                                  ;
;   Loads chr into PPU. Assumes PPU addr is set.                ;
;   Must be called with PPU off.                                ;
;   VRAM addressing must be set to 1.                           ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer points to start of data                      ;
;   1st byte = number of pages                                  ;
;   rest = data                                                 ;
;****************************************************************

LoadChr:
  
  ; load number of pages
  LDA [genericPointer], y
  TAX
  
  ; move the pointer
  LDA <genericPointer
  CLC
  ADC #$01
  STA <genericPointer
  LDA <genericPointer + $01
  ADC #$00
  STA <genericPointer + $01
  
  ; load the pages
  LDY #$00
  .copyLoop:
    LDA [genericPointer], y
    STA $2007
    INY
    BNE .copyLoop
    INC <genericPointer + $01
    DEX
    BNE .copyLoop    
    RTS

;****************************************************************
; Name:                                                         ;
;   LoadSprChr                                                  ;
;                                                               ;
; Description:                                                  ;
;   Loads sprite CHR. See comments in LoadChr                   ;
;****************************************************************

LoadSprChr:
  
  JSR WaitForFrame      
  BIT $2002
  LDA #$00
  STA $2006
  STA $2006     
  JMP LoadChr

;****************************************************************
; Name:                                                         ;
;   LoadBgChr                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads sprite CHR. See comments in LoadChr                   ;
;****************************************************************

LoadBgChr:
  
  JSR WaitForFrame    
  BIT $2002
  LDA #$10
  STA $2006
  LDA #$00
  STA $2006    
  JMP LoadChr
    
;****************************************************************
; EOF                                                           ;
;****************************************************************

ChrManagerEnd: