BankManagerStart:

;****************************************************************
; BankManager                                                   ;
; Responsible for bank switching                                ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   SelectBank                                                  ;
;                                                               ;
; Description:                                                  ;
;   Selects a bank                                              ;
;                                                               ;
; Input variables:                                              ;
;   Y register pointing to a bank                               ;
;****************************************************************

SelectBank:
  JSR StopSound ; stop all sounds just in case
  LDA <currentBank
  STA <previousBank
  STY <currentBank
  LDA BankTable, y
  STA BankTable, y
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