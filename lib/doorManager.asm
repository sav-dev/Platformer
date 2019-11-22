;****************************************************************
; DoorManager                                                   ;
; Responsible for processing the door and keycard logic         ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   ProcessDoorAndKeycard                                       ;
;                                                               ;
; Description:                                                  ;
;   Process door and keycard logic                              ;
;                                                               ;
; Used variables:                                               ;
;   render vars                                                 ;
;   generic vars                                                ;
;   X                                                           ;
;   Y                                                           ;
;****************************************************************

ProcessDoorAndKeycard:

  ; if the door doesn't exist (either is not on the level or has been opened), exit
  .checkIfExists:
    LDA doorExists
    BNE .processDoor
    RTS
    
  ; process the door first
  .processDoor:
    JSR TransposeDoor
    LDA genericVisible
    BEQ .processKeycard ; genericVisible set to >0 if door is on the screen
    JSR RenderDoor      ; only thing we do with the door is rendering
    
  .processKeycard:
    RTS

;****************************************************************
; Name:                                                         ;
;   TransposeDoor                                               ;
;                                                               ;
; Description:                                                  ;
;   Transposes the door.                                        ;
;   POI - possible optimization - only do this once per frame?  ;
;                                                               ;
; Output variables:                                             ;
;   genericX, genericOffScreen, genericVisible                  ;
;                                                               ;
; Used variables:                                               ;
;   todo 0004                                                   ;
;****************************************************************

TransposeDoor:
  
  LDA #$00
  STA genericVisible
  STA genericOffScreen
  
  .checkScreen:
    LDA scroll + $01
    CMP doorScreen
    BEQ .doorOnCurrentScreen
    CLC
    ADC #$01
    CMP doorScreen
    BEQ .doorOnNextScreen
    JMP .doorNotVisible
      
    ; door is on the current screen. Transpose logic:
    ;   - x' = x - low byte of scroll
    ;   - if x' < 0 (carry cleared after the subtraction), set genericOffScreen to 1 (door is off screen to the left)
    ;     - then check if the door is on the screen at all
    ;     - A = generic X + door width
    ;     - if carry not set - off screen
    .doorOnCurrentScreen:
      LDA doorX
      SEC
      SBC scroll
      STA genericX
      BCC .doorOffScreenToTheLeft
      INC genericVisible
      RTS
      
      .doorOffScreenToTheLeft:
        INC genericOffScreen
        CLC
        ADC #DOOR_WIDTH_IN_PIXELS ; A still contains genericX
        BCC .doorNotVisible
        INC genericVisible
        RTS  
    
    ; door is on the next screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;   - first calculate A = 255 - scroll + 1. If this overflows, it means scroll = 0, i.e. door is off screen
    ;   - then calculate A = A + x. Again, overflow means door off screen
    .doorOnNextScreen:
      LDA #SCREEN_WIDTH
      SEC
      SBC scroll
      CLC
      ADC #$01
      BCS .doorNotVisible
      ADC doorX
      BCS .doorNotVisible
      STA genericX
      INC genericVisible
      RTS      
  
  ; door not visible
  .doorNotVisible:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   RenderDoor                                                  ;
;                                                               ;
; Description:                                                  ;
;   Renders the door.                                           ;
;                                                               ;
; Input variables:                                              ;
;   genericX, genericOffScreen - transposed position            ;
;   doorY - position                                            ;
;                                                               ;
; Used variables:                                               ;
;   render vars                                                 ;
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
    LDA doorY
    STA renderYPos
    JSR RenderDoorColumn
    
  .setXRightCol:
    LDA genericX
    CLC
    ADC #SPRITE_DIMENSION
    BCS .renderDoorDone            ; 2nd column is off screen to the right
    STA renderXPos    
    
  .renderRightColumn:
    LDA doorY
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