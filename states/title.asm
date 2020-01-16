StateTitleStart:

;****************************************************************
; State: title                                                  ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

TITLE_PALETTE_OFFSET = $07 * $10

;****************************************************************
; Name:                                                         ;
;   TitleFrame                                                  ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "title" state        ;
;****************************************************************

TitleFrame:

  .resetNmiFlags:
    LDA #$00
    STA <needDrawLocal
        
  .processFrame:
    ; ...
      
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw ; we only do draw in this state - no sprites or scrolling
  
  .frameDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadTitle                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads the "title" state                                     ;
;****************************************************************

LoadTitle:  

  ; todo : most of this will be common for all bank 0 states

  .disablePPUAndSleep:  
    JSR DisablePPU
    JSR ClearSprites
    INC <needDma
    JSR WaitForFrame
 
  .clearBackground:
    JSR ClearBackground
    
  .setVramAddressingTo1:
    JSR SetVramAddressingTo1
      
  .selectNameTable0AndSetScrollTo0:
    LDA <soft2000
    AND #%11111100 ; last 2 bits = nametable address
    STA <soft2000
    LDA #$00
    STA <scroll
    INC <needPpuReg
    JSR WaitForFrame ; this sets both
      
  .loadBgChr:   
    LDA #LOW(titleChr)
    STA <genericPointer
    LDA #HIGH(titleChr)
    STA <genericPointer + $01
    JSR LoadBgChr                        
  
  .loadPalette:
    LDA #TITLE_PALETTE_OFFSET
    STA <paletteOffset
    JSR LoadBgPalette    
    INC <needDraw
    
  .setAllAtts:
    LDA #$01 ; 2nd palette = text
    STA <renderAtts
    LDA #$08 ; 8 atts rows = entire screen
    STA <genericHeight
    JSR SetAttributes
    
  .drawLogo:
    JSR DrawLogo
 
  .enablePPU:                                    
    JSR EnablePPU
    
  ; todo: fade in?

  ; todo 0006 - is this the right place to call this
  .initializeSound:
    JSR InitializeSound
    JSR PlaySong
  
  JMP WaitForFrame 
  
;****************************************************************
; Name:                                                         ;
;   DrawLogo                                                    ;
;                                                               ;
; Description:                                                  ;
;   Draws the logo                                              ;
;****************************************************************

DrawLogo:

  ; generic pointer will keep track of the starting address
  LDA #INITIAL_LOGO_ADDR_L
  STA <genericPointer
  LDA #INITIAL_LOGO_ADDR_H
  STA <genericPointer + $01
  
  ; X will be the pointer in the table
  LDX #$00
  
  ; b will count characters in a row
  LDA #LOGO_ROW_LENGTH
  STA <b
  
  ; Y will count rows
  LDY #LOGO_ROWS 
  
  .drawingLoopOuter:
  
    .setAddress:
      LDA $2002
      LDA <genericPointer + $01
      STA $2006
      LDA <genericPointer
      STA $2006
      
    .drawingLoopInner:
      LDA Logo, x
      STA $2007
      INX
      DEC b
      BNE .drawingLoopInner
      
    .moveRow:
      DEY
      BEQ .drawingDone
      LDA <genericPointer
      CLC
      ADC #$20
      STA <genericPointer
      LDA <genericPointer + $01
      ADC #$00
      STA <genericPointer + $01
      LDA #LOGO_ROW_LENGTH
      STA <b
      JMP .drawingLoopOuter
      
  .drawingDone:

  .setLogoAtts:
    LDA #$00 ; 1st palette = logo
    STA <renderAtts
    LDA #$03 ; set atts for the top 3 rows to cover the logo
    STA <genericHeight
    JSR SetAttributes
  
    RTS

  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateTitleEnd: