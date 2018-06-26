;****************************************************************
; EnemiesManager                                                ;
; Responsible for rendering and updating enemies                ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   RenderEnemy                                                 ;
;                                                               ;
; Description:                                                  ;
;   Renders an enemy                                            ;
;                                                               ;
; Input variables:                                              ;
;   Generic vars:                                               ;
;     genericX, genericY, genericOffScreen - position           ;
;     genericFrame - frame to render                            ;
;     genericDirection - flip (0 = no flip, 1 = flip)           ;
;     genericPointer - pointing to the enemy (from enemies.asm) ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b                                                           ;
;****************************************************************

RenderEnemy:

  .getSpriteCount:
    LDY #$00                    ; Y points to the sprite count  
    LDA [genericPointer], y
    STA b                       ; b = sprite count
    INY                         ; Y points to xOff
  
  .checkHFlip:
    LDA genericDirection
    AND #FLIP_H_FLIP
    BNE .hFlip
  
  .noHFlip:                     ; no hFlip, read the xOff pointer
    LDA [genericPointer], y
    STA xOffPointerLow
    LDA [genericPointer], y
    STA xOffPointerHigh
    INY
    INY                         ; Y points at the xOffH pointer
    JMP .xOffSet    
  
  .hFlip:                       ; hFlip, read the xOffH pointer
    INY
    INY                         ; Y points at the xOffH pointer
    LDA [genericPointer], y
    STA xOffPointerLow
    LDA [genericPointer], y
    STA xOffPointerHigh
    
  .xOffSet:
    INY
    INY                         ; Y points at the yOff pointer
    
  .checkVFlip:
    LDA genericDirection
    AND #FLIP_V_FLIP
    BNE .vFlip
  
  .noVFlip:                     ; no vFlip, read the yOff pointer
    LDA [genericPointer], y
    STA yOffPointerLow
    LDA [genericPointer], y
    STA yOffPointerHigh
    INY
    INY                         ; Y points at the yOffV pointer
    JMP .yOffSet    
  
  .vFlip:                       ; vFlip, read the yOffV pointer
    INY
    INY                         ; Y points at the yOffV pointer
    LDA [genericPointer], y
    STA yOffPointerLow
    LDA [genericPointer], y
    STA yOffPointerHigh
    
  .yOffSet:
    INY
    INY                         ; Y points at the atts
    
  .setAttsPointer:              ; store the current value of generic pointer
    LDA genericPointer
    STA attsOffPointerLow
    LDA genericPointer + $01
    STA attsOffPointerHigh
    
  .movePointerToTiles:
    ; move by sprite count + genericFrame (-1?) * sprite count
    
  ; get tiles pointer
  
  ; all pointers set: draw
  
  RTS
  