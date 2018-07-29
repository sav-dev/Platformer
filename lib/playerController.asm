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
  BEQ .counterAt0
  RTS
  
  .counterAt0:
    LDA levelBeaten
    BEQ .resetLevel
  
  .nextLevel:
    ; todo - this is temporary (going immediately to the next level)
    INC currentLevel
    LDA currentLevel
    CMP #NUMBER_OF_LEVELS
    BNE .resetLevel
    LDA #$00
    STA currentLevel
  
  .resetLevel:
    JSR WaitForFrame
    JSR FadeOut
    LDX #PLAYER_NOT_V_FADED_OUT
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
    
    ; first check if player is riding on an elevator.
    ; in such case, no collision checks are needed, just go to collisionGoingDown
    .checkIfPlayerOnElevator:
      LDA playerOnElevator
      BNE .collisionGoingDown
    
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
      ; note - remove everything from here up to and including
      ; JMP .lookupJumpDistance to get rid of the 'keep A to jump' mechanic)      
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
        ; lookup the distance, set genericDY and go check for collisions.        
        .lookupJumpDistance:
          LDX playerJump              
          LDA jumpLookupTable, x          
          STA genericDY
                                    
    ; check for vertical collision - this will update genericDY and set collision and b (b = 1 means player is not standing on something).
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
       LDA #$00
       STA playerJump
       LDA #PLAYER_JUMP
       STA playerAnimation
       JMP .verticalMovementDone
       
     ; collision going down, cancel jump.
     ; player is on the ground now, can either jump or crouch
     .collisionGoingDown:
       LDA #$00  
       STA playerJump

      ; if we get here it means the player is either on a platform or an elevator.
      .playerOnTheGround:
      
        ; check if player wants to jump, update jump var and animation if yes.
        ; also by jumping player gets off a platform.
        .checkA:  
          LDA controllerPressed
          AND #CONTROLLER_A 
          BEQ .checkADone
          LDA #JUMP_FRAMES
          STA playerJump
          LDA #PLAYER_JUMP
          STA playerAnimation
          LDA #$00
          STA playerOnElevator
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
                    
      ; POI - possible issue - this doesn't work if level is shorter than two screens
                    
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

  ; now that player has been moved, check if the player is still on an elevator and clear the flag if not
  ; if player is not on an elevator, just skip.
  ; otherwise, set the 'b' boxes to player platform box, but increment by2 by 1 to check for collision.
  ; then check for collision with the elevator the player was on, if none found clear the flag.
  ; POI - possible optimization - are the 'b' boxes still set from before?
  .checkIfPlayerStillOnElevator:
    LDA playerOnElevator
    BEQ .renderPlayer
    LDA playerPlatformBoxX1
    STA bx1
    LDA playerPlatformBoxX2
    STA bx2
    LDA playerPlatformBoxY1
    STA by1
    LDA playerPlatformBoxY2
    STA by2
    INC by2    
    LDA #$00
    STA collision
    LDY playerElevatorId
    JSR SingleElevatorCollision
    LDA collision
    BNE .renderPlayer
    LDA #$00
    STA playerOnElevator
  
  ; we can render the player now.
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
    BEQ .checkExit
    JMP ExplodePlayer
  
  ; check if player wants to exit the stage and whether is at the exit.
  .checkExit:
    LDA controllerPressed
    AND #CONTROLLER_UP
    BNE .doCheckExit
    RTS
    .doCheckExit:
      JMP CheckExit      
  
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
    LDA #PLAYER_NOT_V_COOLDOWN
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
    LDA #PLAYER_NOT_V_COOLDOWN
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
;   CheckExit                                                   ;
;                                                               ;
; Description:                                                  ;
;   Check whether up is pressed and if player is at the exit    ;
;                                                               ;
; Used variables:                                               ;
;   ax1                                                         ;
;   ax2                                                         ;
;****************************************************************
  
CheckExit:

  ; first check if player's Y is correct.
  ; check whether:
  ;   - playerY1 >= exitY1
  ;     - i.e. CMP playerY1 to exitY1
  ;     - carry clear means playerY1 < exitY1 - exit in that case
  ;   - playerY2 <= exitY2
  ;     - but we add 1 to exitY2 ahead of time, so check playerY2 < exitY2
  ;     - i.e CMP playerY2 to exitY2
  ;     - carry set means exitY2 >= playerY2 - exit in that case
  .checkY:
    LDA playerPlatformBoxY1
    CMP levelExitY1
    BCC .playerNotAtExit
    CMP levelExitY2
    BCS .playerNotAtExit
    
  ; now check if player's X is correct.
  ; first we must transpose exit X.
  ; check the screen.
  .transposeX:
    LDA levelExitScreen
    CMP scroll + $01
    BEQ .currentScreen
    SEC
    SBC #$01
    CMP scroll + $01
    BNE .playerNotAtExit ; not current screen nor the next screen
    
    ; exit is on the next screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;   - first calculate A = 255 - scroll + 1. If this overflows, it means scroll = 0, i.e. exit is off screen
    ;   - then calculate A = A + x. Again, overflow means exit off screen
    ;   - if exit off screen, player not at exit. Otherwise, store the result in ax1
    .nextScreen:
      LDA #SCREEN_WIDTH
      SEC
      SBC scroll
      CLC
      ADC #$01
      BCS .playerNotAtExit
      ADC levelExitX
      BCS .playerNotAtExit
      STA ax1
      JMP .playerExitX1Set
    
    ; exit is on the current screen. Transpose logic:
    ;   - x' = x - low byte of scroll
    ;   - if x' < 0 (carry cleared after the subtraction), it means exit is partially of screen.
    ;     no need to check anything then - player cannot be at the exit in that case.
    .currentScreen:
      LDA levelExitX
      SEC
      SBC scroll
      BCC .playerNotAtExit
      STA ax1
    
    ; ax1 has been set, not calculate ax2 by adding exit width.
    ; if it overflows it means player not at exit.
    ; also ax1 is loaded when we get here so no need to load.
    .playerExitX1Set:
      CLC
      ADC #EXIT_WIDTH
      BCS .playerNotAtExit
      STA ax2
      
  ; now check if player's X is correct.
  ; check whether:
  ;   - playerX1 >= exitX1
  ;     - i.e. CMP playerX1 to exitX1
  ;     - carry clear means playerX1 < exitX1 - exit in that case
  ;   - playerX2 <= exitX2
  ;     - but we add 1 to exitX2 ahead of time, so check playerX2 < exitX2
  ;     - i.e CMP playerX2 to exitX2
  ;     - carry set means exitX2 >= playerX2 - exit in that case
  .checkX:
    LDA playerPlatformBoxX1
    CMP ax1
    BCC .playerNotAtExit
    CMP ax2
    BCS .playerNotAtExit
    
  ; if we get here, it means player is at exit.
  ; change the state to not visible, and INC levelBeaten
  .playerAtExit:
    LDA #PLAYER_NOT_V_COOLDOWN
    STA playerCounter
    LDA #PLAYER_NOT_VISIBLE
    STA playerState
    INC levelBeaten
    
  .playerNotAtExit:
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
;   b = 1 set on output if player is now standing on something  ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   yPointerCache                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   enemyScreen                                                 ;
;   elevatorSize                                                ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************

CheckCollisionVertical:
 
  ; check move direction, set b to 0 (static or up) or 1 (down).
  ; if player is not moving, skip the bounds check and go straight to .setBox
  .directionCheck:
    LDA #$00
    STA b                                                                     
    LDA genericDY
    BEQ .setBox
    CMP #$80                          
    BCS .directionCheckDone
    INC b
  .directionCheckDone:
  
  ; check if after the movement player will be in screen bounds
  .checkBounds:
    LDA b
    BNE .checkBottomBound
                         
    ; check top screen bound.
    ; carry clear after adding means playerY + genericDY < 0 - cap at Y_MIN 
    ; then compare to Y_MIN, again carry clear means playerY + genericDY < Y_MIN - cap at Y_MIN
    ; in either case cap and just exit
    ; note - important - never put elevators high enough that this could be an issue
    ; (POI - possible issue with elevators)
    .checkTopBound:                   
      LDA playerY                     
      CLC                             
      ADC genericDY                    
      BCC .offTop
      CMP #PLAYER_Y_MIN               
      BCC .offTop
      JMP .checkBoundsDone            
      .offTop:                        
        LDA #PLAYER_Y_MIN             
        SEC
        SBC playerY                   
        STA genericDY                  
        INC collision
        RTS
    .checkTopBoundDone:               

    ; check bottom screen bound.
    ; carry clear after adding means playerY + genericDY < Y_MAX - continue
    ; otherwise cap at max and just exit
    ; note - important - never put elevators low enough that this could be an issue
    ; (POI - possible issue with elevators)
    .checkBottomBound:
      LDA playerY                     
      CLC                             
      ADC genericDY                    
      CMP #PLAYER_Y_MAX               
      BCC .checkBottomBoundDone
      .offBottom:                     
        LDA #PLAYER_Y_MAX             
        SEC
        SBC playerY                   
        STA genericDY                  
        INC collision
        RTS
    .checkBottomBoundDone:   
  .checkBoundsDone:

  ; set new player box.
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

  ; check for collisions with platforms first to avoid issue where a player is standing on the ground
  ; and hit by en elevator from the top (POI - possible optimization - this can be changed back if it's guaranteed
  ; that scenario will never happen)
  ;
  ; first check if player is moving - if no, we can skip this (go to .checkCollisionsWithElevators).
  ; 
  ; check first screen first (c == 0), then second screen (c == 1) if no collisions found.
  ; if any collisions found, go to adjustMovement. Otherwise go to .checkCollisionsWithElevators
  .checkCollisionsWithPlatforms:
    
    .checkPlayerDY:
      LDA genericDY
      BEQ .checkCollisionsWithElevators
  
    .checkFirstScreen:
      LDA #$00
      STA c
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      LDA collision
      BNE .adjustMovement
                                      
    .checkSecondScreen:               
      INC c
      JSR MovePlatformsPointerForward
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      JSR MovePlatformsPointerBack
      LDA collision
      BNE .adjustMovement
      JMP .checkCollisionsWithElevators
      
  .checkCollisionsWithPlatformsDone:

  ; collision has been detected, adjust movement. 
  ; do not check collisions with elevators.
  ; POI - possible issue - this will be a possible issue if either gravity or a step in player's jump
  ; will be greater than elevator's height, and elevator will come as close to a platform as possible.
  ; make sure that's never the case.
  .adjustMovement:
    LDA b
    BNE .adjustMovingDown
    
    ; dy => boxY1 + dy - 1 = ay2 => dy = ay2 - boxY1 + 1
    .adjustMovingUp:      
      LDA ay2
      SEC
      SBC playerPlatformBoxY1
      STA genericDY
      INC genericDY
      RTS
      
    ; dy => boxY2 + dy + 1 = ay1 => dy = ay1 - boxY2 - 1
    .adjustMovingDown:      
      LDA ay1
      SEC
      SBC playerPlatformBoxY2
      STA genericDY
      DEC genericDY
      RTS
  
  ; now check for collisions with elevators.
  ; if collision found, go handle it. otherwise exit.
  .checkCollisionsWithElevators:
    JSR CheckForElevatorCollision
    LDA collision
    BNE .processElevatorVerticalColl
    RTS
    
  ; POI - possible optimization - don't have a separate subroutine?
  .processElevatorVerticalColl:
    JMP ProcessElevatorVerticalColl

;****************************************************************
; Name:                                                         ;
;   CheckCollisionHorizontal                                    ;
;                                                               ;
; Description:                                                  ;
;   Check for horizontal collisions, updates genericDX          ;
;   collision = 1 set on output if collision detected           ;
;   b = 1 set on output if player was going right, 0 if left    ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   yPointerCache                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   enemyScreen                                                 ;
;   elevatorSize                                                ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************

CheckCollisionHorizontal:

  ; check move direction, set b to 0 (left) or 1 (right).
  ; if player is not moving, skip the bounds check and go straight to .setBox
  .directionCheck: 
    LDA #$00
    STA b
    LDA genericDX
    BEQ .setBox
    CMP #$80
    BCS .directionCheckDone
    INC b
  .directionCheckDone:
  
  ; check if after the movement player will be in screen bounds
  .checkBounds:
    LDA b
    BNE .checkRightBound
    
    ; check left screen bound.
    ; carry clear after adding means playerX + genericDX < 0 - cap at X_MIN 
    ; then compare to Y_MIN, again carry clear means playerX + genericDX < X_MIN - cap at X_MIN
    ; in either case cap and just exit
    ; note - important - never put elevators left enough that this could be an issue
    ; (POI - possible issue with elevators)
    .checkLeftBound:
      LDA playerX
      CLC
      ADC genericDX
      BCC .offLeft
      CMP #PLAYER_X_MIN
      BCC .offLeft
      JMP .checkBoundsDone
      .offLeft:
        LDA #PLAYER_X_MIN
        SEC
        SBC playerX
        STA genericDX       
        RTS
    .checkLeftBoundDone:            
         
    ; check right screen bound.
    ; carry set after adding means playerX + genericDX > 255 - cap at X_MAX
    ; then compare to X_MAX, carry clear means playerX + genericDX < X_MAX - continue
    ; otherwise cap at X_MAX. if capping at X_MAX just exit.
    ; note - important - never put elevators right enough that this could be an issue
    ; (POI - possible issue with elevators)
    .checkRightBound:               
      LDA playerX
      CLC                           
      ADC genericDX
      BCS .offRight
      CMP #PLAYER_X_MAX
      BCC .checkRightBoundDone
      .offRight:
        LDA #PLAYER_X_MAX
        SEC
        SBC playerX
        STA genericDX
        RTS
    .checkRightBoundDone:   
  .checkBoundsDone:
  
  ; set new player box.  
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

  ; don't check collisions with other elevators if player is already on an elevator.
  ; (POI - possible issue with elevators)
  .playerOnElevator:
    LDA playerOnElevator
    BNE .checkCollisionsWithPlatforms
  
  ; check for collisions with elevators.  
  ; if none found, go check collisions with platforms.
  .checkCollisionsWithElevators:
    JSR CheckForElevatorCollision
    LDA collision
    BNE .adjustMovement
  
  ; check for collisions with platforms.
  ; but first check if player is moving - exit if not.
  ; check first screen first (c == 0), then second screen (c == 1) if no collisions found.
  ; if any collisions found, go to adjustMovement. Otherwise exit (leaving collision at 0).
  .checkCollisionsWithPlatforms:
   
    .checkPlayerDX:
      LDA genericDX
      BNE .checkFirstScreen
      RTS
  
    .checkFirstScreen:
      LDA #$00
      STA c
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      LDA collision
      BNE .adjustMovement
                                      
    .checkSecondScreen:               
      INC c
      JSR MovePlatformsPointerForward
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      JSR MovePlatformsPointerBack
      LDA collision
      BNE .adjustMovement
      RTS
      
  .checkCollisionsWithPlatformsDone:

  ; adjust movement 
  .adjustMovement:   
    
    ; just zero out the speed, it can stay like that assuming horizontal speed will always be 2
    LDA #$00
    STA genericDX
    RTS
    
    ; below is tested for platforms but not for elevators
    ;LDA b
    ;BNE .adjustMovingRight
    ;
    ; ; dx => boxX1 + dx - 1 = ax2 => dx = ax2 - boxX1 + 1
    ;.adjustMovingLeft:
    ;  LDA ax2
    ;  SEC
    ;  SBC playerPlatformBoxX1
    ;  STA genericDX
    ;  INC genericDX
    ;  RTS
    ;  
    ; ; dx => boxX2 + dx + 1 = ax1 => dx = ax1 - boxX2 - 1
    ;.adjustMovingRight:
    ;  LDA ax1
    ;  SEC
    ;  SBC playerPlatformBoxX2
    ;  STA genericDX
    ;  DEC genericDX
    ;  RTS
    
;****************************************************************
; Name:                                                         ;
;   ProcessElevatorVerticalColl                                 ;
;                                                               ;
; Description:                                                  ;
;   Process a vertical collision with an elevator               ;
;                                                               ;
; Input variables:                                              ;
;   yPointerCache - points to the elevator                      ;
;   b - 0 means player was moving up or is static, 1 means down ;
;   'a' boxes - elevator's box                                  ;
;   genericDY (which will be updated)                           ;
;                                                               ;
; Output variables:                                             ;
;   Updates genericDY                                           ;
;   b = 1 if player is standing on something, 0 otherwise       ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************
    
ProcessElevatorVerticalColl:

    ; player can either collide with the elevator from the top or the bottom.
    ; we can tell by the direction they are moving in and their speeds.
    ; if player collides with the elevator from the top, the player should be marked as standing on that elevator.
    ; 
    ; possible combinations which can let us figure this out:
    ;
    ; elevator moving | player moving | player speed vs elevator speed | result
    ; --------------------------------------------------------------------------
    ;       up        |      no       |               -                |  top   
    ;       up        |     down      |               -                |  top   
    ;       up        |      up       |               <                |  top   
    ;       up        |      up       |               >                | bottom  
    ;      down       |      no       |               -                | bottom
    ;      down       |      up       |               -                | bottom
    ;      down       |     down      |               <                | bottom
    ;      down       |     down      |               >                |  top 
    ;       no        |     down      |               -                |  top 
    ;       no        |      up       |               -                | bottom  
    ;
    
    ; first check the direction the elevator is moving in - Y = yPointerCache + 5 to point to the direction
    .checkElevatorDirection:
      LDA yPointerCache
      CLC
      ADC #$05
      TAY
      LDA elevators, y
      BEQ .elevatorStatic
      CMP #GENERIC_DIR_UP
      BEQ .elevatorMovingUp
      
    ; elevator is moving down
    ;
    ; elevator moving | player moving | player speed vs elevator speed | result
    ; --------------------------------------------------------------------------
    ;      down       |      no       |               -                | bottom
    ;      down       |      up       |               -                | bottom
    ;      down       |     down      |               <                | bottom
    ;      down       |     down      |               >                |  top 
    ;
    ; if player is static, collision from the bottom.
    ; if player is moving up, collision from the bottom.
    ; if player is moving down:
    ;   if player's speed is less than elevator's speed, collision from the bottom
    ;   if player's speed is more than elevator's speed, collision from the top
    .elevatorMovingDown:

      ; player static?
      LDA genericDY
      BEQ .collisionBottom
      
      ; player moving up?
      LDA b
      BEQ .collisionBottom
      
      ; todo: issue - if player is standing on the ground, DY will be 4 and this won't work
      ; check for platform collisions first?
      
      ; both platform and player are moving down, check speeds
      ; LDY yPointerCache, Y += 2 to point to speed, load to A, compare with genericDY
      ; cache clear if elevator speed < player speed => collision from the top
      ; otherwise collision from the bottom
      .playerMovingDown:
        LDY yPointerCache
        INY
        INY
        LDA elevators, y
        CMP genericDY
        BCC .collisionTop
        JMP .collisionBottom
    
    ; elevator is moving up
    ;
    ; elevator moving | player moving | player speed vs elevator speed | result
    ; --------------------------------------------------------------------------
    ;       up        |      no       |               -                |  top   
    ;       up        |     down      |               -                |  top   
    ;       up        |      up       |               <                |  top   
    ;       up        |      up       |               >                | bottom  
    ;
    ; if player is static, collision from the top.
    ; if player is moving down, collision from the top.
    ; if player is moving up:
    ;   if player's speed is less than elevator's speed, collision from the top
    ;   if player's speed is more than elevator's speed, collision from the bottom
    .elevatorMovingUp:

      ; player static?
      LDA genericDY
      BEQ .collisionTop
      
      ; player moving down?
      LDA b
      BEQ .playerMovingUp
      JMP .collisionTop
      
      ; both platform and player are moving up, check speeds
      ; we must first get the absolute player speed: genericDY = FF - genericDY + 1
      ; then LDY yPointerCache, Y += 2 to point to speed, load to A
      ; cache clear if elevator speed < player speed => collision from the bottom
      ; otherwise collision from the top
      .playerMovingUp:
        LDA #$FF
        SEC
        SBC genericDY
        STA genericDY
        INC genericDY
        LDY yPointerCache
        INY
        INY
        LDA elevators, y
        CMP genericDY
        BCC .collisionBottom
        JMP .collisionTop
    
    ; elevator is static.
    ;
    ; elevator moving | player moving | player speed vs elevator speed | result
    ; --------------------------------------------------------------------------
    ;       no        |     down      |               -                |  top 
    ;       no        |      up       |               -                | bottom  
    ;
    ; if player moving down, collision from the top.
    ; if player moving down, collision from the bottom.
    ; we'll never hit this if player is also static.
    .elevatorStatic:     
      LDA b
      BNE .collisionTop
    
    ; collision from the bottom, same logic as in CheckCollisionVertical.adjustMovement
    ; in addition, set b to 0
    .collisionBottom:      
      LDA ay2
      SEC
      SBC playerPlatformBoxY1
      STA genericDY
      INC genericDY
      LDA #$00
      STA b
      RTS
      
    ; collision from the top, same logic as in CheckCollisionVertical.adjustMovement
    ; in addition, set b to 1 and mark the platform as "player standing on this"
    .collisionTop:      
      LDA ay1
      SEC
      SBC playerPlatformBoxY2
      STA genericDY
      DEC genericDY
      LDA #$01
      STA b
      INC playerOnElevator
      LDA yPointerCache
      STA playerElevatorId
      RTS  

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
      STA renderYPos              ; POI - possible issue - this loopCheck is untested
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

GRAVITY = $04         ; =  4, how much the gravity pulls down per frame (not negative)

JUMP_SLOWDOWN = $04   ; =  4, id A is not down, go to this point in the jump (unless already there)
JUMP_PRESS = $0C      ; = 12, require A to be pressed when jump counter < this

JUMP_FRAMES = $0F     ; = 15, number of 'jump frames', start with this number then go down
jumpLookupTable:      ;       
  .byte $00           ; =  0
  .byte $00           ; =  0
  .byte $FF           ; = -1
  .byte $FF           ; = -1
  .byte $FE           ; = -2
  .byte $FE           ; = -2
  .byte $FE           ; = -2
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FD           ; = -3
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  .byte $FC           ; = -4
  
  ; possible jumps with the above:
  ; 
  ; |-----|----|----------|
  ; | gap | up | possible |
  ; |---------------------|
  ; |  3  |  0 |   yes    |
  ; |  4  |  0 |   no     |
  ; |  3  |  1 |   yes    |
  ; |  3  |  2 |   no     |
  ; |  0  |  2 |   yes    |
  ; |  0  |  3 |   no     |
  ; |  2  |  2 |   yes    |
  ; |  4  | -1 |   yes    |
  ; |  5  | -1 |   no     |
  ; |  5  | -2 |   no     |
  ; |  5  | -3 |   yes    |
  ; |  6  | -3 |   no     | 
  ; |-----|----|----------|
  
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

