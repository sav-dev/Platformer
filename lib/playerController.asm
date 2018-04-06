;****************************************************************
; PlayerController                                              ;
; Responsible for player's movement and graphics                ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   UpdatePlayer                                                ;
;                                                               ;
; Description:                                                  ;
;   Calls into various UpdatePlayer routines based on state     ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   f                                                           ;
;   g                                                           ;
;   h                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;****************************************************************

UpdatePlayer:
  LDA playerState
  BEQ UpdatePlayerNormal        ; PLAYER_NORMAL = 0
  CMP #PLAYER_NOT_VISIBLE
  BEQ UpdatePlayerNotVisible
  CMP #PLAYER_FALLING
  BEQ .playerFalling
  JMP UpdatePlayerExploding
  .playerFalling:
    JMP UpdatePlayerFalling
    
;****************************************************************
; Name:                                                         ;
;   UpdatePlayerNotVisible                                      ;
;                                                               ;
; Description:                                                  ;
;   Called when player is not visible and timing out            ;
;                                                               ;
; Used variables:                                               ;
;   N/I                                                         ;
;****************************************************************

UpdatePlayerNotVisible:
  DEC playerCounter
  BEQ .resetLevel
  RTS
  .resetLevel:
    JSR WaitForFrame
    JSR FadeOut
    LDX #PLAYER_DEAD_FADED_OUT
    JSR SleepForXFrames
    JSR LoadGame
    JMP GameLoopDone

;****************************************************************
; Name:                                                         ;
;   UpdatePlayerNormal                                          ;
;                                                               ;
; Description:                                                  ;
;   Updates player based on current state and input.            ;
;   Renders the player.                                         ;
;   Sets:                                                       ;
;     - playerX and playerY (updated position)                  ;
;     - playerDX and  playerDY (how much player has moved)      ;
;     - updates scroll if needed                                ;
;     - playerPlatformBox, playerCollisionBox                   ;
;     - playerGunX and playerGunY                               ;
;     - playerAnimation                                         ;
;     {todo: spawn bullets}                                     ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   f                                                           ;
;   g                                                           ;
;   h                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;****************************************************************

UpdatePlayerNormal:

  .verticalMovement:                  ; process vertical movement first
    
    .calculateDY:                     ; calculate DY   
      .checkJump:
        LDA playerJump
        BNE .processJump              ; playerJump != 0 means the player is mid-jump animation
                                      
      .applyGravity:                  
        LDA #GRAVITY                    
        STA playerDY                  ; if not mid-jump, apply gravity
        JMP .checkVerticalCollision        
                                      
      .processJump:                   
        DEC playerJump                ; decrease the jump counter
        LDX playerJump                
        LDA jumpLookupTable, x        
        BEQ .playerMidAir             ; no vertical movement, player is suspended mid air, no more checks required
        STA playerDY                  ; load the jump value        
                                    
    .checkVerticalCollision:          ; DY calculated, now check for a vertical collision
      JSR CheckCollisionVertical      ; this will update playerDY and set collision and b (b = 1 means was going down)
      JSR MovePlayerVertically        ; apply movement
      LDA collision 
      BNE .processCollision           ; process collision
      
    .playerMidAir:
      LDA #PLAYER_JUMP                ; no collision, player is mid-air, no more checks required
      STA playerAnimation
      JMP .verticalMovementDone       
        
    .processCollision:  
      LDA b 
      BNE .collisionGoingDown
        
      .collisionGoingUp:  
        LDA #JUMP_PEAK                ; collision was when going up, treat it as the jumps peak, then exit
        STA playerJump
        LDA #PLAYER_JUMP
        STA playerAnimation
        JMP .verticalMovementDone
        
      .collisionGoingDown:
        LDA #$00  
        STA playerJump                ; collision going down, cancel jump, player is on the ground now, can jump or crouch
        
      .checkA:  
        LDA controllerPressed
        AND #CONTROLLER_A 
        BEQ .checkADone               ; check if player wants to jump
        LDA #JUMP_FRAMES
        STA playerJump
        LDA #PLAYER_JUMP
        STA playerAnimation
        JMP .verticalMovementDone
      .checkADone:
      
      .checkDown:  
        LDA controllerDown 
        AND #CONTROLLER_DOWN
        BEQ .checkDownDone            ; check if player wants to crouch
        LDA #PLAYER_CROUCH
        STA playerAnimation
        JMP .verticalMovementDone
      .checkDownDone:
      
      .noInput:                       ; no input, set state to either STAND or RUN
        LDA playerAnimation
        CMP #PLAYER_RUN
        BEQ .verticalMovementDone     ; player is already running, leave animation as RUN
        LDA #PLAYER_STAND
        STA playerAnimation           ; set state to STAND        
  
  .verticalMovementDone:              ; vertical movement processed
     
  .horizontalMovement:                ; process horizontal movement now
    
    .checkLeft:
      LDA controllerDown
      AND #CONTROLLER_LEFT
      BEQ .checkLeftDone              ; check if left is pressed
      LDA #DIRECTION_LEFT
      STA playerDirection             ; set player direction to left
      LDA playerAnimation
      CMP #PLAYER_CROUCH
      BEQ .notMovingHorizontally      ; if player is crouching horizontal movement not possible      
      LDA #PLAYER_SPEED_NEGATIVE
      STA playerDX                    ; set DX
      JMP .movingHorizontally         ; player will move vertically
    .checkLeftDone:
    
    .checkRight:
      LDA controllerDown
      AND #CONTROLLER_RIGHT
      BEQ .checkRightDone             ; check if right is pressed
      LDA #DIRECTION_RIGHT
      STA playerDirection             ; set player direction to right
      LDA playerAnimation
      CMP #PLAYER_CROUCH
      BEQ .notMovingHorizontally      ; if player is crouching horizontal movement not possible      
      LDA #PLAYER_SPEED_POSITIVE
      STA playerDX                    ; set DX
      JMP .movingHorizontally         ; player will move vertically
    .checkRightDone:
    
    .notMovingHorizontally:
      LDA playerAnimation             ; if we got here it means player is not moving vertically
      CMP #PLAYER_RUN                 
      BEQ .changeStateToStand
      JMP .horizontalMovementDone
      .changeStateToStand:            ; if player is in the RUN state, replace it with the STAND State
        LDA #PLAYER_STAND
        STA playerAnimation
        JMP .horizontalMovementDone
    
    .movingHorizontally:
      LDA playerAnimation
      CMP #PLAYER_JUMP
      BEQ .checkHorizontalCollision   ; player in the jumping animation, no updates needed
      CMP #PLAYER_STAND
      BEQ .startRunning               ; player is standing and wants to move, start running
      DEC playerCounter
      BNE .checkHorizontalCollision   ; counter is counting down
      LDA #PLAYER_ANIM_SPEED
      STA playerCounter
      DEC playerAnimationFrame
      BNE .checkHorizontalCollision
      LDA #PLAYER_ANIM_FRAMES
      STA playerAnimationFrame
      JMP .checkHorizontalCollision
      
    .startRunning:
      LDA #PLAYER_RUN
      STA playerAnimation
      LDA #PLAYER_ANIM_SPEED
      STA playerCounter
      LDA #PLAYER_ANIM_FRAMES
      STA playerAnimationFrame  
    
    .checkHorizontalCollision:
      JSR CheckCollisionHorizontal
      
    .applyHorizontalMovement:
      LDA playerDX   
      BEQ .horizontalMovementDone     ; no horizontal movement
                                       
      LDA scroll + $01                ; load scroll  high byte
      CMP maxScroll + $01             ; compare with max scroll high byte
      BEQ .highBytesMatch             
                                      
      LDA scroll                      
      BNE .scrollHorizontally         ; high bytes don't match, and low byte isn't 0 - intermediate scroll, continue scrolling
                                      
      LDA scroll + $01                
      BEQ .leftMost                   ; scroll == 0
      JMP .scrollHorizontally         ; high bytes don't match, scroll != 0 - 
                                      
      .highBytesMatch:                
        LDA scroll                    
        CMP maxScroll                 
        BEQ .rightMost                ; scroll == max scroll
        JMP .scrollHorizontally       ; intermediate scroll, continue scrolling
                                      
      .leftMost:                      
        LDA playerX
        CMP #PLAYER_SCREEN_CENTER
        BNE .moveHorizontally         ; player not centered, meaning player is in the left part, move
        LDA playerDX                  
        CMP #$80                      
        BCC .scrollRight              ; carry cleared, playerDX < #$80 -> playerDX > 0 -> scroll right
        JMP .moveHorizontally         ; moving left
                                      
      .rightMost:                     
        LDA playerX
        CMP #PLAYER_SCREEN_CENTER
        BNE .moveHorizontally         ; player not centered, meaning player is in the right part, move      
        LDA playerDX                  
        CMP #$80                      
        BCS .scrollLeft               ; carry set, playerDX >= #$80 -> playerDX < 0 -> scroll left
        JMP .moveHorizontally         ; moving right
                                      
      .moveHorizontally:              
        JSR MovePlayerHorizontally
        JMP .horizontalMovementDone
                                      
      .scrollHorizontally:            ; scrolling assumes horizontal speed will always be 2
        LDA playerDX                  
        CMP #$80                      
        BCC .scrollRight              ; carry cleared, playerDX < #$80 -> playerDX > 0 -> scroll right
                                       
        .scrollLeft:                   
          JSR DecrementScroll          
          LDA #$01
          STA b
          JSR ScrollPlayerBullets          
          JMP .horizontalMovementDone  
          
        .scrollRight:
          JSR IncrementScroll          
          LDA #$00
          STA b
          JSR ScrollPlayerBullets
          
  .horizontalMovementDone: 

  .renderPlayer:
    JSR RenderPlayer
    
  ; todo: spawn bullets here

  .checkIfFallingOffScreen:
    LDA playerY
    CMP #PLAYER_Y_MAX
    BNE .checkThreats
    LDA #PLAYER_FALLING
    STA playerState
    RTS
    
  .checkThreats:
    JSR CheckForThreatCollisions
    LDA collision
    BEQ .updatePlayerDone
    LDA #PLAYER_EXPLODING
    STA playerState
  
  .updatePlayerDone:
    RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdatePlayerFalling                                         ;
;                                                               ;
; Description:                                                  ;
;   Called when player is in the falling down state             ;
;                                                               ;
; Used variables:                                               ;
;   N/I                                                         ;
;****************************************************************

UpdatePlayerFalling:

  .applyGravity:
    LDA #GRAVITY
    STA playerDY
    JSR MovePlayerVertically
    
  .checkPlayerY:
    LDA playerY
    CMP #$40
    BCC .render                   ; if playerY is < 64, keep rendering the player
    CMP #$80
    BCS .render                   ; if playerY is >= 128, keep rendering the player
  
  .playerOffScreen:               ; if we get here it means playerY >= 64 && playerY < 128, meaning player is well off screen
    LDA #PLAYER_DEAD_COOLDOWN
    STA playerCounter
    LDA #PLAYER_NOT_VISIBLE
    STA playerState
    RTS
  
  .render:
    JMP RenderPlayerFalling

;****************************************************************
; Name:                                                         ;
;   UpdatePlayerExploding                                       ;
;                                                               ;
; Description:                                                  ;
;   Called when player is in the exploding state                ;
;                                                               ;
; Used variables:                                               ;
;   todo                                                        ;
;****************************************************************

UpdatePlayerExploding:
  ; todo actually implement this
  LDA #PLAYER_DEAD_COOLDOWN
  STA playerCounter
  LDA #PLAYER_NOT_VISIBLE
  STA playerState
  RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdatePlayerBullets                                         ;
;                                                               ;
; Description:                                                  ;
;   Updates player bullets, includes spawning new ones          ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************
  
UpdatePlayerBullets:
  
;  .moveBullets:
;    LDY #PLAYER_BULLET_LIMIT
;    .moveBulletLoop:      
;      DEY
;      TYA
;      ASL A
;      ASL A     
;      TAX
;                  
;      INX                             ; x points to tile
;      LDA playerBullets, x            ; load bullet tile
;      CMP #CLEAR_SPRITE               
;      BEQ .moveBulletLoopCheck        ; bullet not populated
;                                      
;      DEX                             ; x points to the Y position
;      LDA playerBullets, x            ; load the Y position
;      STA by1                         ; set by1
;      CLC                             
;      ADC #PLAYER_BULLET_HEIGHT       
;      STA by2                         ; set by2
;                                      
;      INX                             
;      INX                             ; x points to atts
;      LDA playerBullets, x            ; load bullet atts      
;      ; AND #%01000000                ; no need for AND as bullets use pallete 0
;      BEQ .bulletFlyingRight          ; not rotated means bullet flying right
;                                      
;      .bulletFlyingLeft:              
;        INX                           ; x points to X position
;        LDA playerBullets, x          ; load bullet X position
;        SEC                           
;        SBC #PLAYER_BULLET_SPEED      
;        BCC .clearBullet              ; clear bullet if goes off screen
;        STA playerBullets, x          ; set new X position
;        JMP .checkCollisions          
;                                      
;      .bulletFlyingRight:             
;        INX                           ; x points to X position
;        LDA playerBullets, x          ; load bullet X position
;        CLC                           
;        ADC #PLAYER_BULLET_SPEED      
;        BCS .clearBullet              ; clear bullet if goes off screen
;        STA playerBullets, x          ; set new X position
;                                      
;      .checkCollisions:               
;        STA bx1                       ; set bx1 (A still contains the new X posistion)
;        CLC
;        ADC #PLAYER_BULLET_WIDTH
;        BCS .clearBullet              ; bullet already partially off screen
;        STA bx2                       ; set bx2
;        STY e                         ; cache Y in e since CheckForAllCollisions updates it        
;        JSR CheckForAllCollisions
;        LDY e                         ; restore Y
;        LDA collision                 ; check if collision detected
;        BEQ .moveBulletLoopCheck      
;        
;      .clearBullet:      
;        DEX                           ; CheckForAllCollisions doesn't affect X so it's OK
;        DEX                           ; x points to tile
;        LDA #CLEAR_SPRITE             
;        STA playerBullets, x          ; clear bullet
;      
;      .moveBulletLoopCheck:
;        TYA
;        BNE .moveBulletLoop    
;  
;  .updateCooldown:
;    LDA playerBulletCooldown
;    BEQ .checkInput
;    DEC playerBulletCooldown
;    RTS
;  
;  .checkInput:
;    LDA controllerPressed
;    AND #CONTROLLER_B
;    BNE .checkIfPlayerOnScreen
;    RTS
;  
;  .checkIfPlayerOnScreen:
;    ; todo: check if player is on screen and can fire
;    
;  .findFreeBulletSlot:
;    LDY #PLAYER_BULLET_LIMIT
;    .findLoop:      
;      DEY
;      TYA
;      ASL A
;      ASL A     
;      TAX      
;      INX                             ; x points to tile
;      LDA playerBullets, x            ; load bullet tile
;      CMP #CLEAR_SPRITE               
;      BEQ freeSlotFound               ; free slot found
;      TYA                             
;      BNE .findLoop                   
;      RTS                             ; no free slots. Exit.
;                                      
;  freeSlotFound:                      ; when we get here X still points to the free bullet slot tile
;    LDA #PLAYER_BULLET_COOLDOWN       
;    STA playerBulletCooldown          ; set cooldown
;    LDA #PLAYER_BULLET_SPRITE         
;    STA playerBullets, x              ; set bullet tile      
;                                      
;  .getYPosition:                      
;    DEX                               ; x points to the Y position
;    LDA playerAnimation                   
;    CMP #PLAYER_CROUCH                
;    BEQ .playerCrouching              
;                                      
;    .playerUp:                        
;      LDA playerY                     
;      CLC                             
;      ADC #PLAYER_GUN_OFF_Y           
;      STA playerBullets, x            ; set the Y position
;      JMP .getXPositionAndAtts        
;                                      
;    .playerCrouching:                 
;      LDA playerY                     
;      CLC                             
;      ADC #PLAYER_GUN_OFF_Y_C         
;      STA playerBullets, x            ; set the X position
;                                      
;  .getXPositionAndAtts:               
;    INX                               
;    INX                               ; x points to atts
;    LDA playerDirection               
;    BEQ .shootLeft                    ; DIRECTION_LEFT = 0
;                                      
;    .shootRight:                      
;      LDA #PLAYER_BULLET_PALETTE      
;      STA playerBullets, x            ; set atts
;      INX                             ; x points to the X position
;      LDA playerX                     
;      CLC                             
;      ADC #PLAYER_GUN_OFF_X_R         
;      STA playerBullets, x            ; set the X position
;      RTS                             
;                                      
;    .shootLeft:                       
;      ; LDA #PLAYER_BULLET_PALETTE    
;      ; ORA #%01000000                
;      LDA #%01000000                  ; can just do this as long as palette == 0
;      STA playerBullets, x            ; set atts
;      INX                             ; x points to the X position
;      LDA playerX                     
;      CLC                             
;      ADC #PLAYER_GUN_OFF_X_L         
;      STA playerBullets, x            ; set the X position
      RTS
    
;****************************************************************
; Name:                                                         ;
;   ScrollPlayerBullets                                         ;
;                                                               ;
; Description:                                                  ;
;   Moves player bullets as part of the scroll                  ;
;                                                               ;
; Input values:                                                 ;
;   b - 0 means we're incementing scroll (move left)            ;
;       1 means we're decementing scroll (move right)           ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;****************************************************************  

ScrollPlayerBullets:

;  .moveBullets:
;    LDY #PLAYER_BULLET_LIMIT
;    .moveBulletLoop:      
;      DEY
;      TYA
;      ASL A
;      ASL A     
;      TAX
;      
;      INX                           ; x points to tile
;      LDA playerBullets, x          ; load bullet tile
;      CMP #CLEAR_SPRITE             
;      BEQ .moveBulletLoopCheck      ; bullet not populated
;                                    
;      INX                           ; x points to atts
;      INX                           ; x points to X position
;                                    
;      LDA b                         
;      BNE .moveRight                
;                                    
;      .moveLeft:                    
;        LDA playerBullets, x        ; load bullet X position
;        SEC                         
;        SBC #PLAYER_SPEED_POSITIVE  
;        BCC .clearBullet            ; clear bullet if goes off screen
;        STA playerBullets, x        ; set new X position
;        JMP .moveBulletLoopCheck    
;                                    
;      .moveRight:                   
;        LDA playerBullets, x        ; load bullet X position
;        CLC                         
;        ADC #PLAYER_SPEED_POSITIVE    
;        BCS .clearBullet            ; clear bullet if goes off screen
;        STA playerBullets, x        ; set new X position
;        JMP .moveBulletLoopCheck    
;                                    
;      .clearBullet:                 
;        DEX                         
;        DEX                         ; x points to tile
;        LDA #CLEAR_SPRITE           
;        STA playerBullets, x        ; clear bullet
;      
;      .moveBulletLoopCheck:
;        TYA
;        BNE .moveBulletLoop  
        RTS

;****************************************************************
; Name:                                                         ;
;   CheckCollisionVertical                                      ;
;                                                               ;
; Description:                                                  ;
;   Check for vertical collisions, updates playerDY             ;
;   collision = 1 set on output if collision detected           ;
;   b = 1 set on output if was going down                       ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************

CheckCollisionVertical:
 
  ; check move direction
  
  LDA #$00
  STA b                               ; b = 0 means moving up, b <> 0 means moving down
                                      
  .directionCheck:                    
    LDA playerDY                      
    ;BEQ .notMoving                   ; not moving at all - commented out, this will never be called with DY == 0
    CMP #$80                          
    BCS .directionCheckDone           ; carry set, playerDY >= #$80 -> playerDY < 0 -> moving up, b stays as 0
    INC b                             ; moving down
    JMP .directionCheckDone    
    .notMoving:
      RTS  
  .directionCheckDone:
  
  ; check bounds
  ; POI - possible optimization - some of these checks may not be required  
  
  .checkBounds:
    LDA b
    BNE .checkBottomBound             ; moving down
                                      
    .checkTopBound:                   
      LDA playerY                     
      CLC                             
      ADC playerDY                    
      BCC .offTop                     ; carry clear means playerY + playerDY < 0 - cap at Y_MIN 
      CMP #PLAYER_Y_MIN               
      BCC .offTop                     ; carry clear means playerY + playerDY < Y_MIN - cap at Y_MIN
      JMP .checkBoundsDone            
      .offTop:                        
        LDA #PLAYER_Y_MIN             
        SEC                           ; set DY to Y_MIN - playerY, i.e. stop at min
        SBC playerY                   
        STA playerDY                  
        INC collision                 ; collision with screen edge
        RTS                           ; can just exit since there is no possibility of collision
    .checkTopBoundDone:               
                                      
    .checkBottomBound:                 
      LDA playerY                     
      CLC                             
      ADC playerDY                    
      CMP #PLAYER_Y_MAX               
      BCC .checkBottomBoundDone       ; carry clear means playerY + playerDY < Y_MAX - continue
      .offBottom:                     
        LDA #PLAYER_Y_MAX             
        SEC                           ; set DY to Y_MAX - playerY, i.e. stop at max
        SBC playerY                   
        STA playerDY                  
        INC collision                 ; collision with screen edge
        RTS                           ; can just exit since there is no possibility of collision
    .checkBottomBoundDone:   
  .checkBoundsDone:

  ; set new player box. POI - possible memory optimization - calculate boxes here instead of storing them in zero page
  
  .setBox:
    LDA playerPlatformBoxX1
    STA bx1
    LDA playerPlatformBoxX2
    STA bx2    
    LDA playerPlatformBoxY1
    CLC
    ADC playerDY
    STA by1
    LDA playerPlatformBoxY2
    CLC
    ADC playerDY
    STA by2  
  .setBoxDone:

  ; check for collisions with platforms

  .checkCollisions:
    .checkFirstScreen:
      LDA #$00
      STA c                           ; c = 0 means check 1st screen
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      LDA collision
      BNE .adjustMovement             ; collision detected
                                      
    .checkSecondScreen:               
      INC c                           ; c = 1 means check 2nd screen
      JSR MovePlatformsPointerForward
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      JSR MovePlatformsPointerBack
      LDA collision
      BNE .adjustMovement             ; collision detected
      RTS                             ; no collision, just exit
  .checkCollisionsDone:

  ; adjust movement if needed
  
  .adjustMovement:   
    LDA b
    BNE .adjustMovingDown
    
    .adjustMovingUp:
      ; dy => boxY1 + dy - 1 = ay2 => dy = ay2 - boxY1 + 1
      LDA ay2
      SEC
      SBC playerPlatformBoxY1
      STA playerDY
      INC playerDY
      RTS
      
    .adjustMovingDown:
      ; dy => boxY2 + dy + 1 = ay1 => dy = ay1 - boxY2 - 1
      LDA ay1
      SEC
      SBC playerPlatformBoxY2
      STA playerDY
      DEC playerDY
      RTS

;****************************************************************
; Name:                                                         ;
;   CheckCollisionHorizontal                                    ;
;                                                               ;
; Description:                                                  ;
;   Check for horizontal collisions, updates playerDX           ;
;   collision = 1 set on output if collision detected           ;
;   b = 1 set on output if was going right                      ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************

CheckCollisionHorizontal:

  ; check move direction

  LDA #$00
  STA b                             ; b = 0 means moving left, b <> 0 means moving right
 
  .directionCheck: 
    LDA playerDX
    ;BEQ .notMoving                 ; not moving at all - commented out, this will never be called with DX == 0
    CMP #$80
    BCS .directionCheckDone         ; carry set, playerDX >= #$80 -> playerDX < 0 -> moving left, b stays as 0
    INC b                           ; moving down
    JMP .directionCheckDone    
    .notMoving:
      RTS  
  .directionCheckDone:
  
  ; check bounds
  ; POI - possible optimization - some of these checks may not be required
  
  .checkBounds:
    LDA b
    BNE .checkRightBound            ; moving right
    
    .checkLeftBound:
      LDA playerX
      CLC
      ADC playerDX
      BCC .offLeft                  ; carry clear means playerX + playerDX < 0 - cap at X_MIN 
      CMP #PLAYER_X_MIN
      BCC .offLeft                  ; carry clear means playerX + playerDX < X_MIN - cap at X_MIN
      JMP .checkBoundsDone
      .offLeft:
        LDA #PLAYER_X_MIN
        SEC                         ; set DX to X_MIN - playerX, i.e. stop at min
        SBC playerX
        STA playerDX       
        RTS                         ; can just exit since there is no possibility of collision
    .checkLeftBoundDone:            
         
    .checkRightBound:               
      LDA playerX
      CLC                           
      ADC playerDX
      BCS .offRight                 ; carry set means playerX + playerDX > 255 - cap at X_MAX
      CMP #PLAYER_X_MAX
      BCC .checkRightBoundDone      ; carry clear means playerX + playerDX < X_MAX - continue
      .offRight:
        LDA #PLAYER_X_MAX
        SEC                         ; set DX to X_MAX - playerX, i.e. stop at max
        SBC playerX
        STA playerDX
        RTS                         ; can just exit since there is no possibility of collision
    .checkRightBoundDone:   
  .checkBoundsDone:
  
  ; set new player box. POI - possible memory optimization - calculate boxes here instead of storing them in zero page
  
  .setBox:
    LDA playerPlatformBoxY1
    STA by1
    LDA playerPlatformBoxY2
    STA by2    
    LDA playerPlatformBoxX1
    CLC
    ADC playerDX
    STA bx1
    LDA playerPlatformBoxX2
    CLC
    ADC playerDX
    STA bx2  
  .setBoxDone:

  ; check for collisions with platforms

  .checkCollisions:
    .checkFirstScreen:
      LDA #$00
      STA c                           ; c = 0 means check 1st screen
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      LDA collision
      BNE .adjustMovement             ; collision detected
                                      
    .checkSecondScreen:               
      INC c                           ; c = 1 means check 2nd screen
      JSR MovePlatformsPointerForward
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      JSR MovePlatformsPointerBack
      LDA collision
      BNE .adjustMovement             ; collision detected
      RTS                             ; no collision, just exit
  .checkCollisionsDone:

  ; adjust movement if needed  
  .adjustMovement:   
    
    ; just zero out the speed, it can stay like that assuming horizontal speed will always be 2
    LDA #$00
    STA playerDX
    RTS
    
    ;LDA b
    ;BNE .adjustMovingRight
    ;
    ;.adjustMovingLeft:
    ;  ; dx => boxX1 + dx - 1 = ax2 => dx = ax2 - boxX1 + 1
    ;  LDA ax2
    ;  SEC
    ;  SBC playerPlatformBoxX1
    ;  STA playerDX
    ;  INC playerDX
    ;  RTS
    ;  
    ;.adjustMovingRight:
    ;  ; dx => boxX2 + dx + 1 = ax1 => dx = ax1 - boxX2 - 1
    ;  LDA ax1
    ;  SEC
    ;  SBC playerPlatformBoxX2
    ;  STA playerDX
    ;  DEC playerDX
    ;  RTS
    
;****************************************************************
; Name:                                                         ;
;   CheckForThreatCollisions                                    ;
;                                                               ;
; Description:                                                  ;
;   Checks for collisions between player and threats            ;
;                                                               ;
; Output variables:                                             ;
;   collision set to 1 means collision has been detected        ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************
  
CheckForThreatCollisions:

  .setBox:
    LDA playerThreatBoxX1
    STA bx1
    LDA playerThreatBoxX2
    STA bx2
    LDA playerThreatBoxY1
    STA by1
    LDA playerThreatBoxY2
    STA by2

  .checkFirstThreatScreen:
    LDA #$00
    STA c
    LDA threatsPointer
    STA genericPointer
    LDA threatsPointer + $01
    STA genericPointer + $01
    JSR CheckForPlatformOneScreen
    LDA collision
    BNE .collisionCheckDone
    
  .checkSecondThreatScreen:
    INC c
    JSR MoveThreatsPointerForward
    LDA threatsPointer
    STA genericPointer
    LDA threatsPointer + $01
    STA genericPointer + $01
    JSR CheckForPlatformOneScreen
    JSR MoveThreatsPointerBack
    
  .collisionCheckDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   MovePlayerHorizontally                                      ;
;                                                               ;
; Description:                                                  ;
;   Moves the player horizontally based on playerDX             ;
;   Updates position, boxes etc.                                ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;****************************************************************

MovePlayerHorizontally:
  
  .applyMovement:
    LDA playerDX
    ;BEQ .noMovement            no need for this check currently
    CLC
    ADC playerX
    STA playerX    
  
  .plaformBoxX:
    LDA playerX
    STA playerPlatformBoxX1
    CLC
    ADC #PLAYER_PLAT_BOX_WIDTH     
    STA playerPlatformBoxX2     ; don't cap X2 since player should never be off screen horizontally
  
  .threatBoxX:
    LDA playerX
    CLC
    ADC #PLAYER_THR_BOX_X_OFF
    STA playerThreatBoxX1
    CLC
    ADC #PLAYER_THR_BOX_WIDTH      
    STA playerThreatBoxX2       ; don't cap here either
    
  .noMovement:
    RTS
  
;****************************************************************
; Name:                                                         ;
;   MovePlayerVertically                                        ;
;                                                               ;
; Description:                                                  ;
;   Moves the player vertically based on playerDY               ;
;   Updates position, boxes etc.                                ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;****************************************************************

MovePlayerVertically:
  
  .applyMovement:
    LDA playerDY
    ;BEQ .noMovement            no need for this check currently
    CLC   
    ADC playerY    
    STA playerY
  
  .plaformBoxY:
    LDA playerY
    STA playerPlatformBoxY2
    SEC
    SBC #PLAYER_PLAT_BOX_HEIGHT
    BCC .capYAtMin
    STA playerPlatformBoxY1
    JMP .threatBoxY
    .capYAtMin:
      LDA #$00
      STA playerPlatformBoxY1
  
  .threatBoxY:
    LDA playerY
    SEC
    SBC #PLAYER_THR_BOX_Y_OFF
    BCC .capBothAtMin
    STA playerThreatBoxY2
    
    LDA playerAnimation
    CMP #PLAYER_CROUCH
    BEQ .crouching
            
    .notCrouching:
      LDA playerThreatBoxY2
      SEC
      SBC #PLAYER_THR_BOX_HEIGHT
      BCC .capY1AtMin
      STA playerThreatBoxY1
      RTS
    
    .crouching:
      LDA playerThreatBoxY2
      SEC
      SBC #PLAYER_THR_BOX_HEIGHT_C
      BCC .capY1AtMin
      STA playerThreatBoxY1
      RTS
    
    .capBothAtMin:
      LDA #$00
      STA playerThreatBoxY1
      STA playerThreatBoxY2      
      RTS
      
    .capY1AtMin:
      LDA #$00
      STA playerThreatBoxY1      
  
  .noMovement:
    RTS   
    
;****************************************************************
; Name:                                                         ;
;   LoadPlayer                                                  ;
;                                                               ;
; Description:                                                  ;
;   Loads player in the standing position.                      ;
;   Sets all variables.                                         ;
;   playerX and playerY should be set on input                  ;
;****************************************************************

LoadPlayer:

  .setBoxes:
    LDA #PLAYER_SPEED_POSITIVE    ; move player by +2 and -2 to set the boxes
    STA playerDX
    STA playerDY
    JSR MovePlayerHorizontally
    JSR MovePlayerVertically
    LDA #PLAYER_SPEED_NEGATIVE
    STA playerDX
    STA playerDY
    JSR MovePlayerHorizontally
    JSR MovePlayerVertically    
  
  .presetState:
    LDA #PLAYER_NORMAL
    STA playerState
    LDA #$00                      
    STA playerJump
    STA playerCounter
    STA playerAnimationFrame      
    LDA #PLAYER_STAND             
    STA playerAnimation    
    LDA #DIRECTION_RIGHT
    STA playerDirection
  
  .renderPlayer:
    JSR RenderPlayer

  RTS
    
;****************************************************************
; Name:                                                         ;
;   RenderPlayer                                                ;
;                                                               ;
; Description:                                                  ;
;   Renders player.                                             ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b ~ i used as pointers                                      ;
;****************************************************************
    
RenderPlayer:
  
  .directionCheck:
    LDA playerDirection
    BEQ .facingLeft               ; DIRECTION_LEFT = 0
        
    .facingRight:   
      LDA #LOW(xOffRight)   
      STA h   
      LDA #HIGH(xOffRight)    
      STA i   
        
      LDA #LOW (attsRight)    
      STA f   
      LDA #HIGH (attsRight)   
      STA g   
      JMP .stateCheck   
        
    .facingLeft:    
      LDA #LOW(xOffLeft)    
      STA h   
      LDA #HIGH(xOffLeft)   
      STA i   
        
      LDA #LOW (attsLeft)   
      STA f   
      LDA #HIGH (attsLeft)    
      STA g   
        
  .stateCheck:    
    LDA playerAnimation   
    CMP #PLAYER_CROUCH    
    BEQ .playerCrouch   
          
    LDA #LOW(yOffNonCrouch)   
    STA b   
    LDA #HIGH(yOffNonCrouch)    
    STA c   
        
    LDA playerAnimation   
    BEQ .playerStand              ; PLAYER_STAND = 0
    CMP #PLAYER_JUMP  
    BEQ .playerJump 
    ;CMP #PLAYER_RUN  
    ;BEQ #PLAYER_RUN  
      
    .playerRun: 
      LDA #LOW(tilesRun)  
      STA d 
      LDA #HIGH(tilesRun) 
      STA e 
        
      LDX playerAnimationFrame    ; X = animation frame             
      DEX                         ; X = animation frame - 1 (so for frame 1 there is no offset etc)
      BEQ .render
      LDA #$00
      .movePointerLoop:
        CLC
        ADC #PLAYER_SPRITES_COUNT
        DEX
        BNE .movePointerLoop      ; after loop A = 9 * (frame - 1)
      CLC                         
      ADC d                       
      STA d                       ; move pointer
      BCC .render                 
      INC e                       ; handle carry
      JMP .render
      
    .playerStand:
      LDA #LOW(tilesStand) 
      STA d 
      LDA #HIGH(tilesStand)  
      STA e 
      JMP .render
    
    .playerJump:
      LDA #LOW(tilesJump) 
      STA d 
      LDA #HIGH(tilesJump)  
      STA e
      JMP .render
    
    .playerCrouch:
      LDA #LOW(yOffCrouch)
      STA b
      LDA #HIGH(yOffCrouch)
      STA c
      
      LDA #LOW(tilesCrouch) 
      STA d 
      LDA #HIGH(tilesCrouch)  
      STA e
      
  .render:
    
    ; once we get here
    ;   b+c points to y off table
    ;   d+e points to tiles table
    ;   f+g points to atts table
    ;   h+i points to x off table
  
    LDY #PLAYER_SPRITES_COUNT
    .renderTileLoop:
      DEY
      LDA [b], y
      CLC
      ADC playerY                 ; yOffs are always negative, so if tile is off screen, e.g. if player Y = 3
      BCC .loopCheck              ; and yOff= -8 (F8), then carry won't be set and tile should be ignored
      STA renderYPos              ; todo - this loopCheck is untested
      LDA [d], y
      STA renderTile
      LDA [f], y
      STA renderAtts
      LDA [h], y
      CLC
      ADC playerX
      STA renderXPos
      JSR RenderSprite
      .loopCheck:
        TYA
        BNE .renderTileLoop
        RTS
        
;****************************************************************
; Name:                                                         ;
;   RenderPlayerFalling                                         ;
;                                                               ;
; Description:                                                  ;
;   Renders player when falling off screen                      ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b ~ i used as pointers                                      ;
;****************************************************************
    
RenderPlayerFalling:
  
  .directionCheck:
    LDA playerDirection
    BEQ .facingLeft               ; DIRECTION_LEFT = 0
        
    .facingRight:   
      LDA #LOW(xOffRight)   
      STA h   
      LDA #HIGH(xOffRight)    
      STA i   
        
      LDA #LOW (attsRight)    
      STA f   
      LDA #HIGH (attsRight)   
      STA g   
      JMP .yAndTiles
        
    .facingLeft:    
      LDA #LOW(xOffLeft)    
      STA h   
      LDA #HIGH(xOffLeft)   
      STA i   
        
      LDA #LOW (attsLeft)   
      STA f   
      LDA #HIGH (attsLeft)    
      STA g   
        
  .yAndTiles:    
    LDA #LOW(yOffNonCrouch)   
    STA b   
    LDA #HIGH(yOffNonCrouch)    
    STA c   
        
    LDA #LOW(tilesJump) 
    STA d 
    LDA #HIGH(tilesJump)  
    STA e
      
  .render:
    
    ; once we get here
    ;   b+c points to y off table
    ;   d+e points to tiles table
    ;   f+g points to atts table
    ;   h+i points to x off table
  
    LDY #PLAYER_SPRITES_COUNT
    .renderTileLoop:
      DEY
      LDA [b], y
      CLC
      ADC playerY                 ; when falling down, we want to ignore tiles that would be rendered on top of the screen
      CMP #$80                    ; compare the tile Y with $80, if it's less then ignore it
      BCC .loopCheck
      STA renderYPos
      LDA [d], y
      STA renderTile
      LDA [f], y
      STA renderAtts
      LDA [h], y
      CLC
      ADC playerX
      STA renderXPos
      JSR RenderSprite
      .loopCheck:
        TYA
        BNE .renderTileLoop
        RTS
    
;****************************************************************
; Name:                                                         ;
;   jumpLookupTable                                             ;
;                                                               ;
; Description:                                                  ;
;   Lookup table with jump DY values                            ;
;****************************************************************

; todo: remove this? replace with something simpler?
;       two counters?

JUMP_FRAMES = $19 ; = 25
JUMP_PEAK = $04   ; =  4
jumpLookupTable:
  .byte $00       ; =  0
  .byte $00       ; =  0
  .byte $00       ; =  0
  .byte $00       ; =  0
  .byte $00       ; =  0  
  .byte $FF       ; = -1
  .byte $FF       ; = -1
  .byte $FF       ; = -1
  .byte $FF       ; = -1
  .byte $FF       ; = -1
  .byte $FE       ; = -2  
  .byte $FE       ; = -2
  .byte $FE       ; = -2
  .byte $FE       ; = -2
  .byte $FE       ; = -2
  .byte $FD       ; = -3
  .byte $FD       ; = -3
  .byte $FD       ; = -3
  .byte $FD       ; = -3
  .byte $FD       ; = -3
  .byte $FC       ; = -4
  .byte $FC       ; = -4
  .byte $FC       ; = -4
  .byte $FC       ; = -4
  .byte $FC       ; = -4
  
;****************************************************************
; Lookup tables generated by the tool below                     ;
; 117 bytes, could be less since there is a lot of duplication  ;
;****************************************************************
  
xOffRight:
  .byte $03, $FB, $03, $0B, $00, $08, $00, $08, $F8
xOffLeft:
  .byte $05, $0D, $05, $FD, $08, $00, $08, $00, $10
yOffNonCrouch:
  .byte $E0, $E8, $E8, $E8, $F0, $F0, $F8, $F8, $F3
yOffCrouch:
  .byte $E8, $F0, $F0, $F0, $F8, $F8, CLEAR_SPRITE, CLEAR_SPRITE, $F8
attsRight:
  .byte $00, $00, $01, $01, $00, $00, $00, $00, $00
attsLeft:
  .byte $40, $40, $41, $41, $40, $40, $40, $40, $40
tilesStand:
  .byte $00, $01, $02, $03, $04, $05, $06, $07, CLEAR_SPRITE ; Stand
tilesJump:
  .byte $00, $01, $02, $03, $04, $08, $09, $0A, CLEAR_SPRITE ; Jump
tilesCrouch:
  .byte $00, $01, $02, $03, $18, $06, CLEAR_SPRITE, CLEAR_SPRITE, $12 ; Crouch
tilesRun:
  .byte $00, $01, $02, $03, $16, $17, $11, $07, $12 ; Run 4
  .byte $00, $01, $02, $03, $13, $14, $15, $0E, CLEAR_SPRITE ; Run 3
  .byte $00, $01, $02, $03, $0F, $10, $11, $07, $12 ; Run 2
  .byte $00, $01, $02, $03, $0B, $0C, $0D, $0E, CLEAR_SPRITE ; Run 1
