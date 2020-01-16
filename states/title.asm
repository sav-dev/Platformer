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
      
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw
  
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

  .disablePPUAndSleep:  
    JSR DisablePPU
    JSR ClearSprites
    INC <needDma
    JSR WaitForFrame              ; wait for values to be written
 
  .clearBackground:
    JSR ClearBackground
    
  .setVramAddressingTo1:
    JSR SetVramAddressingTo1      ; this never changes for this state
      
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

  

  RTS

  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateTitleEnd: