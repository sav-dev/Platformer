StateStageSelectStart:

;****************************************************************
; State: stage select                                           ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

STAGE_X = $0C
STAGE_Y = $0C

STAGE_DIGIT_X = STAGE_X + $05 + $03
STAGE_DIGIT_Y = STAGE_Y

STAGE_DIGIT_CURSOR_X = STAGE_DIGIT_X - $01
STAGE_DIGIT_CURSOR_Y = STAGE_DIGIT_Y

LEVEL_X = STAGE_X
LEVEL_Y = STAGE_Y + $02

LEVEL_DIGIT_X = STAGE_DIGIT_X
LEVEL_DIGIT_Y = LEVEL_Y

LEVEL_DIGIT_CURSOR_X = LEVEL_DIGIT_X - $01
LEVEL_DIGIT_CURSOR_Y = LEVEL_DIGIT_Y

;****************************************************************
; Name:                                                         ;
;   StageSelectFrame                                            ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "stage select" state ;
;****************************************************************

StageSelectFrame:

  .resetNmiFlags:
    LDA #$00
    STA <needDrawLocal
        
  .processFrame:
    LDA <controllerPressed
    AND #CONTROLLER_START
    BNE .loadLevel
    LDA <controllerPressed
    AND #CONTROLLER_SEL
    BNE .moveCursor
    LDA <controllerPressed
    AND #CONTROLLER_DOWN
    BNE .moveCursor
    LDA <controllerPressed
    AND #CONTROLLER_UP
    BNE .moveCursor
    LDA <controllerPressed
    AND #CONTROLLER_LEFT
    BNE .changeDigitLeft
    LDA <controllerPressed
    AND #CONTROLLER_RIGHT
    BNE .changeDigitRight
    JMP .setNmiFlags
    
  .changeDigitRight:
    JSR SfxOptionChanged
    ; todo
    INC <LOW(levelPointer)
    INC <HIGH(levelPointer)
    JSR DrawDigits
    INC <needDrawLocal
    JMP .setNmiFlags

  .changeDigitLeft:
    JSR SfxOptionChanged
    ; todo
    DEC <LOW(levelPointer)
    DEC <HIGH(levelPointer)
    JSR DrawDigits
    INC <needDrawLocal
    JMP .setNmiFlags
  
  .moveCursor:
    JSR SfxOptionChanged
    LDA <playerCounter
    EOR #$01
    STA <playerCounter
    BNE .levelDigitSelected
    
    .stageDigitSelected:
      LDA #STAGE_DIGIT_CURSOR_X
      STA <genericX
      LDA #STAGE_DIGIT_CURSOR_Y
      STA <genericY
      JSR MoveCursor
      JMP .setNmiFlags
    
    .levelDigitSelected:
      LDA #LEVEL_DIGIT_CURSOR_X
      STA <genericX
      LDA #LEVEL_DIGIT_CURSOR_Y
      STA <genericY
      JSR MoveCursor
      JMP .setNmiFlags
    
  .loadLevel:
    ; todo
    ;JMP .setNmiFlags
    
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw ; we only do draw in this state - no sprites or scrolling
  
  .frameDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadStageSelect                                             ;
;                                                               ;
; Description:                                                  ;
;   Loads the "stage select" state                              ;
;****************************************************************

LoadStageSelect:  

  .commonLogic:
    JSR CommonBank0Init    
  
  .drawStrings:
    LDA #STR_17
    LDA #STAGE_X
    STA <genericX
    LDA #STAGE_Y
    STA <genericY
    LDA #STR_17
    STA <genericPointer
    JSR DrawString
    LDA #STR_18
    LDA #LEVEL_X
    STA <genericX
    LDA #LEVEL_Y
    STA <genericY
    LDA #STR_18
    STA <genericPointer
    JSR DrawString
      
  .setVars:
    LDA #$00
    STA <LOW(levelPointer)  ; selected stage
    STA <HIGH(levelPointer) ; selected level
    STA <playerCounter      ; 0 = stage, 1 = level    
   
  .drawDigits:
    JSR DrawDigits
   
  .drawCursor:
    LDA #STAGE_DIGIT_CURSOR_X
    STA <genericX
    LDA #STAGE_DIGIT_CURSOR_Y
    STA <genericY
    JSR SetCursor    
   
  .fadeIn:
    JSR FadeIn ; this enables PPU    
  
  .initializeSound:
    LDX #song_index_song_title
    JSR PlaySong
    
  JMP WaitForFrame 

;****************************************************************
; Name:                                                         ;
;   DrawDigits                                                  ;
;                                                               ;
; Description:                                                  ;
;   Draws the digits                                            ;
;****************************************************************
  
DrawDigits:

  .drawDigits:
    LDA #STAGE_DIGIT_X
    STA <genericX
    LDA #STAGE_DIGIT_Y
    STA <genericY
    LDA <LOW(levelPointer)
    STA <LOW(genericPointer)   
    JSR DrawDigit
    
    LDA #LEVEL_DIGIT_X
    STA <genericX
    LDA #LEVEL_DIGIT_Y
    STA <genericY
    LDA <HIGH(levelPointer)
    STA <LOW(genericPointer)
    JMP DrawDigit
    
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateStageSelectEnd: