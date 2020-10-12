StatePasswordStart:

;****************************************************************
; State: password                                               ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

DIGIT_COUNT = $04

DIGIT_SPACING = $03

DIGITS_Y = $0E

DIGIT_1_X = $0B
DIGIT_2_X = DIGIT_1_X + DIGIT_SPACING
DIGIT_3_X = DIGIT_2_X + DIGIT_SPACING
DIGIT_4_X = DIGIT_3_X + DIGIT_SPACING

MAX_DIGIT = $09

;****************************************************************
; Name:                                                         ;
;   PasswordFrame                                               ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "password" state     ;
;****************************************************************

PasswordFrame:

  .resetNmiFlags:
    LDA #$00
    STA <needDrawLocal
        
  .processFrame:
    LDA <controllerPressed
    AND #CONTROLLER_START
    BNE .jumpToCheckPassword
    LDA <controllerPressed
    AND #CONTROLLER_A
    BNE .jumpToCheckPassword
    LDA <controllerPressed
    AND #CONTROLLER_B
    BNE .backToMenu
    LDA <controllerPressed
    AND #CONTROLLER_SEL
    BNE .moveCursorRight
    LDA <controllerPressed
    AND #CONTROLLER_LEFT
    BNE .moveCursorLeft
    LDA <controllerPressed
    AND #CONTROLLER_RIGHT
    BNE .moveCursorRight
    LDA <controllerPressed
    AND #CONTROLLER_UP
    BNE .increaseDigit
    LDA <controllerPressed
    AND #CONTROLLER_DOWN
    BNE .decreaseDigit
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
    
  .jumpToCheckPassword:
    JMP .checkPassword
    
  .moveCursor:
    LDA #DIGITS_Y
    STA <genericY
    LDA #DIGIT_1_X - $01
    LDX <playerCounter
    BEQ .additionDone
    
    .additionLoop:
      CLC
      ADC #DIGIT_SPACING
      DEX
      BNE .additionLoop
    
    .additionDone:
      STA <genericX
      JSR MoveCursor
      JMP .setNmiFlags
    
  .moveCursorRight:
    JSR SfxOptionChanged
    INC <playerCounter
    LDA <playerCounter
    CMP #DIGIT_COUNT
    BNE .moveCursor
    LDA #$00
    STA <playerCounter
    JMP .moveCursor
    
  .moveCursorLeft:
    JSR SfxOptionChanged
    DEC <playerCounter
    LDA <playerCounter
    CMP #$FF
    BNE .moveCursor
    LDA #DIGIT_COUNT - $01
    STA <playerCounter
    JMP .moveCursor
    
  .drawDigits:
    JSR DrawDigitsPassword
    INC <needDrawLocal
    JMP .setNmiFlags
    
  .increaseDigit:
    JSR SfxOptionChanged
    LDX <playerCounter
    INC levelTypeData1, x
    LDA levelTypeData1, x
    CMP #MAX_DIGIT + $01
    BNE .drawDigits
    LDA #$00
    STA levelTypeData1, x   
    JMP .drawDigits    
  
  .decreaseDigit:
    JSR SfxOptionChanged
    LDX <playerCounter
    DEC levelTypeData1, x
    LDA levelTypeData1, x
    CMP #$FF
    BNE .drawDigits
    LDA #MAX_DIGIT
    STA levelTypeData1, x   
    JMP .drawDigits

    
  .checkPassword:
    ; todo: check the password, go to level if good, play a buzzer sound if bad
   
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw ; we only do draw in this state - no sprites or scrolling
  
  .frameDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadPassword                                                ;
;                                                               ;
; Description:                                                  ;
;   Loads the "password" state                                  ;
;****************************************************************

LoadPassword:  

  .commonLogic:
    JSR CommonBank0Init    
    
  .drawStrings:
    ; todo draw a 'title' string
    
  .initVars:
    LDA #$00
    STA <levelTypeData1
    STA <levelTypeData2
    STA <levelTypeData3
    STA <levelTypeData4
    STA <playerCounter ; selected option
    
  .drawDigits:
    JSR DrawDigitsPassword
    
  .setCursor:
    LDA #DIGIT_1_X - $01
    STA <genericX
    LDA #DIGITS_Y
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
;   DrawDigitsPassword                                          ;
;                                                               ;
; Description:                                                  ;
;   Draws the digits                                            ;
;****************************************************************
  
DrawDigitsPassword:

  LDA #DIGIT_1_X
  STA <genericX
  LDA #DIGITS_Y
  STA <genericY
  LDA <levelTypeData1
  STA <genericPointer
  JSR DrawDigit
  
  LDA #DIGIT_2_X
  STA <genericX
  LDA #DIGITS_Y
  STA <genericY
  LDA <levelTypeData2
  STA <genericPointer
  JSR DrawDigit
  
  LDA #DIGIT_3_X
  STA <genericX
  LDA #DIGITS_Y
  STA <genericY
  LDA <levelTypeData3
  STA <genericPointer
  JSR DrawDigit
  
  LDA #DIGIT_4_X
  STA <genericX
  LDA #DIGITS_Y
  STA <genericY
  LDA <levelTypeData4
  STA <genericPointer
  JMP DrawDigit
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StatePasswordEnd: