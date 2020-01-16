StateStoryStart:

;****************************************************************
; State: story                                                  ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

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
    ; ...
    
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

  ; todo 0006 - is this the right place to call this?
  .initializeSound:
    JSR InitializeSound
    JSR StopSong
    
  JMP WaitForFrame 
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateStoryEnd: