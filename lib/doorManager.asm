DoorManagerStart:

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

  .checkIfExists:
    LDA <doorExists
    BNE .processDoor
    RTS
    
  .processDoor:
    JSR TransposeDoor
    LDA <genericVisible
    BEQ .processKeycard
    JSR RenderDoor
    
  .processKeycard:
    JSR TransposeKeycard
    LDA <genericVisible
    BNE .renderKeycard
    RTS
    
    .renderKeycard:
      JSR RenderKeycard
    
    .checkKeycardCollision:
      LDA <keycardY
      STA <genericY
      LDA #KEYCARD_HEIGHT
      STA <genericHeight
      LDA #$01
      STA <c; everything is still transposed from above, set c to > 0 to signal that
      
      LDA <playerPlatformBoxX1
      STA <bx1
      LDA <playerPlatformBoxX2
      STA <bx2
      LDA <playerPlatformBoxY1
      STA <by1
      LDA <playerPlatformBoxY2
      STA <by2
      JSR CheckForItemCollision      
      LDA <collision
      BNE .keycardCollision
      RTS
    
    .keycardCollision:
      PlaySfxHighPri #sfx_index_sfx_shot ; todo 0007: update the sound
      LDA #$00
      STA <doorExists; keycard collision, simply disable the door, next frame both door and keycard will disappear
      RTS

;****************************************************************
; Name:                                                         ;
;   TransposeDoor                                               ;
;                                                               ;
; Description:                                                  ;
;   Transposes the door.                                        ;
;                                                               ;
; Output variables:                                             ;
;   genericX, genericOffScreen, genericVisible                  ;
;****************************************************************

TransposeDoor:
  LDA <doorX
  STA <genericX
  LDA <doorScreen
  STA <genericOffScreen
  LDA #DOOR_WIDTH
  STA <genericWidth
  JMP TransposeItem
  
;****************************************************************
; Name:                                                         ;
;   TransposeKeycard                                            ;
;                                                               ;
; Description:                                                  ;
;   Transposes the keycard.                                     ;
;                                                               ;
; Output variables:                                             ;
;   genericX, genericOffScreen, genericVisible                  ;
;****************************************************************

TransposeKeycard:
  LDA <keycardX
  STA <genericX
  LDA <keycardScreen
  STA <genericOffScreen
  LDA #KEYCARD_WIDTH
  STA <genericWidth
  JMP TransposeItem
  
;****************************************************************
; Name:                                                         ;
;   CheckForDoorCollision                                       ;
;                                                               ;
; Description:                                                  ;
;   Checks for collisions between 'b' box and the door.         ;
;   Sets collision >0 if found                                  ;
;   Sets 'a' boxes to the box of the door                       ;
;                                                               ;
; Used variables:                                               ;
;   c                                                           ;
;   collision vars                                              ;
;   generic vars                                                ;
;****************************************************************

CheckForDoorCollision:
  LDA <doorExists
  BNE .checkCollision
  LDA #$00
  STA <collision
  RTS ; door doesn't exist
  
  .checkCollision:
    LDA <doorX
    STA <genericX
    LDA <doorY
    STA <genericY
    LDA <doorScreen
    STA <genericOffScreen
    LDA #DOOR_WIDTH
    STA <genericWidth
    LDA #DOOR_HEIGHT
    STA <genericHeight
    LDA #$00
    STA <c; we want to transpose
    JMP  CheckForItemCollision  
    
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
    STA <renderTile   
    LDA #DOOR_ATTS
    STA <renderAtts
    
  .setXLeftCol:
    LDA <genericOffScreen
    BNE .setXRightColLeftOffScreen ; off screen tot the left, don't draw this column, and have special logic for the 2nd one
    LDA <genericX
    STA <renderXPos   
    
  .renderLeftColumn:
    LDA <doorY
    STA <renderYPos
    JSR RenderDoorColumn
    
  .setXRightCol:
    LDA <genericX
    CLC
    ADC #SPRITE_DIMENSION
    BCS .renderDoorDone            ; 2nd column is off screen to the right
    STA <renderXPos   
    
  .renderRightColumn:
    LDA <doorY
    STA <renderYPos
    LDA <renderAtts
    ORA #%01000000
    STA <renderAtts
    JMP RenderDoorColumn
    
  .setXRightColLeftOffScreen:
    LDA <genericX
    CLC
    ADC #SPRITE_DIMENSION
    BCC .renderDoorDone            ; 2nd column is off screen to the left
    STA <renderXPos
    JMP .renderRightColumn
    
  .renderDoorDone:
    RTS
  
  RenderDoorColumn:
    LDY #DOOR_HEIGHT_IN_SPRITES
    .renderLoop:
      JSR RenderSprite
      LDA <renderYPos
      CLC
      ADC #SPRITE_DIMENSION
      STA <renderYPos              ; no overflow check since doors should always be fully on screen in Y plane
      DEY
      BNE .renderLoop
      RTS
      
;****************************************************************
; Name:                                                         ;
;   RenderKeycard                                               ;
;                                                               ;
; Description:                                                  ;
;   Renders the keycard.                                        ;
;                                                               ;
; Input variables:                                              ;
;   genericX, genericOffScreen - transposed position            ;
;   keycardY - position                                         ;
;                                                               ;
; Used variables:                                               ;
;   render vars                                                 ;
;****************************************************************

RenderKeycard:

  .presetVars:
    LDA #KEYCARD_ATTS
    STA <renderAtts
    LDA <keycardY
    STA <renderYPos
    LDA #KEYCARD_SPRITE_1
    STA <renderTile
    
  .checkIfOnScreen:
    LDA <genericOffScreen
    BNE .offScreen
    
  .onScreen:
    LDA #KEYCARD_SPRITE_1
    STA <renderTile
    LDA <genericX
    STA <renderXPos
    JSR RenderSprite
    LDA <genericX
    CLC
    ADC #SPRITE_DIMENSION
    BCS .done
    STA <renderXPos
    LDA #KEYCARD_SPRITE_2
    STA <renderTile   
    JMP RenderSprite
    
  ; off screen, but visible - only render the 2nd sprite
  .offScreen:
    LDA <genericX
    CLC
    ADC #SPRITE_DIMENSION
    STA <renderXPos
    LDA #KEYCARD_SPRITE_2
    STA <renderTile   
    JMP RenderSprite
  
  .done:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadDoorAndKeycard                                          ;
;                                                               ;
; Description:                                                  ;
;   Loads door and keycard.                                     ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer - 1st byte of the door/keycard data          ;
;                                                               ;
; Output variables:                                             ;
;   genericPointer - set to 1st byte after door/keycard data    ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_door_in_level_data_format                        ;
;   depends_on_door_in_memory_format                            ;
;****************************************************************
    
LoadDoorAndKeycard:

  ; the next 7 bytes genericPointer points to are the same as the 7 bytes in memory starting with doorExists, just copy those bytes.
  
  LDY #$00
  LDX #$00
  
  .copyLoop:  
    LDA [genericPointer], y  
    STA doorExists, x
    INY
    INX
    CPX #DOOR_DATA_SIZE
    BNE .copyLoop
    
  LDA <genericPointer
  CLC
  ADC #DOOR_DATA_SIZE
  STA <genericPointer
  LDA <genericPointer + $01
  ADC #$00
  STA <genericPointer + $01
    
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

DoorManagerEnd: