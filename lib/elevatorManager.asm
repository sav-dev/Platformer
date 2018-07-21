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
;        - x position (1 byte)
;        - y position (1 byte)
;   - pointer to the previous screen (from here): (n x 9) + 2 (1 byte)
;
; - elevators in memory: same but starting at size (8 bytes each)
;

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
;   {todo}                                                      ;
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
;   {todo}                                                      ;
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