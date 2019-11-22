;****************************************************************
; DoorManager                                                   ;
; Responsible for processing doors and keycards                 ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   RenderDoor                                                  ;
;                                                               ;
; Description:                                                  ;
;   Renders the door.                                           ;
;                                                               ;
; Input variables:                                              ;
;   genericX, genericY, genericOffScreen - position             ;
;                                                               ;
; Used variables:                                               ;
;   renderAtts                                                  ;
;   Y                                                           ;
;****************************************************************

RenderDoor:

  .presetVars:
    LDA #DOOR_SPRITE
    STA renderTile    
    LDA #DOOR_ATTS
    STA renderAtts
    
  .setXLeftCol:
    LDA genericOffScreen
    BNE .setXRightColLeftOffScreen ; off screen tot the left, don't draw this column, and have special logic for the 2nd one
    LDA genericX
    STA renderXPos    
    
  .renderLeftColumn:
    LDA genericY
    STA renderYPos
    JSR RenderDoorColumn
    
  .setXRightCol:
    LDA genericX
    CLC
    ADC #SPRITE_DIMENSION
    BCS .renderDoorDone            ; 2nd column is off screen to the right
    STA renderXPos    
    
  .renderRightColumn:
    LDA genericY
    STA renderYPos
    LDA renderAtts
    ORA #%01000000
    STA renderAtts
    JMP RenderDoorColumn
    
  .setXRightColLeftOffScreen:
    LDA genericX
    CLC
    ADC #SPRITE_DIMENSION
    BCC .renderDoorDone            ; 2nd column is off screen to the left
    STA renderXPos
    JMP .renderRightColumn
    
  .renderDoorDone:
    RTS
  
  RenderDoorColumn:
    LDY #DOOR_HEIGHT_IN_SPRITES
    .renderLoop:
      JSR RenderSprite
      LDA renderYPos
      CLC
      ADC #SPRITE_DIMENSION
      STA renderYPos               ; no overflow check since doors should always be fully on screen in Y plane
      DEY
      BNE .renderLoop
      RTS