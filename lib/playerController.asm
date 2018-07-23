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
;     - updates scroll if needed                                ;
;     - playerPlatformBox, playerCollisionBox                   ;
;     - playerGunX and playerGunY                               ;
;     - playerAnimation                                         ;
;     - spawns bullets                                          ;
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
;   elevator vars                                               ;
;****************************************************************

UpdatePlayerNormal:

  ; process vertical movement first
  .verticalMovement:
    
    ; calculate DY based on either player jumping or gravity
    .calculateDY:       

      ; playerJump != 0 means the player is mid-jump animation, go to .processJump in that case
      .checkJump:
        LDA playerJump
        BNE .processJump
                                      
      ; if not mid-jump, apply gravity, then go to check vertical collision
      .applyGravity:                  
        LDA #GRAVITY                    
        STA genericDY                 
        JMP .checkVerticalCollision        
     
      ; process jump 
      ; (note - remove everything from here up to and including  JMP .lookupJumpDistance to get rid of the 'keep A to jump' mechanic)      
      .processJump:
      
        ; first check if we're at a point where we require A to be pressed to continue the jump (jump var > jump counter)
        CMP #JUMP_PRESS               
        BCS .updateJumpCounter
      
        ; we require A to be pressed, see if it's down.
        ; if it is, process the jump normally
        .jumpCheckA:
          LDA controllerDown
          AND #CONTROLLER_A 
          BNE .updateJumpCounter
          
          ; A is no longer pressed.
          ; if player jump is past (<=) the slowdown, continue normally.
          ; otherwise, move the jump to the slowdown point.
          .jumpANotDown:
            LDA playerJump
            CMP #JUMP_SLOWDOWN + $01
            BCC .updateJumpCounter
            LDA #JUMP_SLOWDOWN
            STA playerJump
            JMP .lookupJumpDistance
        
        ; we get here when jump is processed naturally.
        ; decrement the jump counter.
        .updateJumpCounter:
          DEC playerJump
          
        ; we get here when the jump counter has been updated (via any way).
        ; lookup the distance. 0, player is suspended mid air, no more checks required.
        ; otherwise, set genericDY.
        .lookupJumpDistance:
          LDX playerJump              
          LDA jumpLookupTable, x      
          BEQ .playerMidAir ; todo remove this
          STA genericDY
                                    
    ; we get here when DY is set to something.
    ; check for vertical collision - this will update genericDY and set collision and b (b = 1 means was going down).
    ; apply movement (with updated DY), and then, if collision was detected, go process the collision.
    .checkVerticalCollision:
      JSR CheckCollisionVertical
      JSR MovePlayerVertically
      LDA collision 
      BNE .processCollision
      
    ; we get here when no vertical collision was found - that means player is mid-air, set the animation to JUMP.
    .playerMidAir:
      LDA #PLAYER_JUMP
      STA playerAnimation
      JMP .verticalMovementDone       
        
    ; we get here when vertical collision was detected. Check if it was going up or going down.
    .processCollision:  
      LDA b 
      BNE .collisionGoingDown
        
      ; collision was when going up, cancel the jump (set to peak) and exit.
      .collisionGoingUp:  
        LDA #JUMP_PEAK
        STA playerJump
        LDA #PLAYER_JUMP
        STA playerAnimation
        JMP .verticalMovementDone
        
      ; collision going down, cancel jump.
      ; player is on the ground now, can either jump or crouch
      .collisionGoingDown:
        LDA #$00  
        STA playerJump
        
      ; check if player wants to jump, update jump var and animation if yes.
      .checkA:  
        LDA controllerPressed
        AND #CONTROLLER_A 
        BEQ .checkADone
        LDA #JUMP_FRAMES
        STA playerJump
        LDA #PLAYER_JUMP
        STA playerAnimation
        JMP .verticalMovementDone
      .checkADone:
      
      ; check if player wants to crouch, update animation if yes
      ; also set DY to 0 and 'move' player to update the threat box.
      .checkDown:  
        LDA controllerDown 
        AND #CONTROLLER_DOWN
        BEQ .checkDownDone
        LDA #PLAYER_CROUCH
        STA playerAnimation
        LDA #$00
        STA genericDY
        JSR MovePlayerVertically
        JMP .verticalMovementDone
      .checkDownDone:
      
      ; no jump or crouch input.
      ; if state is RUN leave it as so, otherwise set to STAND.
      .noInput:
        LDA playerAnimation
        CMP #PLAYER_RUN
        BEQ .verticalMovementDone
        LDA #PLAYER_STAND
        STA playerAnimation
  
  ; vertical movement has now been processed.
  .verticalMovementDone:
     
  ; process horizontal movement now
  .horizontalMovement:
    
    ; check if left is pressed, if yes update player's direction and - if not crouching - set DX.
    .checkLeft:
      LDA controllerDown
      AND #CONTROLLER_LEFT
      BEQ .checkLeftDone
      LDA #DIRECTION_LEFT
      STA playerDirection
      LDA playerAnimation
      CMP #PLAYER_CROUCH
      BEQ .notMovingHorizontally
      LDA #PLAYER_SPEED_NEGATIVE
      STA genericDX
      JMP .movingHorizontally
    .checkLeftDone:
    
    ; check if right is pressed, if yes update player's direction and - if not crouching - set DX.
    .checkRight:
      LDA controllerDown
      AND #CONTROLLER_RIGHT
      BEQ .checkRightDone
      LDA #DIRECTION_RIGHT
      STA playerDirection
      LDA playerAnimation
      CMP #PLAYER_CROUCH
      BEQ .notMovingHorizontally
      LDA #PLAYER_SPEED_POSITIVE
      STA genericDX
      JMP .movingHorizontally
    .checkRightDone:
    
    ; if we get here it means player is not moving vertically.
    ; if player is in the RUN state, replace it with the STAND State, and exit.
    .notMovingHorizontally:
      LDA playerAnimation
      CMP #PLAYER_RUN                 
      BEQ .changeStateToStand
      JMP .horizontalMovementDone
      .changeStateToStand:
        LDA #PLAYER_STAND
        STA playerAnimation
        JMP .horizontalMovementDone
    
    ; if we get here it means player is moving vertically.
    ; first update the animation:
    ;   - if player in the JUMP animation, no updates needed
    ;   - if player is in the STAND animation, change to RUN
    ;   - if player is in the RUN animation, update the animation 
    .movingHorizontally:
      LDA playerAnimation
      CMP #PLAYER_JUMP
      BEQ .checkHorizontalCollision
      CMP #PLAYER_STAND
      BEQ .startRunning
      DEC playerCounter
      BNE .checkHorizontalCollision
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
    
    ; animation has been updated, now check for a horizontal collision. 
    ; this updates DX. it may have been updated to 0, just exit in that case.
    .checkHorizontalCollision:
      JSR CheckCollisionHorizontal
      LDA genericDX   
      BEQ .horizontalMovementDone
    
    ; now apply the movement after collision checks.
    ; depending on the player's position and scroll we want to either move the player or scroll the screen.
    .applyHorizontalMovement:          
                                      
      ; load scroll high byte, compare with max scroll high byte
      LDA scroll + $01                
      CMP maxScroll + $01
      BEQ .highBytesMatch             
                         
      ; high bytes don't match.
      ; check if low byte isn't 0 - in that case we should scroll
      LDA scroll                      
      BNE .scrollHorizontally
                                      
      ; high bytes don't match, low byte is 0.
      ; check if high byte is 0, in that case we're on the left end.
      ; otherwise we should scroll.
      LDA scroll + $01                
      BEQ .leftMost
      JMP .scrollHorizontally

      ; high bytes match, check if scroll == max scroll - in that case we're at the right end.
      ; otherwise we should scroll.
      .highBytesMatch:                
        LDA scroll
        CMP maxScroll
        BEQ .rightMost
        JMP .scrollHorizontally

      ; we're on the left most screen.
      ; check if player is on the left side of the screen (position != screen center). in such case, move the player.
      ; otherwise, check which direction player is going - if going right, scroll, otherwise move.
      .leftMost:                      
        LDA playerX
        CMP #PLAYER_SCREEN_CENTER
        BNE .moveHorizontally
        LDA genericDX                  
        CMP #$80                      
        BCC .scrollRight
        JMP .moveHorizontally
                             
      ; we're on the right most screen.
      ; check if player is on the right side of the screen (position != screen center). in such case, move the player.
      ; otherwise, check which direction player is going - if going left, scroll, otherwise move.
      .rightMost:                     
        LDA playerX
        CMP #PLAYER_SCREEN_CENTER
        BNE .moveHorizontally
        LDA genericDX                  
        CMP #$80                      
        BCS .scrollLeft
        JMP .moveHorizontally
                             
      ; if we get here it means we want to move the player.
      .moveHorizontally:              
        JSR MovePlayerHorizontally
        JMP .horizontalMovementDone
                        
      ; if we get here it means we want to scroll the screen.
      ; check which direction player is going, and scroll.
      ; note - we only check if DX > 0 or < 0 - we don't look at the actual values
      ; (we expect scroll to be constant always, and scroll speed to == player speed)
      .scrollHorizontally:
        LDA genericDX                  
        CMP #$80                      
        BCC .scrollRight
                                       
        .scrollLeft:                   
          JSR DecrementScroll          
          LDA #$01
          STA b
          JSR ScrollBullets          
          JMP .horizontalMovementDone  
          
        .scrollRight:
          JSR IncrementScroll          
          LDA #$00
          STA b
          JSR ScrollBullets
          
  ; horizontal movement has now been processed.
  .horizontalMovementDone: 

  ; we can render the player now.
  ; todo - move this somewhere else? later in the frame?
  .renderPlayer:
    JSR RenderPlayer

  ; the player has been moved, check if player is falling off screen, change the state in that case.
  .checkIfFallingOffScreen:
    LDA playerY
    CMP #PLAYER_Y_MAX
    BNE .checkThreats
    LDA #PLAYER_FALLING
    STA playerState
    RTS
    
  ; check for collisions with threats, explode player if any detected.
  .checkThreats:
    JSR CheckForThreatCollisions
    LDA collision
    BEQ .updatePlayerDone
    JMP ExplodePlayer
  
  ; updates done
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
    STA genericDY
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
;   N/I                                                         ;
;****************************************************************

UpdatePlayerExploding:
  
  .updateTimer:
    DEC playerCounter
    BNE .renderExplosion
  
  .updateFrame:
    LDA #EXPLOSION_ANIM_SPEED
    STA playerCounter
    DEC playerAnimationFrame
    BNE .renderExplosion
    
  .animationEnded:  
    LDA #PLAYER_DEAD_COOLDOWN
    STA playerCounter
    LDA #PLAYER_NOT_VISIBLE
    STA playerState
    RTS
    
  .renderExplosion:
    LDA playerX
    STA genericX
    LDA playerY
    SEC
    SBC #PLAYER_EXPL_Y_OFF
    STA genericY
    LDA playerAnimationFrame
    STA genericFrame
    LDA #$00
    STA genericOffScreen
    JMP RenderExplosion
  
;****************************************************************
; Name:                                                         ;
;   ExplodePlayer                                               ;
;                                                               ;
; Description:                                                  ;
;   Puts the player in the exploding state and sets all timers  ;
;                                                               ;
; Used variables:                                               ;
;   N/I                                                         ;
;****************************************************************

ExplodePlayer:
  LDA #PLAYER_EXPLODING
  STA playerState
  LDA #EXPLOSION_ANIM_FRAMES
  STA playerAnimationFrame
  LDA #EXPLOSION_ANIM_SPEED
  STA playerCounter
  RTS   

;****************************************************************
; Name:                                                         ;
;   SpawnPlayerBullets                                          ;
;                                                               ;
; Description:                                                  ;
;   Checks if player can/wants to fire, spawns a bullet at      ;
;   current position if that's the case                         ;
;                                                               ;
; Used variables:                                               ;
;   N/I                                                         ;
;****************************************************************

SpawnPlayerBullets:  

  LDA playerBulletCooldown
  BEQ .checkB
  DEC playerBulletCooldown
  RTS
    
  .checkB:
    LDA controllerPressed
    AND #CONTROLLER_B 
    BEQ .return
    JMP SpawnPlayerBullet

  .return:
    RTS
  
;****************************************************************
; Name:                                                         ;
;   CheckCollisionVertical                                      ;
;                                                               ;
; Description:                                                  ;
;   Check for vertical collisions, updates genericDY            ;
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
    LDA genericDY                      
    ;BEQ .notMoving                   ; not moving at all - commented out, this will never be called with DY == 0
    CMP #$80                          
    BCS .directionCheckDone           ; carry set, genericDY >= #$80 -> genericDY < 0 -> moving up, b stays as 0
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
      ADC genericDY                    
      BCC .offTop                     ; carry clear means playerY + genericDY < 0 - cap at Y_MIN 
      CMP #PLAYER_Y_MIN               
      BCC .offTop                     ; carry clear means playerY + genericDY < Y_MIN - cap at Y_MIN
      JMP .checkBoundsDone            
      .offTop:                        
        LDA #PLAYER_Y_MIN             
        SEC                           ; set DY to Y_MIN - playerY, i.e. stop at min
        SBC playerY                   
        STA genericDY                  
        INC collision                 ; collision with screen edge
        RTS                           ; can just exit since there is no possibility of collision
    .checkTopBoundDone:               
                                      
    .checkBottomBound:                 
      LDA playerY                     
      CLC                             
      ADC genericDY                    
      CMP #PLAYER_Y_MAX               
      BCC .checkBottomBoundDone       ; carry clear means playerY + genericDY < Y_MAX - continue
      .offBottom:                     
        LDA #PLAYER_Y_MAX             
        SEC                           ; set DY to Y_MAX - playerY, i.e. stop at max
        SBC playerY                   
        STA genericDY                  
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
    ADC genericDY
    STA by1
    LDA playerPlatformBoxY2
    CLC
    ADC genericDY
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
      STA genericDY
      INC genericDY
      RTS
      
    .adjustMovingDown:
      ; dy => boxY2 + dy + 1 = ay1 => dy = ay1 - boxY2 - 1
      LDA ay1
      SEC
      SBC playerPlatformBoxY2
      STA genericDY
      DEC genericDY
      RTS

;****************************************************************
; Name:                                                         ;
;   CheckCollisionHorizontal                                    ;
;                                                               ;
; Description:                                                  ;
;   Check for horizontal collisions, updates genericDX          ;
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
    LDA genericDX
    ;BEQ .notMoving                 ; not moving at all - commented out, this will never be called with DX == 0
    CMP #$80
    BCS .directionCheckDone         ; carry set, genericDX >= #$80 -> genericDX < 0 -> moving left, b stays as 0
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
      ADC genericDX
      BCC .offLeft                  ; carry clear means playerX + genericDX < 0 - cap at X_MIN 
      CMP #PLAYER_X_MIN
      BCC .offLeft                  ; carry clear means playerX + genericDX < X_MIN - cap at X_MIN
      JMP .checkBoundsDone
      .offLeft:
        LDA #PLAYER_X_MIN
        SEC                         ; set DX to X_MIN - playerX, i.e. stop at min
        SBC playerX
        STA genericDX       
        RTS                         ; can just exit since there is no possibility of collision
    .checkLeftBoundDone:            
         
    .checkRightBound:               
      LDA playerX
      CLC                           
      ADC genericDX
      BCS .offRight                 ; carry set means playerX + genericDX > 255 - cap at X_MAX
      CMP #PLAYER_X_MAX
      BCC .checkRightBoundDone      ; carry clear means playerX + genericDX < X_MAX - continue
      .offRight:
        LDA #PLAYER_X_MAX
        SEC                         ; set DX to X_MAX - playerX, i.e. stop at max
        SBC playerX
        STA genericDX
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
    ADC genericDX
    STA bx1
    LDA playerPlatformBoxX2
    CLC
    ADC genericDX
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
    STA genericDX
    RTS
    
    ;LDA b
    ;BNE .adjustMovingRight
    ;
    ;.adjustMovingLeft:
    ;  ; dx => boxX1 + dx - 1 = ax2 => dx = ax2 - boxX1 + 1
    ;  LDA ax2
    ;  SEC
    ;  SBC playerPlatformBoxX1
    ;  STA genericDX
    ;  INC genericDX
    ;  RTS
    ;  
    ;.adjustMovingRight:
    ;  ; dx => boxX2 + dx + 1 = ax1 => dx = ax1 - boxX2 - 1
    ;  LDA ax1
    ;  SEC
    ;  SBC playerPlatformBoxX2
    ;  STA genericDX
    ;  DEC genericDX
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
;   Moves the player horizontally based on genericDX            ;
;   Updates position, boxes etc.                                ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;****************************************************************

MovePlayerHorizontally:
  
  .applyMovement:
    LDA genericDX
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
;   Moves the player vertically based on genericDY              ;
;   Updates position, boxes etc.                                ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;****************************************************************

MovePlayerVertically:
  
  .applyMovement:
    LDA genericDY
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
    STA genericDX
    STA genericDY
    JSR MovePlayerHorizontally
    JSR MovePlayerVertically
    LDA #PLAYER_SPEED_NEGATIVE
    STA genericDX
    STA genericDY
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
      LDA #LOW(playerXOffRight)   
      STA h   
      LDA #HIGH(playerXOffRight)    
      STA i   
        
      LDA #LOW (playerAttsRight)    
      STA f   
      LDA #HIGH (playerAttsRight)   
      STA g   
      JMP .stateCheck   
        
    .facingLeft:    
      LDA #LOW(playerXOffLeft)    
      STA h   
      LDA #HIGH(playerXOffLeft)   
      STA i   
        
      LDA #LOW (playerAttsLeft)   
      STA f   
      LDA #HIGH (playerAttsLeft)    
      STA g   
        
  .stateCheck:    
    LDA playerAnimation   
    CMP #PLAYER_CROUCH    
    BEQ .playerCrouch   
          
    LDA #LOW(playerYOffNonCrouch)   
    STA b   
    LDA #HIGH(playerYOffNonCrouch)    
    STA c   
        
    LDA playerAnimation   
    BEQ .playerStand              ; PLAYER_STAND = 0
    CMP #PLAYER_JUMP  
    BEQ .playerJump 
    ;CMP #PLAYER_RUN  
    ;BEQ #PLAYER_RUN  
      
    .playerRun: 
      LDA #LOW(playerTilesRun)  
      STA d 
      LDA #HIGH(playerTilesRun) 
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
      LDA #LOW(playerTilesStand) 
      STA d 
      LDA #HIGH(playerTilesStand)  
      STA e 
      JMP .render
    
    .playerJump:
      LDA #LOW(playerTilesJump) 
      STA d 
      LDA #HIGH(playerTilesJump)  
      STA e
      JMP .render
    
    .playerCrouch:
      LDA #LOW(playerYOffCrouch)
      STA b
      LDA #HIGH(playerYOffCrouch)
      STA c
      
      LDA #LOW(playerTilesCrouch) 
      STA d 
      LDA #HIGH(playerTilesCrouch)  
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
      LDA #LOW(playerXOffRight)   
      STA h   
      LDA #HIGH(playerXOffRight)    
      STA i   
        
      LDA #LOW (playerAttsRight)    
      STA f   
      LDA #HIGH (playerAttsRight)   
      STA g   
      JMP .yAndTiles
        
    .facingLeft:    
      LDA #LOW(playerXOffLeft)    
      STA h   
      LDA #HIGH(playerXOffLeft)   
      STA i   
        
      LDA #LOW (playerAttsLeft)   
      STA f   
      LDA #HIGH (playerAttsLeft)    
      STA g   
        
  .yAndTiles:    
    LDA #LOW(playerYOffNonCrouch)   
    STA b   
    LDA #HIGH(playerYOffNonCrouch)    
    STA c   
        
    LDA #LOW(playerTilesJump) 
    STA d 
    LDA #HIGH(playerTilesJump)  
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

JUMP_PEAK = $04       ; =  4, if a platform is hit going up, go to this point in the jump
JUMP_SLOWDOWN = $08   ; =  8, id A is not down, go to this point in the jump (unless already there)
JUMP_PRESS = $16      ; = 22, require A to be pressed when jump counter < this

JUMP_FRAMES = $19     ; = 25, number of 'jump frames'
jumpLookupTable:      ;       start with this number then go down
  .byte $00           ; =  0
  .byte $00           ; =  0
  .byte $00           ; =  0
  .byte $00           ; =  0
  .byte $00           ; =  0  
  .byte $FF           ; = -1
  .byte $FF           ; = -1
  .byte $FF           ; = -1
  .byte $FF           ; = -1
  .byte $FF           ; = -1
  .byte $FE           ; = -2  
  .byte $FE           ; = -2
  .byte $FE           ; = -2
  .byte $FE           ; = -2
  .byte $FE           ; = -2
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  
;****************************************************************
; Lookup tables generated by the tool below                     ;
; 117 bytes, could be less since there is a lot of duplication  ;
;****************************************************************
  
playerXOffRight:
  .byte $03, $FB, $03, $0B, $00, $08, $00, $08, $F8
playerXOffLeft:
  .byte $05, $0D, $05, $FD, $08, $00, $08, $00, $10
playerYOffNonCrouch:
  .byte $E1, $E9, $E9, $E9, $F1, $F1, $F9, $F9, $F4
playerYOffCrouch:
  .byte $E9, $F1, $F1, $F1, $F9, $F9, CLEAR_SPRITE, CLEAR_SPRITE, $F9
playerAttsRight:
  .byte $00, $00, $01, $01, $00, $00, $00, $00, $00
playerAttsLeft:
  .byte $40, $40, $41, $41, $40, $40, $40, $40, $40
playerTilesStand:
  .byte $00, $01, $02, $03, $04, $05, $06, $07, CLEAR_SPRITE ; Stand
playerTilesJump:
  .byte $00, $01, $02, $03, $04, $08, $09, $0A, CLEAR_SPRITE ; Jump
playerTilesCrouch:
  .byte $00, $01, $02, $03, $18, $06, CLEAR_SPRITE, CLEAR_SPRITE, $12 ; Crouch
playerTilesRun:
  .byte $00, $01, $02, $03, $16, $17, $11, $07, $12 ; Run 4
  .byte $00, $01, $02, $03, $13, $14, $15, $0E, CLEAR_SPRITE ; Run 3
  .byte $00, $01, $02, $03, $0F, $10, $11, $07, $12 ; Run 2
  .byte $00, $01, $02, $03, $0B, $0C, $0D, $0E, CLEAR_SPRITE ; Run 1

