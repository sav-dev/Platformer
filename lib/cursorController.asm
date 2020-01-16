CursorControllerStart:

;****************************************************************
; CursorController                                              ;
; Responsible for drawing the cursor                            ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   MoveCursor                                                  ;
;                                                               ;
; Description:                                                  ;
;   Moves the cursor (clearing the tile in previous location)   ;
;   Updates playerX/Y                                           ;
;                                                               ;
; Input variables:                                              ;
;   genericDX/DY - position move the cursor to                  ;
;****************************************************************

MoveCursor:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SetCursor                                                   ;
;                                                               ;
; Description:                                                  ;
;   Sets the cursor                                             ;
;   Updates playerX/Y                                           ;
;                                                               ;
; Input variables:                                              ;
;   genericDX/DY - position move the cursor to                  ;
;****************************************************************

SetCursor:
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

CursorControllerEnd: