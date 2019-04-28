;****************************************************************
; ElevatorManager                                               ;
; Responsible for updating and rendering Elevators              ;
;****************************************************************

;
; - elevators in level data in the following format:
;   - pointer to next screen (from here): (n x 9) + 3 (1 byte)
;   - number of elevators (1 byte)
;   - n times the elevator data (9 bytes)
;        - slot to put elevator in (1 byte)
;        - elevator size (1 byte)
;        - screen the elevator is on (1 byte)
;        - movement speed (1 byte)
;        - max movement distance (1 byte)            
;        - (initial) movement left (1 byte)
;        - (initial) flip + movement direction (1 byte)
;        - y position (1 byte)
;        - x position (1 byte) (y comes before x!)
;   - pointer to the previous screen (from here): (n x 9) + 2 (1 byte)
;
; - elevators in memory: same but starting at size (8 bytes each)
;

;****************************************************************
; Name:                                                         ;
;   UpdateElevators                                             ;
;                                                               ;
; Description:                                                  ;
;   Updates all elevators:                                      ;
;     - move                                                    ;
;     - move player if on an elevator                           ;
;                                                               ;
; Used variables:                                               ;
;     X                                                         ;
;     xPointerCache                                             ;
;     enemy vars (!)                                            ;
;     elevator vars                                             ;
;     generic vars                                              ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

UpdateElevators:
  
  ; main loop - loop all elevators going down
  ; load the place pointing to after the last elevator, store it in xPointerCache
  ; the loop expects value in the A register to point to the elevator after the one we want to process
  LDA #AFTER_LAST_ELEVATOR
  .updateElevatorLoop:  
    
    ; move A to point to the next elevator we want to process. Cache that value in xPointerCache and store it in X
    SEC
    SBC #ELEVATOR_SIZE
    STA xPointerCache
    TAX                  
    
    ; X now points to the size. if it's 0, elevator is inactive - exit.
    ; otherwise, cache the size in elevatorSize.
    LDA elevators, x
    BNE .setSize
    JMP .updateElevatorLoopCondition
    
    .setSize:
      STA elevatorSize
    
    ; X += 1 to point to the screen, load it, store it in enemyScreen
    INX
    LDA elevators, X
    STA enemyScreen
    
    ; X += 1 to point to the speed, load it, if it's 0 - we can exit
    ; otherwise, cache it in enemySpeed then check if it's a special value
    INX
    LDA elevators, X
    BEQ .updateElevatorLoopCondition
    STA enemySpeed
    CMP #SMALLEST_SPECIAL_SPEED
    BCC .getMaxDistance
    
    ; special speed, call the routine to process it
    ; POI - possible optimization - we process the special speed multiple times per frame
    JSR ProcessSpecialSpeed    
    BEQ .updateElevatorLoopCondition ; A = enemySpeed after ProcessSpecialSpeed
    
    ; X += 1 to point to the max movement distance, cache it in enemyMaxDistance
    .getMaxDistance:
      INX 
      LDA elevators, X    
      STA enemyMaxDistance
    
    ; preset genericDirection to 0, then X += 1 to point to the movement distance left. 
    ; load it. if it's 0, it means the extreme was met the previous frame - 
    ; update it with enemyMaxDistance, and INC genericDirection to tell us we must update the direction.
    ; note - when updating enemies, we update the direction and update distance left as soon as it reaches 0
    ; (so it never stays at 0). We don't do this for elevators since we want to know the direction it went
    ; later when processing the frame.
    LDA #$00
    STA genericDirection
    INX
    LDA elevators, x
    BNE .someDistanceLeft
    
    .zeroDistanceReachedLastFrame:
      INC genericDirection
      LDA enemyMaxDistance
      
    .someDistanceLeft:
      SEC
      SBC enemySpeed
      STA elevators, x
      
    ; X += 1 to point to the direction.
    ; if genericDirection != 0, it means it must be updated.
    ;   GENERIC_DIR_UP    = $02 = %00000010
    ;   GENERIC_DIR_DOWN  = $03 = %00000011
    ; so to update the direction, simply EOR #$01
    INX
    LDA genericDirection
    BEQ .directionOK
    
    .directionNeedsUpdate:
      LDA elevators, x
      EOR #$01
      STA elevators, x
      JMP .directionLoaded
      
    .directionOK:
      LDA elevators, x
    
    ; once we get here, X points to the direction, and it has been loaded into A.
    ; compare it to UP and DOWN and set the DY to a right value
    ; POI - possible optimization - skip the CMP (requires updates in consts, one vertical dir must be 0)
    .directionLoaded:
      CMP #GENERIC_DIR_UP
      BEQ .elevatorGoingUp
      
    .elevatorGoingDown:
      LDA enemySpeed
      STA genericDY
      JMP .updatePosition
    
    .elevatorGoingUp:
      LDA #$00
      SEC
      SBC enemySpeed
      STA genericDY
    
    ; genericDY is set, X still points to the direction.
    ; X += 1 to point to the Y position, update it, store it in genericY
    .updatePosition:
      INX
      LDA elevators, x
      CLC
      ADC genericDY
      STA elevators, x
      STA genericY
      
    ; check if player is standing on the current elevator.    
    .checkIfPlayerOnElevator:
      LDA playerOnElevator
      BEQ .updateElevatorLoopCondition
      LDA playerElevatorId
      CMP xPointerCache
      BNE .updateElevatorLoopCondition
      
    ; player on elevator, move by genericDY
    ; POI - possible issue - this can force player into the wall
    ;       make sure that's never the case
    .playerOnElevator:
      JSR MovePlayerVertically
          
    ; loop condition - if we've not just processed the last elevator, loop.   
    ; otherwise exit
    .updateElevatorLoopCondition:
      LDA xPointerCache
      BEQ .updateElevatorsDone
      JMP .updateElevatorLoop
    
  .updateElevatorsDone:
    RTS
      
;****************************************************************
; Name:                                                         ;
;   RenderElevators                                             ;
;                                                               ;
; Description:                                                  ;
;   Renders all elevators                                       ;
;                                                               ;
; Used variables:                                               ;
;     X                                                         ;
;     xPointerCache                                             ;
;     enemy vars (!)                                            ;
;     elevator vars                                             ;
;     generic vars                                              ;
;     render vars                                               ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

RenderElevators:
  
  ; main loop - loop all elevators going down
  ; load the place pointing to after the last elevator, store it in xPointerCache
  ; the loop expects value in the A register to point to the elevator after the one we want to process
  LDA #AFTER_LAST_ELEVATOR
  .renderElevatorLoop:  
    
    ; move A to point to the next elevator we want to process. Cache that value in xPointerCache and store it in X
    SEC
    SBC #ELEVATOR_SIZE
    STA xPointerCache
    TAX                  
    
    ; X now points to the size. if it's 0, elevator is inactive - exit.
    ; otherwise, cache the size in elevatorSize.
    LDA elevators, x
    BEQ .renderElevatorLoopCondition
    STA elevatorSize
    
    ; X += 1 to point to the screen, load it, store it in enemyScreen
    INX
    LDA elevators, X
    STA enemyScreen
    
    ; X += 5 to point to the Y position, load it, store it in genericY
    ; X += 1 to point to the X position, load it, store it in genericX
    TXA
    CLC
    ADC #$05
    TAX
    LDA elevators, X
    STA genericY
    INX
    LDA elevators, X
    STA genericX
   
    ; once we get here, these are set:
    ;  - elevatorSize = elevator size
    ;  - genericScreen = elevator the screen is on
    ;  - genericX, genericY = elevator position
    ; time to transpose X. first set genericOffScreen to 0,
    ; then check if the elevator is on the current or next screen.
    .transposeX:
      LDA #$00
      STA genericOffScreen
      LDA enemyScreen
      CMP scroll + $01
      BEQ .currentScreen
  
      ; elevator is on the next screen. Transpose logic:
      ;   - x' = x - low byte of scroll + 256
      ;   - first calculate A = 255 - scroll + 1. If this overflows,
      ;     it means scroll = 0, i.e. elevator is off screen
      ;   - then calculate A = A + x. Again, overflow means elevator off screen
      ;   - if elevator is off screen, processing is done.
      .nextScreen:
        LDA #SCREEN_WIDTH
        SEC
        SBC scroll
        CLC
        ADC #$01
        BCS .renderElevatorLoopCondition
        ADC genericX
        BCS .renderElevatorLoopCondition
        STA genericX
        JMP .renderElevator
        
      ; elevator is on the current screen. Transpose logic:
      ;   - x' = x - low byte of scroll
      ;   - if x' < 0 (carry cleared after the subtraction), set genericOffScreen to 1
      ;     - we then have to check the width from the const data to see if elevator is truly on screen
      ;     - logic: A = width + generic X
      ;     - if carry not set - off screen
      ;     - else if result < 8 (sprite width) - off screen
      ;     - else - on screen
      .currentScreen:
        LDA genericX
        SEC
        SBC scroll
        STA genericX
        BCS .renderElevator
        INC genericOffScreen
        LDY elevatorSize
        CLC
        ADC ElevatorWidth, y
        BCC .renderElevatorLoopCondition
        CMP #SPRITE_DIMENSION
        BCC .renderElevatorLoopCondition
  
      ; once we get here, everything needed to render the elevator is set:
      ;  - elevatorSize, genericOffScreen, genericX, genericY
      .renderElevator:
        JSR RenderElevator
  
    ; loop condition - if we've not just processed the last elevator, loop.   
    ; otherwise exit
    .renderElevatorLoopCondition:
      LDA xPointerCache
      BNE .renderElevatorLoop
      RTS

;****************************************************************
; Name:                                                         ;
;   CheckForElevatorCollision                                   ;
;                                                               ;
; Description:                                                  ;
;   Checks for a collision between the 'b' box                  ;
;   and all elevators                                           ;
;                                                               ;
; Input variables:                                              ;
;   'b' box                                                     ;
;                                                               ;
; Output variables:                                             ;
;   collision - set to 1 if collision was detected              ;
;   'a' box - set to the box of the elevator that was hit       ;
;   yPointerCache - points to the elevator that was hit         ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   yPointerCache                                               ;
;   enemyScreen                                                 ;
;   elevatorSize                                                ;
;   collision vars                                              ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

CheckForElevatorCollision:

  ; preset collision to 0
  LDA #$00
  STA collision
  
  ; main loop - loop all elevators going down
  ; load the place pointing to after the last elevator, store it in yPointerCache
  ; the loop expects value in the A register to point to the elevator after the one we want to process
  LDA #AFTER_LAST_ELEVATOR
  .checkCollisionLoop:  
    
    ; move A to point to the next elevator we want to process. Cache that value in yPointerCache and store it in Y
    SEC
    SBC #ELEVATOR_SIZE
    STA yPointerCache
    TAY                
    
    ; Y now points to the size. if it's 0, elevator is inactive - exit.
    ; otherwise, check for a collision.
    LDA elevators, y
    BEQ .checkCollisionLoopCondition    
    
    ; Check for a collision, exit if found
    JSR SingleElevatorCollision
    LDA collision
    BEQ .checkCollisionLoopCondition
      
    ; Collision found.
    ; Just exit, we'll have:
    ;  - collision set to 1
    ;  - 'a' boxes set to the right elevator
    ;  - yPointerCache pointing to the elevator that was hit
    .collisionFound:
      RTS
      
    ; loop condition - if we've not just processed the last elevator, loop.   
    ; otherwise exit
    .checkCollisionLoopCondition:
      LDA yPointerCache
      BNE .checkCollisionLoop
      RTS

;****************************************************************
; Name:                                                         ;
;   SingleElevatorCollision                                     ;
;                                                               ;
; Description:                                                  ;
;   Checks for a collision between the 'b' box                  ;
;   and a single elevator                                       ;
;                                                               ;
; Input variables:                                              ;
;   'b' box                                                     ;
;   Y - must point to the elevator to check                     ;
;   collision - on input must be 0                              ;
;                                                               ;
; Output variables:                                             ;
;   collision - set to 1 if collision was detected              ;
;   'a' box - set to the box of the elevator that was hit       ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   yPointerCache                                               ;
;   enemyScreen                                                 ;
;   elevatorSize                                                ;
;   collision vars                                              ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

SingleElevatorCollision:

  ; Y points to the size, load it, store it in elevatorSize
  LDA elevators, y
  STA elevatorSize

  ; Y += 1 to point to the screen, load it, store it in enemyScreen
  INY
  LDA elevators, y
  STA enemyScreen
  
  ; Y += 5 to point to the y position, load it, store it in ay1
  TYA
  CLC
  ADC #$05
  TAY
  LDA elevators, y
  STA ay1
  
  ; Y += 1 to point to the x position, load it, store it in ax1
  INY
  LDA elevators, y
  STA ax1
  
  ; ax1 is set, time to transpose the elevator.
  ; first check if the elevator is on the current or next screen.
  .transposeXAndSetAX2:    
    LDA enemyScreen
    CMP scroll + $01
    BEQ .currentScreen
  
    ; elevator is on the next screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;     - first calculate A = 255 - scroll + 1. If this overflows, it means scroll = 0, i.e. elevator is off screen
    ;     - then calculate A = A + x. Again, overflow means elevator off screen
    ;     - if elevator is off screen, processing is done.
    ;   - if ax1 is on screen, proceed to ax1OnScreen
    .nextScreen:
      LDA #SCREEN_WIDTH
      SEC
      SBC scroll
      CLC
      ADC #$01
      BCS .noCollision
      ADC ax1
      BCS .noCollision
      
      ; ax1 is on screen. set updated ax1, then lookup the width (use Y, not needed anymore), add it
      ; if carry clear, just set ax2. otherwise cap it at screen_width
      .ax1OnScreen:
        STA ax1
        LDY elevatorSize
        CLC
        ADC ElevatorWidth, y
        BCS .capX2AtMax
        STA ax2
        JMP .setAY2        
        .capX2AtMax:
          LDA #SCREEN_WIDTH
          STA ax2
          JMP .setAY2
      
    ; elevator is on the current screen. Transpose logic:
    ;   - x' = x - low byte of scroll
    ;     - if x' >= 0 (carry set after the subtraction), it means ax1 is on screen, go to ax1OnScreen
    ;     - otherwise, go to ax1OffScreenToTheLeft      
    .currentScreen:
      LDA ax1
      SEC
      SBC scroll
      BCS .ax1OnScreen
      
      ; elevator starts off-screen to the left. add width from the consts.
      ; if carry is not set, it means elevator is fully off-screen - exit
      ; otherwise, set ax2 to the result, and set ax1 to 0      
      .ax1OffScreenToTheLeft:
        LDY elevatorSize
        CLC
        ADC ElevatorWidth, y
        BCC .noCollision
        ; todo uncomment this? otherwise bullets may hit 'nothing'
        ; CMP #SPRITE_DIMENSION
        ; BCC .noCollision
        STA ax2
        LDA #$00
        STA ax1
    
  ; When we get here, it means elevator is on screen, and ax1, ax2 and ay1 are set.
  ; We must now set ay2 - just add the elevator height
  .setAY2:
    LDA ay1
    CLC
    ADC #ELEVATOR_HEIGHT
    STA ay2
    
  ; When we get here, all boxes are set. Check for collision and exit.
  .checkCollision:    
    JMP CheckForCollision

  ; We get here if we figure out no collision is possible.
  ; Just exit without updating the collision var.
  .noCollision:
    RTS
      
;****************************************************************
; Name:                                                         ;
;   LoadElevatorsInitial                                        ;
;                                                               ;
; Description:                                                  ;
;   Loads elevators for screen 0 and 1,                         ;
;   sets the elevatorsPointer                                   ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer - set to the start of the elevators data     ;
;                                                               ;
; Output variables:                                             ;
;   elevatorsPointer - set to the elevators data for screen 1   ;
;   genericPointer - set to the first byte after elevators data ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadElevatorsInitial:
  
  .screensToSkip:
    LDA maxScroll + $01                ; see LoadPlatformsAndThreats for explanation of this logic
    CLC
    ADC #$02
    STA b
                                       
  .setElevatorsPointer:                 
    LDA genericPointer                 
    STA elevatorsPointer               
    LDA genericPointer + $01           
    STA elevatorsPointer + $01         ; elevatorsPointer set to elevators for screen 0
  
  .moveElevatorsPointerLoop:
    JSR MoveElevatorsPointerForward    ; move elevatorsPointer forward
    DEC b
    BNE .moveElevatorsPointerLoop      ; after this loop, elevatorsPointer set to the first byte after elevators data
    
  .setGenericPointer:
    LDA genericPointer
    STA b
    LDA genericPointer + $01
    STA c                              ; cache genericPointer (still pointing to the start of the data) in b c
    LDA elevatorsPointer
    STA genericPointer
    LDA elevatorsPointer + $01
    STA genericPointer + $01           ; genericPointer now points to the first byte after elevators data
    LDA b
    STA elevatorsPointer
    LDA c
    STA elevatorsPointer + $01         ; elevatorsPointer now points to the first byte of the elevators data
    
  .loadElevators:
    JSR LoadElevators                  ; load elevators for screen 0
    JSR MoveElevatorsPointerForward
    JSR LoadElevators                  ; load elevators for screen 1

  .playerOnElevator:
    LDA #$00
    STA playerOnElevator               ; initially player is not on an elevator
    
  RTS                                  ; elevators loaded, pointer points to screen 1 as expected

;****************************************************************
; Name:                                                         ;
;   LoadElevatorsForward                                        ;
;                                                               ;
; Description:                                                  ;
;   Load elevators for the screen in the front,                 ;
;   also moves the elevators pointer forward                    ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadElevatorsForward:
 
  ; look in LookEnemiesForward for the logic
 
  .unloadElevators:
    LDA scroll + $01
    SEC
    SBC #$01
    STA b                             ; b = screen - 1
    JSR UnloadElevators               ; unload elevators
 
  .loadElevatorsAndUpdatePointer:
    JSR MoveElevatorsPointerForward   ; move pointer forward
    JSR LoadElevators                 ; load elevators

  RTS  
  
;****************************************************************
; Name:                                                         ;
;   LoadElevatorsBack                                           ;
;                                                               ;
; Description:                                                  ;
;   Load elevators for the screen in the back,                  ;
;   also moves the elevators pointer back                       ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadElevatorsBack:

  ; look in LookEnemiesForward for the logic
  
  .unloadElevators:
    LDA scroll + $01
    CLC
    ADC #$02
    STA b                             ; b = screen + 1
    JSR UnloadElevators               ; unload elevators
 
  .loadElevatorsAndUpdatePointer:
    JSR MoveElevatorsPointerBack
    JSR MoveElevatorsPointerBack      ; move pointer back twice
    JSR LoadElevators                 ; load elevators
    JSR MoveElevatorsPointerForward   ; move pointer forward
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadElevators                                               ;
;                                                               ;
; Description:                                                  ;
;   Load elevators from elevatorsPointer                        ;
;                                                               ;
; Input variables:                                              ;
;   elevatorsPointer - elevators to load                        ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;    
;   X                                                           ;    
;   b                                                           ;    
;   c                                                           ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_level_data_format                    ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

LoadElevators:
  
  ; first Y += 1 to skip the pointer to the next screen.
  ; then load the number of elevators, exit if 0, store in b
  .loadElevatorsCount:  
    LDY #$01
    LDA [elevatorsPointer], y
    BEQ .loadElevatorsExit
    STA b
  
  ; loop for loading elevators
  .loadElevatorsLoop:
  
    ; load slot - Y += 1 to point to the slot, load it, store it in X
    INY
    LDA [elevatorsPointer], y
    TAX
      
    ; remaining 8 bytes are the same.
    ; use c as the loop counter.
    LDA #$08
    STA c
    .copyLoop:
      INY
      LDA [elevatorsPointer], y      
      STA elevators, x
      INX
      DEC c
      BNE .copyLoop
  
    ; loop if needed
    DEC b
    BNE .loadElevatorsLoop
  
  .loadElevatorsExit:
    RTS
  
;****************************************************************
; Name:                                                         ;
;   UnloadElevators                                             ;
;                                                               ;
; Description:                                                  ;
;   Unloads elevators for given screen                          ;
;                                                               ;
; Input variables:                                              ;
;   b - screen to unload the elevators for                      ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   b                                                           ;
;   c                                                           ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

UnloadElevators:

  LDX #LAST_ELEVATOR_SCREEN        ; loop all elevators going down
  LDA #ELEVATORS_COUNT
  STA c                            ; c is the loop counter
  
  ; POI - possible optimization - instead of DEC c BNE, do CPX BNE ? same in UnloadEnemies
  
  .unloadElevatorLoop:
  
    LDA elevators, x               ; load the screen the elevator is on
    CMP b
    BNE .loopCondition             ; if screen != b, don't do anything
    
    .unloadElevator:
      DEX                          ; x points to the elevator size
      LDA #ELEVATOR_EL_SIZE_EMPTY
      STA elevators, x             ; unload the elevator
      INX                          ; x points back to the screen
    
    .loopCondition:
      TXA
      SEC
      SBC #ELEVATOR_SIZE
      TAX                          ; decrement the pointer 
      DEC c                        ; decrement the loop counter
      BNE .unloadElevatorLoop         

  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveElevatorsPointerForward                                 ;
;                                                               ;
; Description:                                                  ;
;   Moves the elevators pointer forward                         ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;****************************************************************

MoveElevatorsPointerForward:
  LDY #$00
  LDA [elevatorsPointer], y
  CLC
  ADC elevatorsPointer
  STA elevatorsPointer
  LDA elevatorsPointer + $01
  ADC #$00
  STA elevatorsPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveElevatorsPointerBack                                    ;
;                                                               ;
; Description:                                                  ;
;   Moves the elevators pointer back                            ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   i                                                           ;
; POI - possible optimization - is the 'i' var needed?          ;
;****************************************************************

MoveElevatorsPointerBack:
  LDA elevatorsPointer
  SEC
  SBC #$01
  STA elevatorsPointer
  LDA elevatorsPointer + $01
  SBC #$00
  STA elevatorsPointer + $01
  LDY #$00
  LDA [elevatorsPointer], y
  STA i
  LDA elevatorsPointer
  SEC
  SBC i
  STA elevatorsPointer
  LDA elevatorsPointer + $01
  SBC #$00
  STA elevatorsPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   RenderElevator                                              ;
;                                                               ;
; Description:                                                  ;
;   Renders an elevator.                                        ;
;                                                               ;
; Input variables:                                              ;
;   genericX, genericY, genericOffScreen - position             ;
;   elevatorSize - size                                         ;
;                                                               ;
; Used variables:                                               ;
;   updates genericX, genericY, elevatorSize                    ;
;   b - used to track current x offset                          ;
;****************************************************************
    
; todo - have different size of elevators have different palette (also update AddEditElevatorDialog)
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
    ; if elevatorSize == 1 it means we're rendering the right end.
    ; but first set the atts.
    .setAttsAndTile:
      LDA #ELEVATOR_ATTS
      STA renderAtts
      LDA b
      BEQ .renderingLeftEnd
      LDA elevatorSize
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
    
    ; loop check - b += 8, elevatorSize -= 1, elevatorSize == 0 means exit
    .loopCheck:
      LDA b
      CLC
      ADC #$08
      STA b
      DEC elevatorSize
      BNE .renderTileLoop
         
  RTS

;****************************************************************
; Hardcoded elevator widths                                     ;
;****************************************************************
  
ElevatorWidth:
  .byte $00 * $00
  .byte $00 * $01
  .byte $08 * $02
  .byte $08 * $03
  .byte $08 * $04
  .byte $08 * $05
  .byte $08 * $06
  .byte $08 * $07
  .byte $08 * $08
  