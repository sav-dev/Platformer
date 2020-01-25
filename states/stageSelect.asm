StateStageSelectStart:

;****************************************************************
; State: stage select                                           ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

; todo 0005: stage select

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
    ; todo 0005: stage select
    
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
  
  ; todo 0005: stage select
    
  .fadeIn:
    JSR FadeIn ; this enables PPU    
  
  .initializeSound:
    LDX #song_index_song_title ; todo 0007: update the song id
    JSR PlaySong
    
  JMP WaitForFrame 

;****************************************************************
; EOF                                                           ;
;****************************************************************

StateStageSelectEnd: