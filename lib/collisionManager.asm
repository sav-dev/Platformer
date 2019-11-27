CollisionManagerStart:

;****************************************************************
; CollisionManager                                              ;
; Responsible for detecting collisions                          ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   LoadPlatformsAndThreats                                     ;
;                                                               ;
; Description:                                                  ;
;   Sets the platform and threat pointers                       ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer - set to the start of the platform data      ;
;                                                               ;
; Output variables:                                             ;
;   platformsPointer - set to the start of the platform data    ;
;   threatsPointer - set to the start of the threats data       ;
;   genericPointer - set to the first byte after threats data   ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadPlatformsAndThreats:

  ; Both in the following format:
  ;  - pointer to next screen (from here): (n x 4) + 3 (1 byte)
  ;  - number of platforms (1 byte)
  ;  - n times platform data (x1, y1, x2, y2) (n x 4 bytes)
  ;    both checks should be greater/less or equal - e.g. values will be x1 = 0, x2 = 15
  ;  - pointer to the previous screen (from here): (n x 4) + 2 (1 byte)

  .screensToSkip:
    LDA maxScroll + $01                ; load the high byte of the max scroll - that's the "number of full screens - 1".
    CLC                                ; then add 2: now we have "number of full screens + 1" - even if there are no partial screens,
    ADC #$02                           ; the export data will contain platform/data for the non-existing screen.
    STA b                              ; add 2 and set to b and c. That's the number of screens to skip.
    STA c                              ; e.g. max scroll being 07C0 means there's 9 screens of platform/threat data.
  .screensToSkipDone:                  
                                       
  .setPlatformsPointer:                 
    LDA genericPointer                 
    STA platformsPointer               
    LDA genericPointer + $01           
    STA platformsPointer + $01         ; platformsPointer set to the start of the platform data
    
    .setPlatformsPointerLoop:
      JSR MovePlatformsPointerForward  ; move platformsPointer forward
      DEC b
      BNE .setPlatformsPointerLoop     ; after this loop, platformsPointer set to the start of the threat data

    LDA platformsPointer
    STA threatsPointer
    LDA platformsPointer + $01
    STA threatsPointer + $01           ; threatsPointer set to the start of the threat data

    LDA genericPointer                 
    STA platformsPointer               
    LDA genericPointer + $01           
    STA platformsPointer + $01         ; platformsPointer set to the start of the platform data
    
    LDA threatsPointer                 
    STA genericPointer               
    LDA threatsPointer + $01           
    STA genericPointer + $01           ; genericPointer set to the start of the threat data    
  .setPlatformsPointerDone:
  
  ; platformsPointer points to start of the platform data
  ; genericPointer & threatsPointer point to the start of the threat data

  .setThreatsPointer:      
    .setThreatsPointerLoop:
      JSR MoveThreatsPointerForward    ; move threatsPointer forward
      DEC c
      BNE .setThreatsPointerLoop       ; after this loop, threatsPointer set to the first byte after threats data
     
    LDA threatsPointer
    STA b
    LDA threatsPointer + $01
    STA c                              ; cache that in {b,c}

    LDA genericPointer                 
    STA threatsPointer               
    LDA genericPointer + $01           
    STA threatsPointer + $01           ; threatsPointer set to the start of the threat data
    
    LDA b
    STA genericPointer
    LDA c
    STA genericPointer + $01           ; genericPointer set to the first byte after threats data
    
  .setThreatsPointerDone:  
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MovePlatformsPointerForward                                 ;
;                                                               ;
; Description:                                                  ;
;   Moves the platforms pointer forward                         ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;****************************************************************

MovePlatformsPointerForward:
  LDY #$00
  LDA [platformsPointer], y
  CLC
  ADC platformsPointer
  STA platformsPointer
  LDA platformsPointer + $01
  ADC #$00
  STA platformsPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MovePlatformsPointerBack                                    ;
;                                                               ;
; Description:                                                  ;
;   Moves the platforms pointer back                            ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   i                                                           ;
;****************************************************************

MovePlatformsPointerBack:
  LDA platformsPointer
  SEC
  SBC #$01
  STA platformsPointer
  LDA platformsPointer + $01
  SBC #$00
  STA platformsPointer + $01
  LDY #$00
  LDA [platformsPointer], y
  STA i
  LDA platformsPointer
  SEC
  SBC i
  STA platformsPointer
  LDA platformsPointer + $01
  SBC #$00
  STA platformsPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveThreatsPointerForward                                   ;
;                                                               ;
; Description:                                                  ;
;   Moves the threats pointer forward                           ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;****************************************************************

MoveThreatsPointerForward:
  LDY #$00
  LDA [threatsPointer], y
  CLC
  ADC threatsPointer
  STA threatsPointer
  LDA threatsPointer + $01
  ADC #$00
  STA threatsPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveThreatsPointerBack                                      ;
;                                                               ;
; Description:                                                  ;
;   Moves the threats pointer back                              ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   i                                                           ;
;****************************************************************

MoveThreatsPointerBack:
  LDA threatsPointer
  SEC
  SBC #$01
  STA threatsPointer
  LDA threatsPointer + $01
  SBC #$00
  STA threatsPointer + $01
  LDY #$00
  LDA [threatsPointer], y
  STA i
  LDA threatsPointer
  SEC
  SBC i
  STA threatsPointer
  LDA threatsPointer + $01
  SBC #$00
  STA threatsPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   CheckForCollisionsOneScreen                                 ;
;                                                               ;
; Description:                                                  ;
;   Check for platform or threat collisions on one screen       ;
;                                                               ;
; Input variables:                                              ;
;   c: 0 means we're checking the first screen,                 ;
;      1 means we're checking the second screen,                ;
;   'b' hitboxes                                                ;
;   genericPointer pointing to either platforms or threats      ;
;                                                               ;
; Output variables:                                             ;
;   collision set to 1 means collision has been detected        ;
;   ax1,ay1,... are set to the object collision was found for   ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   c (input)                                                   ;
;   d (used as a counter)                                       ;
;   collision vars                                              ; 
;****************************************************************
    
CheckForPlatformOneScreen:
  
  LDA #$00                      
  STA collision
    
  LDY #$01                            ; skip first byte of the pointer (pointer to the next screen)
  LDA [genericPointer], y             ; load the number of objects
  BNE .performChecks                  
  RTS                                 ; if we get here it means there are no objects on the current scren
  
  .performChecks:
    ASL A       
    ASL A                             ; A = number of objects on the screen x 4
    CLC
    ADC #$02
    STA d                             ; d = number of objects on the screen x 4 + 2 = what Y will be equal to after the last object
    INY                               ; Y points to the first coordinate of the first object
      
    .checkPlatformLoop:       
      LDA [genericPointer], y         ; X1
      STA ax1   
      INY       
      LDA [genericPointer], y         ; Y1
      STA ay1 
      INY   
      LDA [genericPointer], y         ; X2
      STA ax2 
      INY   
      LDA [genericPointer], y         ; Y2
      STA ay2 
      INY   
      
      .transposition:
        
        ; Transposition logic:
        ;    1st screen: x' = x - low byte of scroll
        ;       calculate x2'. If x2' < 0: check next object (object off screen)
        ;       calculate x1'. If x1' < 0, x1' = 0
        ;
        ;    2nd screen: x' = x - low byte of scroll + 256
        ;       calculate x1'. If x1' > 255, exit (platforms is off screen, they are sorted by x1 so all subsequent ones will also be off screen)
        ;       calculate x2'. If x2' > 255, x2' = 255
      
        LDA c
        BNE .transpositionFor2nd
        
        .transpositionFor1st:
          LDA ax2
          SEC
          SBC scroll
          BCC .loopCheck              ; carry cleared means ax2 - scroll < 0. Object off screen, check next object
          STA ax2
          LDA ax1
          SEC
          SBC scroll
          BCC .zeroOutX1              ; carry cleared means ax1 - scroll < 0 - set to 0
          STA ax1
          JMP .transpositionDone
          .zeroOutX1:
            LDA #$00
            STA ax1
            JMP .transpositionDone
          
        ; POI - possible optimization - I think this can be calculated better
          
        .transpositionFor2nd:
          LDA #SCREEN_WIDTH
          SEC
          SBC scroll
          CLC
          ADC #$01                    ; A = 256 - scroll
          BCS .exitCheck              ; carry set means scroll = 0, no need to check 2nd screen, just exit
          ADC ax1                     ; x1' = x1 - scroll + 256
          BCS .exitCheck              ; carry set means object is off screen, they are sorted by x1, just exit.
          STA ax1
          LDA #SCREEN_WIDTH
          SEC
          SBC scroll
          CLC
          ADC #$01                    ; A = 256 - scroll, no need to check for overflow
          ADC ax2        
          BCS .maxOutX2               ; carry set means x2' is off scren. Max it out at 255        
          STA ax2
          JMP .transpositionDone
          .maxOutX2:
            LDA #SCREEN_WIDTH
            STA ax2
      
      .transpositionDone:
      
      .checkX:
        LDA bx2
        CMP ax1
        BCS .checkXDone
        RTS                           ; ax1 > bx2, no collision, and since objects are sorted by x1, no need for further checks
      .checkXDone:
      
      .checkCollision:
        JSR CheckForCollisionNoAX1    ; check for collision between the input and the object (except for the check we already did above)
        LDA collision
        BEQ .loopCheck                ; no collision
        RTS                           ; collision detected, exit with collision = 1
      .checkCollisionDone:  
      
      .loopCheck:
        CPY d                         ; compare Y to d, if equal break
        BEQ .exitCheck
        JMP .checkPlatformLoop        ; loop
    
    .exitCheck:
      RTS
  
;****************************************************************
; Name:                                                         ;
;   CheckForCollisionNoAX1                                      ;
;                                                               ;
; Description:                                                  ;
;   Checks for collision between hitboxes a and b               ;
;   except for the ax1 > bx2 check                              ;
;   expects collision to be set to 0 before calling             ;
;****************************************************************
  
CheckForCollisionNoAX1:
  LDA ax2
  CMP bx1
  BCC .checkDone             ; ax2 < bx1, no collision 
  LDA by2
  CMP ay1
  BCC .checkDone             ; ay1 > by2, no collision  
  LDA ay2
  CMP by1
  BCC .checkDone             ; ay2 < by1, no collision  
  INC collision
  .checkDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   CheckForCollision                                           ;
;                                                               ;
; Description:                                                  ;
;   Checks for collision between hitboxes a and b               ;
;****************************************************************
  
CheckForCollision:
  LDA #$00
  STA collision
  LDA bx2
  CMP ax1
  BCC .checkDone             ; ax1 > bx2, no collision  
  JMP CheckForCollisionNoAX1 ; check other points
  .checkDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   CheckForItemCollision                                       ;
;                                                               ;
; Description:                                                  ;
;   Checks for collisions between 'b' box and an item.          ;
;   Sets collision >0 if found                                  ;
;   Sets 'a' boxes to the box of the item                       ;
;   POI - possible issue - assumes items are always fully       ;
;         on screen in the 'y' plane                            ;
;                                                               ;
; Input variables:                                              ;
;   c - whether to transpose.                                   ;
;     If set to 0:                                              ;
;       genericOffScreen - the screen the object is on          ;
;       genericX - non-transposed X                             ;
;     If set to 1:                                              ;
;       genericOffScreen - transposed, whether item on screen   ;
;       genericX - transposed X                                 ;
;   genericY - Y                                                ;
;   genericWidth - width of the object                          ;
;   genericHeight - height of the object                        ;
;                                                               ;
; Used variables:                                               ;
;   collision vars                                              ;
;****************************************************************

CheckForItemCollision:

  ; preset collision to 0
  .preset:
    LDA #$00
    STA collision
  
  ; transpose the item if needed
  .transposeIfNeeded:
    LDA c
    BNE .itemTransposed
    JSR TransposeItem  
    LDA genericVisible
    BNE .itemTransposed
    RTS  

  .itemTransposed:
  
    ; set X box first
    .setXBox:
  
      ; now check the genericOffScreen variable
      LDA genericOffScreen
      BNE .itemOffScreen
    
      ; item is on screen, set x boxes, cap X2 at max
      .itemOnScreen:  
        LDA genericX
        STA ax1
        CLC
        ADC genericWidth
        BCS .capXAtMax
        STA ax2
        JMP .setYBox
        
        .capXAtMax:
          LDA #SCREEN_WIDTH
          STA ax2
          JMP .setYBox
      
      ; item is off screen, set ax2 = genericX + width, ax1 = 0, no need to check for overflows,
      ; genericVisible would be 0 if the item was not on the screen at all.
      .itemOffScreen:
        LDA genericX
        CLC
        ADC genericWidth
        STA ax2
        LDA #$00
        STA ax1

    ; set Y box, don't cap, items processed by this routine should always be on screen.
    .setYBox:
      LDA genericY
      STA ay1
      CLC
      ADC genericHeight
      STA ay2 
    
    ; finally, check for collisions.
    JMP CheckForCollision
    
;****************************************************************
; Name:                                                         ;
;   TransposeItem                                               ;
;                                                               ;
; Description:                                                  ;
;   Transposes an item.                                         ;
;   POI - possible optimization - reuse this for elsewhere      ;
;                                                               ;
; Input variables:                                              ;
;   genericOffScreen - points to the screen the object is on    ;
;   genericX - non-transposed X                                 ;
;   genericWidth - width of the object                          ;
;                                                               ;
; Output variables:                                             ;
;   genericX, genericOffScreen, genericVisible                  ;
;****************************************************************

TransposeItem:
  
  LDA #$00
  STA genericVisible
  
  .checkScreen:
    LDA scroll + $01
    CMP genericOffScreen
    BEQ .itemOnCurrentScreen
    CLC
    ADC #$01
    CMP genericOffScreen
    BEQ .itemOnNextScreen
    JMP .itemNotVisible
      
    ; item is on the current screen. Transpose logic:
    ;   - x' = x - low byte of scroll
    ;   - if x' < 0 (carry cleared after the subtraction), set genericOffScreen to 1 (item is off screen to the left)
    ;     - then check if the item is on the screen at all
    ;     - A = generic X + item width
    ;     - if carry not set - off screen
    .itemOnCurrentScreen:
      LDA #$00
      STA genericOffScreen
      LDA genericX
      SEC
      SBC scroll
      STA genericX
      BCC .itemOffScreenToTheLeft
      INC genericVisible
      RTS
      
      .itemOffScreenToTheLeft:
        INC genericOffScreen
        CLC
        ADC genericWidth ; A still contains genericX
        BCC .itemNotVisible
        INC genericVisible
        RTS  
    
    ; item is on the next screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;   - first calculate A = 255 - scroll + 1. If this overflows, it means scroll = 0, i.e. item is off screen
    ;   - then calculate A = A + x. Again, overflow means item off screen
    .itemOnNextScreen:
      LDA #$00
      STA genericOffScreen
      LDA #SCREEN_WIDTH
      SEC
      SBC scroll
      CLC
      ADC #$01
      BCS .itemNotVisible
      ADC genericX
      BCS .itemNotVisible
      STA genericX
      INC genericVisible
      RTS      
  
  ; item not visible
  .itemNotVisible:
    RTS
    
;****************************************************************
; EOF                                                           ;
;****************************************************************

CollisionManagerEnd: