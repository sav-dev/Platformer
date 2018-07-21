;****************************************************************
; ElevatorManager                                               ;
; Responsible for updating and rendering Elevators              ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   RenderElevator                                              ;
;                                                               ;
; Description:                                                  ;
;   Renders an elevator.                                        ;
;                                                               ;
; Input variables:                                              ;
;   genericX, genericY, genericOffScreen - position             ;
;   genericFrame - size                                         ;
;                                                               ;
; Used variables:                                               ;
;   updates genericX, genericY, genericFrame                    ;
;   b - used to track current x offset                          ;
;****************************************************************
    
RenderElevator:
  
  ; preset b (x offset) to 0
  LDA #$00
  STA b
  
  ; main rendering loop
  .renderTileLoop:
  
    ; check if we want to render the tile based on the X position.
    ; load the current offset, add the position, store it in renderXPos.
    ; then check if the tile is on or off screen.
    .checkXPosition:            
      LDA b
      CLC
      ADC genericX
      STA renderXPos
      BCS .tileOffScreen
                        
      ; tile on screen, only render if genericOffScreen == 0
      .tileOnScreen:
        LDA genericOffScreen
        BNE .loopCheck
        JMP .setAttsAndTile
      
      ; tile off screen, only render if genericOffScreen == 1
      .tileOffScreen:           
        LDA genericOffScreen    
        BEQ .loopCheck
      
    ; if we got here we want to render the tile. renderXPos and renderYPos is already set.
    ; if b == 0 it means we're rendering the left end.
    ; if genericFrame == 1 it means we're rendering the right end.
    ; but first set the atts.
    .setAttsAndTile:
      LDA #ELEVATOR_ATTS
      STA renderAtts
      LDA b
      BEQ .renderingLeftEnd
      LDA genericFrame
      CMP #$01
      BEQ .renderingRightEnd
      
      ; rendering the center, set the right tile
      .renderingCenter:
        LDA #ELEVATOR_SPRITE
        STA renderTile
        JMP .setYPosition
      
      ; rendering the left end, set horizontal flip, 
      ; then let flow into .renderingRightEnd to set the tile
      .renderingLeftEnd:
        LDA renderAtts
        ORA #%01000000
        STA renderAtts
      
      ; rendering the right end, set the right tile
      .renderingRightEnd:
        LDA #ELEVATOR_END_SPRITE
        STA renderTile
  
    ; set renderYPos, we have to do it every tile because RenderSprite updates it
    ; POI - possible optimization - change that? only set it once?
    .setYPosition:
      LDA genericY
      STA renderYPos
    
    .renderSprite:
      JSR RenderSprite      
    
    ; loop check - b += 8, genericFrame -= 1, genericFrame == 0 means exit
    .loopCheck:
      LDA b
      CLC
      ADC #$08
      STA b
      DEC genericFrame
      BNE .renderTileLoop
         
  RTS