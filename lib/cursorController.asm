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
;   genericX/Y - position move the cursor to                    ;
;****************************************************************

MoveCursor:

  ; cache genericX/Y
  LDA <genericX
  STA <genericDX
  LDA <genericY
  STA <genericDY

  ; clear cursor
  LDA <playerX
  STA <genericX
  LDA <playerY
  STA <genericY
  JSR CalculatePpuAddress ; [c,d] contain the PPU address of current cursor  
  LDX <bufferOffset
  LDA #$01
  STA drawBuffer, x ; length
  INX
  LDA <d
  STA drawBuffer, x ; high address
  INX
  LDA <c
  STA drawBuffer, x ; low address
  INX
  INX ; skip reserved byte 
  LDA #CLEAR_TILE
  STA drawBuffer, x ; tile to draw
  INX
  STX <bufferOffset ; move buffer
  
  ; restore genericX/Y
  LDA <genericDX
  STA <genericX
  LDA <genericDY
  STA <genericY

  ; flow into SetCursor
  
;****************************************************************
; Name:                                                         ;
;   SetCursor                                                   ;
;                                                               ;
; Description:                                                  ;
;   Sets the cursor                                             ;
;   Updates playerX/Y                                           ;
;                                                               ;
; Input variables:                                              ;
;   genericX/Y - position move the cursor to                    ;
;****************************************************************

SetCursor:

  ; set new position
  LDA <genericX
  STA <playerX
  LDA <genericY
  STA <playerY

  ; draw cursor
  JSR CalculatePpuAddress ; [c,d] contain the PPU address of current cursor  
  LDX <bufferOffset
  LDA #$01
  STA drawBuffer, x ; length
  INX
  LDA <d
  STA drawBuffer, x ; high address
  INX
  LDA <c
  STA drawBuffer, x ; low address
  INX
  INX ; skip reserved byte 
  LDA #CURSOR_TILE
  STA drawBuffer, x ; tile to draw
  INX
  STX <bufferOffset ; move buffer

  INC <needDrawLocal
  
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

CursorControllerEnd: