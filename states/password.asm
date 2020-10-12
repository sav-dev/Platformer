StatePasswordStart:

;****************************************************************
; State: password                                               ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

; todo 0005: password

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
    ; todo 0005: password
    
  .setNmiFlags:
    LDA <needDrawLocal
    BEQ .frameDone
    INC <needDraw ; we only do draw in this state - no sprites or scrolling. todo 0005: is that the case?
  
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
  
  ; todo 0005: password
    
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
