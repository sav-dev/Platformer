BankManagerStart:

;****************************************************************
; BankManager                                                   ;
; Responsible for bank switching                                ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   SwitchBank                                                  ;
;                                                               ;
; Description:                                                  ;
;   Switches to a different bank, disables the sound update to  ;
;   avoid issues with NMI switching bank in the middle of this. ;
;                                                               ;
; Input variables:                                              ;
;   Y register pointing to a bank                               ;
;****************************************************************

SwitchBank:
  INC <skipSoundUpdate ; skip sound update so the NMI bank switching doesn't mess up things here
  LDA <currentBank
  STA <previousBank
  STY <currentBank
  LDA BankTable, y
  STA BankTable, y
  RTS

;****************************************************************
; Name:                                                         ;
;   SelectBank                                                  ;
;                                                               ;
; Description:                                                  ;
;   Selects a bank, disables the sound update temporarily but   ;
;   then reenables it (use for constant switch, not a case      ;
;   where we want to switch temporarily and then restore the    ;
;   original bank).                                             ;
;                                                               ;
; Input variables:                                              ;
;   Y register pointing to a bank                               ;
;****************************************************************

SelectBank:
  JSR SwitchBank
  LDA #$00
  STA <skipSoundUpdate
  RTS
  
;****************************************************************
; Name:                                                         ;
;   RestoreBank                                                 ;
;                                                               ;
; Description:                                                  ;
;   Restores the bank to the previous one                       ;
;****************************************************************

RestoreBank:
  LDA <previousBank
  STA <currentBank
  TAY
  LDA BankTable, y
  STA BankTable, y
  LDA #$00
  STA <skipSoundUpdate ; safe to do sound updates now
  RTS

;****************************************************************
; Bank table used for bank switching                            ;
;****************************************************************

BankTable:
  .byte $00, $01, $02, $03, $04, $05, $06
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

BankManagerEnd: