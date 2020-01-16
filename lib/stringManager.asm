StringManagerStart:

;****************************************************************
; StringManager                                                 ;
; Responsible for drawing strings                               ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   DrawString                                                  ;
;                                                               ;
; Description:                                                  ;
;   Draws a string                                              ;
;                                                               ;
; Input variables:                                              ;
;   genericX/Y = position                                       ;
;   genericPointer (low) = string id                            ;
;****************************************************************

DrawString:
  
  JSR SetStringCommon
  
  .setDataLoop:
    LDA [genericPointer], y
    STA drawBuffer, x
    INX
    INY
    DEC <b
    BNE .setDataLoop 
  
  .updateBufferOffset:
    STX <bufferOffset
  
  RTS

;****************************************************************
; Name:                                                         ;
;   ClearString                                                 ;
;                                                               ;
; Description:                                                  ;
;   Clears a string                                             ;
;                                                               ;
; Input variables:                                              ;
;   genericX/Y = position                                       ;
;   genericPointer (low) = string id                            ;
;****************************************************************

ClearString:

  JSR SetStringCommon
  
  .setDataLoop:
    LDA #CLEAR_TILE
    STA drawBuffer, x
    INX
    INY
    DEC <b
    BNE .setDataLoop 
  
  .updateBufferOffset:
    STX <bufferOffset
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SetStringCommon                                             ;
;                                                               ;
; Description:                                                  ;
;   Common functionality for setting strings.                   ;
;   Sets the draw length and address.                           ;
;   On output:                                                  ;
;     x = bufferOffset                                          ;
;     [genericPointer], y points to the 1st byte of the string  ;
;                                                               ;
; Input variables:                                              ;
;   genericX/Y = position                                       ;
;   genericPointer (low) = string id                            ;
;****************************************************************  
SetStringCommon:

  .needDraw:
    INC <needDrawLocal

  .setStringPointerAndLoadOffset:
    LDX <genericPointer
    LDA StringPointers, x
    STA <genericPointer
    INX
    LDA StringPointers, x
    STA <genericPointer + $01
    LDY #$00
    LDX <bufferOffset
    
  .loadLength:
    LDA [genericPointer], y 
    STA drawBuffer, x
    STA <b ; cache length in b
    INY
    INX
    
  .calculateAddress:
    JSR CalculatePpuAddress
        
  .setAddress:
    LDA <d
    STA drawBuffer, x
    INX
    LDA <c
    STA drawBuffer, x
    INX
    
  .skipReservedByte:
    INX
  
  RTS

;****************************************************************
; Name:                                                         ;
;   CalculatePpuAddress                                         ;
;                                                               ;
; Description:                                                  ;
;   Based on genericX/Y sets the PPU address in [c,d]           ;
;****************************************************************  
  
CalculatePpuAddress:

  LDA <genericX
  STA <c ; low byte
  LDA #$20
  STA <d ; high byte
  
  .moveAddressLoop:
    LDA <genericY
    BEQ .done
    LDA <c
    CLC
    ADC #$20
    STA <c
    LDA <d
    ADC #$00
    STA <d
    DEC <genericY
    JMP .moveAddressLoop
    
  .done:
    RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StringManagerEnd: