StateStoryStart:

;****************************************************************
; State: story                                                  ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

PRESS_START_Y_STORY = $18

;****************************************************************
; Name:                                                         ;
;   StoryFrame                                                  ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "story" state        ;
;****************************************************************

StoryFrame:

  .resetNmiFlags:
    LDA #$00
    STA <needDrawLocal
        
  .processFrame:
    LDA <controllerPressed
    AND #CONTROLLER_START
    BEQ .processBlinking
    
    .nextLevel:
      ; todo
      ; handle currentLevel overflow
      JMP GameLoopDone
      
    .processBlinking:
      LDA <frameCount
      AND #START_BLINKING_FREQ
      CMP #START_BLINKING_FREQ
      BEQ .changeState
      JMP .setNmiFlags
      
      .changeState:
        LDA #$00
        STA <frameCount
        LDA <levelHelperVar2
        BNE .hideString
      
      .showString:
        INC <levelHelperVar2
        LDA #PRESS_START_X
        STA <genericX
        LDA #PRESS_START_Y_STORY
        STA <genericY
        LDA #STR_0
        STA <genericPointer
        JSR DrawString
        JMP .setNmiFlags
        
      .hideString:
        DEC <levelHelperVar2
        LDA #PRESS_START_X
        STA <genericX
        LDA #PRESS_START_Y_STORY
        STA <genericY
        LDA #STR_0
        STA <genericPointer
        JSR ClearString
    
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw ; we only do draw in this state - no sprites or scrolling
  
  .frameDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadStory                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads the "story" state                                     ;
;****************************************************************

LoadStory:  

  .commonLogic:
    JSR CommonBank0Init    
    
  .fadeIn:
    JSR FadeIn ; this enables PPU  
  
  .drawStrings:
    JSR DrawStoryStrings
  
  .initVars:
    LDA #$00
    STA <levelHelperVar2 ; = whether press start is currently printed
    
  ; todo 0006 - is this the right place to call this? 
  .initializeSound:
    JSR InitializeSound
    JSR StopSong
    
  JMP WaitForFrame 

;****************************************************************
; Name:                                                         ;
;   DrawStoryStrings                                            ;
;                                                               ;
; Description:                                                  ;
;   Draws story strings based on level pointer                  ;
;****************************************************************
  
DrawStoryStrings:
  
  LDY #$00
  LDA [levelPointer], y ; number of strings
  TAX
  INY
  
  .drawStringLoop:
    LDA [levelPointer], y ; x
    STA <genericX
    INY
    LDA [levelPointer], y ; y
    STA <genericY
    INY
    LDA [levelPointer], y ; strings id
    STA <genericPointer
    INY
    STX <xPointerCache
    STY <yPointerCache
    JSR DrawString ; changes x & y
    JSR WaitForFrame
    LDX <xPointerCache
    LDY <yPointerCache
    DEX
    BNE .drawStringLoop
    
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateStoryEnd: