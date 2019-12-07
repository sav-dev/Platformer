ControllerManagerStart:

;****************************************************************
; ControllerManager                                             ;                           
; Responsible for checking the state of the controller          ;
;                                                               ;
; Controllers are read through memory ports $4016 and $4017     ;
; To read it first latch the buttons by writing $01 and $00     ;
; Then read 8 bytes for all buttons                             ;
;                                                               ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   ReadController                                              ;
;                                                               ;
; Description:                                                  ;
;   Reads the state of the first controller                     ;
;                                                               ;
; Variables used:                                               ;
;   b                                                           ;
;****************************************************************

ReadController:
 
  .readController:
  
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016                 ; latch buttons
    LDX #$08                  ; read 8 buttons for player 1
                              
    .loop:                    
      LDA $4016               
      LSR A                   
      ROL <b                  ; store the buttons in b for now
      DEX
      BNE .loop
    
    ; We "NOT" the previous state of controllers, and "AND" it with the current one
    ; to get the list of buttons pressed since the last time ReadController was called.
    ;
    ; E.g. if previously this was the state of controllers: 11000110
    ; And this is the current one: 10001001
    ; This is what will happen:
    ;
    ;   NOT(11000110) = 00111001
    ;   00111001 AND 10001001 = 00001001
     
    LDA #$FF
    EOR <controllerDown       ; NOT previous state of controllers
    AND <b                    ; AND with the current state
    STA <controllerPressed    ; store that as controllerPressed
    LDA <controllerDown       ; load previous state of controllers
    STA <controllerPrevious   ; store that in controllerPrevious
    LDA <b                    ; load the placeholder
    STA <controllerDown       ; finally, store that as current state of controllers
    
  .readControllerDone:
  
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

ControllerManagerEnd: