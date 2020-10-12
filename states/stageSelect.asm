StateStageSelectStart:

;****************************************************************
; State: stage select                                           ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

STAGE_X = $0C
STAGE_Y = $0D

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
; Arrays                                                        ;
;****************************************************************

; -1 everywhere because we skip the stories
LevelCounts:
  .byte NUMBER_OF_LEVELS_STAGE_1 - $01
  .byte NUMBER_OF_LEVELS_STAGE_2 - $01
  .byte NUMBER_OF_LEVELS_STAGE_3 - $01
  .byte NUMBER_OF_LEVELS_STAGE_4 - $01
  .byte NUMBER_OF_LEVELS_STAGE_5 - $01

; starts with 1 because we skip the stories
LevelSums:
  .byte $01
  .byte $01 + NUMBER_OF_LEVELS_STAGE_1
  .byte $01 + NUMBER_OF_LEVELS_STAGE_1 + NUMBER_OF_LEVELS_STAGE_2
  .byte $01 + NUMBER_OF_LEVELS_STAGE_1 + NUMBER_OF_LEVELS_STAGE_2 + NUMBER_OF_LEVELS_STAGE_3
  .byte $01 + NUMBER_OF_LEVELS_STAGE_1 + NUMBER_OF_LEVELS_STAGE_2 + NUMBER_OF_LEVELS_STAGE_3 + NUMBER_OF_LEVELS_STAGE_4
  
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
    BNE .jumpToLoadLevel
    LDA <controllerPressed
    AND #CONTROLLER_A
    BNE .jumpToLoadLevel
    LDA <controllerPressed
    AND #CONTROLLER_B
    BNE .backToMenu
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
    AND #CONTROLLER_RIGHT
    BNE .changeDigitRight
    LDA <controllerPressed
    AND #CONTROLLER_LEFT
    BNE .changeDigitLeft
    JMP .setNmiFlags
    
  .backToMenu:
    JSR SfxOptionSelected
    JSR PauseSong      
    JSR WaitForFrame
    JSR FadeOut
    LDX #STATE_CHANGE_TIMEOUT
    JSR SleepForXFrames
    LDA #GAMESTATE_TITLE
    STA <gameState
    JSR LoadTitle ; no need to bank switch as we are already in 0
    JMP .setNmiFlags
    
  .jumpToLoadLevel:
    JMP .loadLevel
    
  .drawDigits:
    JSR DrawDigitsStageSelect
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
  
  .changeDigitRight:
    JSR SfxOptionChanged
    LDA <playerCounter
    BNE .changeLevelDigitRight
    
    .changeStageDigitRight:
      LDA #$00
      STA <currentLevel ; always reset the level since we don't know how many there are in the new stage
      INC <levelPointer
      LDA <levelPointer
      CMP #STAGE_COUNT
      BNE .drawDigits
      LDA #$00
      STA <levelPointer
      JMP .drawDigits
    
    .changeLevelDigitRight:
      INC <currentLevel
      LDX <levelPointer
      LDA LevelCounts, x
      CMP <currentLevel
      BNE .drawDigits
      LDA #$00
      STA <currentLevel
      JMP .drawDigits      
    
  .changeDigitLeft:
    JSR SfxOptionChanged
    LDA <playerCounter
    BNE .changeLevelDigitLeft
    
    .changeStageDigitLeft:
      LDA #$00
      STA <currentLevel ; always reset the level since we don't know how many there are in the new stage
      DEC <levelPointer
      LDA <levelPointer
      CMP #$FF
      BNE .drawDigits
      LDA #STAGE_COUNT - $01
      STA <levelPointer
      JMP .drawDigits
    
    .changeLevelDigitLeft:
      DEC <currentLevel
      LDA <currentLevel
      CMP #$FF
      BNE .drawDigits
      LDX <levelPointer
      LDA LevelCounts, x
      SEC
      SBC #$01
      STA <currentLevel
      JMP .drawDigits    
    
  .loadLevel:
    JSR SfxOptionSelected
    JSR PauseSong      
    JSR WaitForFrame
    JSR FadeOut
    LDX #STATE_CHANGE_TIMEOUT
    JSR SleepForXFrames
    LDX <levelPointer
    LDA LevelSums, x
    CLC
    ADC <currentLevel
    STA <currentLevel
    INC <progressGame
    
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
    ; todo draw a 'title' string
    LDA #STAGE_X
    STA <genericX
    LDA #STAGE_Y
    STA <genericY
    LDA #STR_17
    STA <genericPointer
    JSR DrawString
    LDA #LEVEL_X
    STA <genericX
    LDA #LEVEL_Y
    STA <genericY
    LDA #STR_18
    STA <genericPointer
    JSR DrawString
      
  .setVars:
    LDA #$00
    STA <levelPointer  ; selected stage
    STA <currentLevel  ; selected level
    STA <playerCounter ; 0 = stage, 1 = level    
   
  .drawDigits:
    JSR DrawDigitsStageSelect
   
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
;   DrawDigitsStageSelect                                       ;
;                                                               ;
; Description:                                                  ;
;   Draws the digits                                            ;
;****************************************************************
  
DrawDigitsStageSelect:

  LDA #STAGE_DIGIT_X
  STA <genericX
  LDA #STAGE_DIGIT_Y
  STA <genericY
  LDA <levelPointer
  STA <genericPointer
  INC <genericPointer ; not 0 based
  JSR DrawDigit
  
  LDA #LEVEL_DIGIT_X
  STA <genericX
  LDA #LEVEL_DIGIT_Y
  STA <genericY
  LDA <currentLevel
  STA <genericPointer
  INC <genericPointer ; not 0 based
  JMP DrawDigit
    
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateStageSelectEnd: