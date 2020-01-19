StateTitleStart:

;****************************************************************
; State: title                                                  ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

TITLE_PALETTE_OFFSET = $07 * $10

START_BLINKING_FREQ = %00110000

SAV_2020_X = $0C
SAV_2020_Y = $1A

PRESS_START_X = $0A
PRESS_START_Y = $12

MENU_ITEMS_X = $0C
START_GAME_Y = $10
STAGE_SELECT_Y = $12
CREDITS_Y = $14

CURSOR_X = MENU_ITEMS_X - $02
CURSOR_Y_INIT = START_GAME_Y
CURSOR_Y_INCR = $02
CURSOR_Y_MAX = CREDITS_Y

START_GAME_INDEX = $00
STAGE_SELECT_INDEX = $01
CREDITS_INDEX = $02
MAX_INDEX = $03

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
    LDA <levelHelperVar
    BNE .startWasPressed
    
    .waitForStart:
      LDA <controllerPressed
      AND #CONTROLLER_START
      BEQ .processBlinking
      INC <levelHelperVar ; start pressed, inc the var
      LDA #$01
      STA <levelHelperVar2 ; hideString will decrement it back to 0
      JSR SfxOptionSelected
      JMP .hideString
      
      .processBlinking:
        LDA <frameCount
        AND #START_BLINKING_FREQ
        CMP #START_BLINKING_FREQ
        BEQ .changeState
        JMP .setNmiFlags
        
        .changeState:
          INC <needDrawLocal ; we'll be drawing
          LDA #$00
          STA <frameCount
          LDA <levelHelperVar2
          BNE .hideString
        
        .showString:
          INC <levelHelperVar2
          JSR ShowPressStartStringTitle
          JMP .setNmiFlags
          
        .hideString:
          DEC <levelHelperVar2
          JSR HidePressStartStringTitle
          JMP .setNmiFlags
          
    .startWasPressed:
      LDA <levelHelperVar2
      BNE .checkInput
      INC <levelHelperVar2
      INC <needDrawLocal ; we'll be drawing
      
      .renderMenu:
        LDA #MENU_ITEMS_X
        STA <genericX
        LDA #START_GAME_Y
        STA <genericY
        LDA #STR_1
        STA <genericPointer
        JSR DrawString
        LDA #MENU_ITEMS_X
        STA <genericX
        LDA #STAGE_SELECT_Y
        STA <genericY
        LDA #STR_2
        STA <genericPointer
        JSR DrawString
        LDA #MENU_ITEMS_X
        STA <genericX
        LDA #CREDITS_Y
        STA <genericY
        LDA #STR_3
        STA <genericPointer
        JSR DrawString
        
      .setCursor:
        LDA #START_GAME_INDEX
        STA <playerCounter
        LDA #CURSOR_X
        STA <genericX
        LDA #CURSOR_Y_INIT
        STA <genericY
        JSR SetCursor        
      
    .checkInput:
      LDA <controllerPressed
      AND #CONTROLLER_START
      BNE .optionSelected
      LDA <controllerPressed
      AND #CONTROLLER_A
      BNE .optionSelected
      LDA <controllerPressed
      AND #CONTROLLER_SEL
      BNE .changeSelectionDown
      LDA <controllerPressed
      AND #CONTROLLER_DOWN
      BNE .changeSelectionDown
      LDA <controllerPressed
      AND #CONTROLLER_UP
      BNE .changeSelectionUp
      JMP .setNmiFlags
      
      .optionSelected:
        JSR SfxOptionSelected
        JSR PauseSong

        JSR WaitForFrame
        JSR FadeOut
        LDX #STATE_CHANGE_TIMEOUT
        JSR SleepForXFrames
        
        LDA <playerCounter
        BEQ .startGame ; START_GAME_INDEX = 0
        CMP #STAGE_SELECT_INDEX
        BEQ .stageSelect
        
        .credits:
          LDA #NUMBER_OF_LEVELS
          STA <currentLevel
          DEC <currentLevel ; last level = credits
          INC <progressGame
          JMP .setNmiFlags
        
        .stageSelect:
          LDA #GAMESTATE_STAGE_SELECT
          STA <gameState
          JSR LoadStageSelect ; no need to bank switch as we are already in 0
          JMP .setNmiFlags
        
        .startGame:
          LDA #$00
          STA <currentLevel
          INC <progressGame        
          JMP .setNmiFlags
      
      .changeSelectionDown:
        JSR SfxOptionChanged
        INC <playerCounter
        LDA <playerCounter
        CMP #MAX_INDEX
        BEQ .resetCursorTo0
        
        .moveCursorDown:
          LDA <playerX
          STA <genericX
          LDA <playerY
          CLC
          ADC #CURSOR_Y_INCR
          STA <genericY
          JSR MoveCursor ; this increments needDrawLocal
          JMP .setNmiFlags
        
        .resetCursorTo0:
          LDA #START_GAME_INDEX
          STA <playerCounter
          LDA #CURSOR_X
          STA <genericX
          LDA #CURSOR_Y_INIT
          STA <genericY
          JSR MoveCursor ; this increments needDrawLocal           
          JMP .setNmiFlags
        
      .changeSelectionUp:
        JSR SfxOptionChanged
        DEC <playerCounter        
        LDA <playerCounter
        CMP #$FF
        BEQ .resetCursorToMax
        
        .moveCursorUp:
          LDA <playerX
          STA <genericX
          LDA <playerY
          SEC
          SBC #CURSOR_Y_INCR
          STA <genericY
          JSR MoveCursor ; this increments needDrawLocal
          JMP .setNmiFlags       
          
        .resetCursorToMax:
          LDA #MAX_INDEX - $01
          STA <playerCounter
          LDA #CURSOR_X
          STA <genericX
          LDA #CURSOR_Y_MAX
          STA <genericY
          JSR MoveCursor ; this increments needDrawLocal           
          JMP .setNmiFlags
          
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw ; we only do draw in this state - no sprites or scrolling
  
  .frameDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   ShowPressStartStringTitle                                   ;
;                                                               ;
; Description:                                                  ;
;   Shows the "press start" string.                             ;
;****************************************************************
    
ShowPressStartStringTitle:
  LDA #PRESS_START_X
  STA <genericX
  LDA #PRESS_START_Y
  STA <genericY
  LDA #STR_0
  STA <genericPointer
  JMP DrawString       
  
;****************************************************************
; Name:                                                         ;
;   HidePressStartStringTitle                                   ;
;                                                               ;
; Description:                                                  ;
;   Hides the "press start" string.                             ;
;****************************************************************
    
HidePressStartStringTitle:
  LDA #PRESS_START_X
  STA <genericX
  LDA #PRESS_START_Y
  STA <genericY
  LDA #STR_0
  STA <genericPointer
  JMP ClearString
          
;****************************************************************
; Name:                                                         ;
;   LoadTitle                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads the "title" state                                     ;
;****************************************************************

LoadTitle:  

  .commonLogic:
    JSR CommonBank0Init
    
  .drawLogo:
    JSR DrawLogo

  .drawStrings:
    LDA #SAV_2020_X
    STA <genericX
    LDA #SAV_2020_Y
    STA <genericY
    LDA #STR_4
    STA <genericPointer
    JSR DrawString
    JSR ShowPressStartStringTitle
    INC <needDraw ; we'll be drawing (must be needDraw, not local as this is in the init)
    
  .fadeIn:
    JSR FadeIn ; this enables PPU

  .initializeSound:
    LDX #song_index_song ; todo 0007: update the song id
    JSR PlaySong

  .initVars:
    LDA #$00
    STA <levelHelperVar  ; = whether start was pressed
    LDA #$01
    STA <levelHelperVar2 ; = whether press start is currently printed
    
  JMP WaitForFrame 
  
;****************************************************************
; Name:                                                         ;
;   CommonBank0Init                                             ;
;                                                               ;
; Description:                                                  ;
;   Common bank 0 initialization logic                          ;
;****************************************************************
  
CommonBank0Init:
  
  .disablePPUAndSleep:  
    JSR DisablePPU
    JSR ClearSprites
    INC <needDma
    JSR WaitForFrame
 
  .setVramAddressingTo1:
    JSR SetVramAddressingTo1
 
  .clearBackground:
    JSR ClearBackgrounds
      
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
    LDA #$00 ; 2nd palette = text
    STA <renderAtts
    LDA #$08 ; 8 atts rows = entire screen
    STA <genericHeight
    JSR SetAttributes
    
  .initVars:
    LDA #$00
    STA <frameCount
  
  RTS
  
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
  
    RTS

  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateTitleEnd: