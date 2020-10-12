StatePasswordStart:

;****************************************************************
; State: password                                               ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

; todo: password

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
    ; todo: password
    
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
  
  ; todo: password
    
  .fadeIn:
    JSR FadeIn ; this enables PPU    
  
  .initializeSound:
    LDX #song_index_song_title
    JSR PlaySong
    
  JMP WaitForFrame 

;****************************************************************
; EOF                                                           ;
;****************************************************************

StatePasswordEnd: