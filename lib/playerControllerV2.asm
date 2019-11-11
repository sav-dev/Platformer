;****************************************************************
; Name:                                                         ;
;   UpdatePlayerNormal                                          ;
;                                                               ;
; Description:                                                  ;
;   Updates player based on current state and input.            ;
;   Updates:                                                    ;
;     - playerX and playerY (may scroll)                        ;
;     - playerAnimation                                         ;
;     - playerDirection                                         ;
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
;   some enemy vars                                             ;
;****************************************************************

UpdatePlayerNormal:

  ; Check if in the last frame player was crouching.
  .checkIfWasCrouching:
    LDA playerAnimation
    CMP #PLAYER_CROUCH
    BEQ .playerWasCrouching
    JMP .playerWasNotCrouching
    
  ; Player was crouching in the last frame.
  ; Apply gravity, check for vertical collisions, adjust DY
  .playerWasCrouching:
    LDA #GRAVITY
    STA genericDY
    JSR CheckPlayerCollisionVertical
    LDA collision
    BNE .verticalCollisionWhileCrouching
    
  ; Player was crouching in the last frame, but now there is no vertical collision.
  ; The only time this could happen is if the player was crouching on a horizontal elevator
  ; which made the player go into the wall and fall off the elevator.
  ; Move player by DY, then set the state to 'in air' and calculate boxes.
  ; Check for vertical collisions again in case player 'standing up' caused a collision.
  ; If collision found, move player by DY again (luckily CheckPlayerCollisionVertical assumes player went up if DY = 0).
  .noVerticalCollisionWhileCrouching:
    LDA #PLAYER_JUMP
    STA playerAnimation                 ; update animation to jump
    JSR MovePlayerVertically            ; move player vertically by gravity
    JSR SetPlayerBoxesVertical          ; update boxes to make player 'stand up';
    JSR CheckPlayerCollisionVertical    ; check for collisions again. genericDY is 0 now so it will think player is below the obstacles TODO - no need to check elevators here
    JSR MovePlayerVertically            ; if no collision found, genericDY will be 0 and this is a no-op. POI - possible optimization - we could only do
    JSR SetPlayerBoxesVertical          ; these updates if collision found in the 2nd check, but this is so rare it's not worth the branching
    JMP .checkHorizontalMovement        ; go to the common horizontal movement code
  
  ; Player was crouching in the last frame, and is still on some platform.
  ; POI - possible issue - WE ASSUME GENERIC DY IS 0 - there should never be a case where the player falls off an elevator while crouching,
  ; and then goes down by less than the value of gravity and hits something.
  ; So the only case this may happen is if player is still on the same platform they were previously.
  ; Check if the player wants to jump - that cancels crouching.
  .verticalCollisionWhileCrouching:
    LDA controllerPressed
    AND #CONTROLLER_A
    BEQ .noJumpFromCrouch
    
    ; Player wants to jump from crouch. 'stand up' and check for collisions. If any found, player must go back into crouch.
    .jumpFromCrouch:
      LDA #PLAYER_JUMP
      STA playerAnimation               ; update animation to jump
      JSR SetPlayerBoxesVertical        ; update boxes to make player 'stand up';
      JSR CheckPlayerCollisionVertical  ; check for collisions again. ignore any updates to DY, we just care whether a collision was found TODO - no need to check elevators here
      LDA collision
      BNE .playerCrouching              ; player must go back to the crouch if there is no room to stand up
      JMP .playerWantsToJump            ; go to the common jumping code
      
    ; No jump from crouch. Check if down is pressed. If yes, player wants to continue to crouch.
    ; Otherwise, 'stand up' and check for collisions. If any found, player must go back into crouch anyway.
    .noJumpFromCrouch:
      LDA controllerDown
      AND #CONTROLLER_DOWN
      BNE .playerCrouching
      LDA #PLAYER_STAND
      STA playerAnimation               ; update animation to jump
      JSR SetPlayerBoxesVertical        ; update boxes to make player 'stand up';
      JSR CheckPlayerCollisionVertical  ; check for collisions again. ignore any updates to DY, we just care whether a collision was found
      LDA collision
      BNE .playerCrouching              ; player must go back to the crouch if there is no room to stand up
      JMP .checkHorizontalMovement      ; go to the common horizontal movement code
      
    ; Player continues to crouch. Set the animation, update boxes, and go to the common horizontal movement code.
    .playerCrouching:
      LDA #PLAYER_CROUCH
      STA playerAnimation
      JSR SetPlayerBoxesVertical
      JMP .checkHorizontalMovement
    
  ; Player was not crouching in the last frame.
  ; First check if player is mid-jump.
  .playerWasNotCrouching:
    LDA playerJump
    BEQ .playerWasNotJumping
    
    ; Player is mid-jump. 
    .playerWasJumping:
    
       ; First check if we're at a point where we require A to be pressed to continue the jump (jump var > jump counter)
        CMP #JUMP_PRESS               
        BCS .updateJumpCounter
      
        ; We require A to be pressed, see if it's down. If it is, process the jump normally
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
        
        ; We get here when jump is processed normally. Decrement the jump counter.
        .updateJumpCounter:
          DEC playerJump
          
        ; Once we get here, the jump counter has been updated. Lookup the distance, set genericDY and go check for collisions.        
        .lookupJumpDistance:
          LDX playerJump              
          LDA jumpLookupTable, x
          BEQ .playerMidJump ; little optimization, if we're in the state of jump where DY = 0 no need to check for collisions
          STA genericDY
          JMP .checkVerticalCollision
    
    ; Player was not in a jump. Apply gravity.
    .playerWasNotJumping:
      LDA #GRAVITY
      STA genericDY
     
    ; Once we get here, genericDY is set, either via gravity or the jump mechanics.
    ; Check for vertical collisions, move player and update boxes. Then check whether a collision was found.
    .checkVerticalCollision:
      JSR CheckPlayerCollisionVertical
      JSR MovePlayerVertically
      JSR SetPlayerBoxesVertical
      LDA collision
      BNE .verticalCollision
  
      ; No vertical collision was found.
      ; Set animation to jump and go check horizontal movement.
      .playerMidJump:
        LDA #PLAYER_JUMP
        STA playerAnimation
        JMP .checkHorizontalMovement
  
      ; If we get here, a vertical collision was found.
      ; Check if the collision was going up (b = 0) or down (b > 0).
      .verticalCollision:
        LDA b
        BNE .collisionGoingDown
        
        ; Collision going up. Cancel the jump, set animation to jump.
        .collisionGoingUp:
          LDA #$00
          STA playerJump
          JMP .playerMidJump
  
        ; If we get here it means there's a collision when going down.
        ; That means player is standing on something and is allowed to crouch or jump.
        .collisionGoingDown:
          
          ; First check if down is down on the d-pad.
          LDA controllerDown
          AND #CONTROLLER_DOWN
          BNE .playerCrouching
          
          ; Then check if A is pressed.
          LDA controllerPressed
          AND #CONTROLLER_A
          BNE .playerWantsToJump
          
          ; Player doesn't want to crouch or jump.
          ; If current animation is not RUN, update to STAND. Otherwise, leave as RUN.
          LDA playerAnimation
          CMP #PLAYER_RUN
          BEQ .checkHorizontalMovement
          LDA #PLAYER_STAND
          STA playerAnimation
          JMP .checkHorizontalMovement                  
  
  ; If we get here, it means player wants to and is allowed to jump.
  ; Set the jump vars and clear the playerOnElevator flag.  
  .playerWantsToJump:    
    LDA #JUMP_FRAMES
    STA playerJump
    LDA #PLAYER_JUMP
    STA playerAnimation
    LDA #$00
    STA playerOnElevator
  
  ; Once we get here, vertical movement has been updated. 
  ; Player has been moved vertically, vertical boxes have been updated, animation is set.
  .checkHorizontalMovement:
    
    ; Check if left is pressed, if yes update player's direction.
    ; Then if player is not crouching, set DX.
    .checkLeft:
      LDA controllerDown
      AND #CONTROLLER_LEFT
      BEQ .checkRight
      LDA #DIRECTION_LEFT
      STA playerDirection
      LDA playerAnimation
      CMP #PLAYER_CROUCH
      BEQ .notMovingHorizontally
      LDA #PLAYER_SPEED_NEGATIVE
      STA genericDX
      JMP .movingHorizontally
    
    ; Check if right is pressed, if yes update player's direction.
    ; Then if player is not crouching, set DX.
    .checkRight:
      LDA controllerDown
      AND #CONTROLLER_RIGHT
      BEQ .notMovingHorizontally
      LDA #DIRECTION_RIGHT
      STA playerDirection
      LDA playerAnimation
      CMP #PLAYER_CROUCH
      BEQ .notMovingHorizontally
      LDA #PLAYER_SPEED_POSITIVE
      STA genericDX
      JMP .movingHorizontally

    ; If we get here it means player is not moving vertically.
    ; If player is in the RUN state, replace it with the STAND State, then exit.
    .notMovingHorizontally:
      LDA playerAnimation
      CMP #PLAYER_RUN
      BEQ .changeAnimationToStand
      RTS
      
      .changeAnimationToStand:
        LDA #PLAYER_STAND
        STA playerAnimation
        RTS
        
    ; If we get here it means player is moving horizontally.
    ; First update the animation:
    ;   - if player is in the STAND animation, change to RUN
    ;   - if player in the JUMP animation, no updates needed
    ;   - if player is in the RUN animation, update the animation 
    .movingHorizontally:
      LDA playerAnimation
      BEQ .startRunning ; PLAYER_STAND = 0
      CMP #PLAYER_JUMP
      BEQ .checkHorizontalCollision      
      
      ; Player is running, update the animation,
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
            
      ; If we get here, DX is set to something non-zero.
      ; Check for a horizontal collision. This updates DX.
      .checkHorizontalCollision:
        JSR CheckPlayerCollisionHorizontal
        LDA genericDX
        BNE .applyHorizontalMovement
        RTS ; DX set to 0 by the collision routine, no need to move the player
      
      ; Now apply the movement after collision checks.
      ; Depending on the player's position and scroll, we want to either move the player or scroll the screen.
      ; Update the position by 1 at a time.
      ; POI - possible issue - this doesn't work if level is shorter than two screens
      .applyHorizontalMovement:                       
                      
        ; Load scroll high byte, compare with max scroll high byte
        LDA scroll + $01                
        CMP maxScroll + $01
        BEQ .highBytesMatch             
                           
        ; High bytes don't match.
        ; Check if low byte isn't 0 - in that case we should scroll
        LDA scroll                      
        BNE .scrollHorizontally
                                        
        ; High bytes don't match, low byte is 0.
        ; Check if high byte is 0, in that case we're on the left end.
        ; Otherwise we should scroll.
        LDA scroll + $01                
        BEQ .leftMost
        JMP .scrollHorizontally
  
        ; High bytes match, check if scroll == max scroll - in that case we're at the right end.
        ; Otherwise we should scroll.
        .highBytesMatch:                
          LDA scroll
          CMP maxScroll
          BEQ .rightMost
          JMP .scrollHorizontally
  
        ; We're on the left most screen.
        ; Check if player is on the left side of the screen (position != screen center). in such case, move the player.
        ; Otherwise, check which direction player is going - if going right, scroll, otherwise move.
        .leftMost:                      
          LDA playerX
          CMP #PLAYER_SCREEN_CENTER
          BNE .moveHorizontally
          LDA genericDX                  
          CMP #$80                      
          BCC .scrollRight
          JMP .moveHorizontally
                               
        ; We're on the right most screen.
        ; Check if player is on the right side of the screen (position != screen center). in such case, move the player.
        ; Otherwise, check which direction player is going - if going left, scroll, otherwise move.
        .rightMost:                     
          LDA playerX
          CMP #PLAYER_SCREEN_CENTER
          BNE .moveHorizontally
          LDA genericDX                  
          CMP #$80                      
          BCS .scrollLeft
          JMP .moveHorizontally
                               
        ; If we get here it means we want to move the player.
        .moveHorizontally:              
          JSR MovePlayerHorizontally
          JMP .checkIfShouldMoveMore
                          
        ; If we get here it means we want to scroll the screen. 
        ; Check which direction player is going, and scroll.
        .scrollHorizontally:
          LDA genericDX                  
          CMP #$80                      
          BCC .scrollRight
                                         
          .scrollLeft:                   
            JSR DecrementScroll          
            LDA #$01
            STA b
            JSR ScrollBullets
            INC genericDX
            JMP .checkIfShouldMoveMore  
            
          .scrollRight:
            JSR IncrementScroll          
            LDA #$00
            STA b
            JSR ScrollBullets
            DEC genericDX

      ; We;ve moved the player and updated DX. See if we should move the player any more. 
      ; If not, set horizontal boxes and exit.
      .checkIfShouldMoveMore:
        LDA genericDX
        BNE .applyHorizontalMovement
        JSR SetPlayerBoxesHorizontal
        RTS

;****************************************************************
; Name:                                                         ;
;   CheckThreats                                                ;
;                                                               ;
; Description:                                                  ;
;   Checks for collisions between player and threats            ;
;   Also checks if player is falling off the screen             ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************

CheckThreats:
        
  .checkIfFallingOffScreen:
    LDA playerY
    CMP #PLAYER_Y_MAX
    BNE .checkThreats
    LDA #PLAYER_FALLING ; TODO - this shouldn't be the case for jet pack missions
    STA playerState
    RTS
    
  .checkThreats:
    JSR CheckPlayerThreatCollisions
    LDA collision
    BEQ .noCollision
    JMP ExplodePlayer
    
  .noCollision:
    RTS

;****************************************************************
; Name:                                                         ;
;   CheckVictoryConditions                                      ;
;                                                               ;
; Description:                                                  ;
;   Checks the victory conditions                               ;
;                                                               ;
; Used variables:                                               ;
;   ax1                                                         ;
;   ax2                                                         ;
;****************************************************************
    
CheckVictoryConditions:

  ; TODO - victory condition should come from the level data. For now assume it's the exit one.
  ; check if player wants to exit the stage and whether is at the exit.
  LDA controllerPressed
  AND #CONTROLLER_UP
  BNE .checkExit
  RTS
  
  .checkExit:
  
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
;   CheckPlayerCollisionVertical                                ;
;                                                               ;
; Description:                                                  ;
;   Check for vertical collisions                               ;
;                                                               ;
; Input:                                                        ;
;   genericDY                                                   ;
;                                                               ;
; Output:                                                       ;
;   collision = 1 set on output if collision detected           ;
;   'a' boxes set to whatever the collision was with (if any)   ;
;   b set on output to:                                         ;
;     1 if player was moving down                               ;
;     0 if player was moving up or was static                   ;
;   elevator vars set if player is on an elevator               ;
;   genericDY is updated                                        ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   yPointerCache                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   enemyScreen                                                 ;
;   enemySpeed                                                  ;
;   elevatorSize                                                ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************
 
CheckPlayerCollisionVertical:
  
  ; preset collisionCache and playerOnElevator to 0
  .presetCollisionCache:
    LDA #$00
    STA collisionCache
    STA playerOnElevator
 
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
    ; in either case also INC collisionCache
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
        INC collisionCache
        JMP .checkBoundsDone

    ; check bottom screen bound.
    ; carry clear after adding means playerY + genericDY < Y_MAX - continue
    ; otherwise cap at max and just exit
    ; in either case also INC collisionCache
    .checkBottomBound:
      LDA playerY                     
      CLC                             
      ADC genericDY                    
      CMP #PLAYER_Y_MAX               
      BCC .checkBoundsDone
      .offBottom:                     
        LDA #PLAYER_Y_MAX             
        SEC
        SBC playerY                   
        STA genericDY                  
        INC collisionCache
    
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
 
  ; check for collisions with platforms first,
  ; check first screen first (c == 0), then second screen (c == 1) if no collisions found.
  ; if any collisions found, go to .adjustMovement. Otherwise go to .checkCollisionsWithElevators
  ; POI - possible issue - make sure player will never a vertical collision with both platform and elevator in a frame.
  ; that could be the case if player could gain more vertical speed than the thickness of an elevator.
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
      
  ; now check for collisions with elevators.
  ; if collision found, go handle it. otherwise exit,
  ; but first do collision = collisionCache to handle the out of bounds case
  .checkCollisionsWithElevators:
    JSR CheckForElevatorCollision
    LDA collision
    BNE .processPlayerAndElevatorCollision
    LDA collisionCache
    STA collision
    RTS  
    
  ; if we get here, player had a vertical collision with an elevator.
  ; check if was going down, set the elevator vars if yes.  
  .processPlayerAndElevatorCollision:
    LDA b ; 0 means that player was going up, 1 that player was going down
    BEQ .adjustMovement 
    LDA yPointerCache
    STA playerOnElevator
    STA playerElevatorId
    
  .adjustMovement:

    LDA b ; 0 means that player was going up or static, 1 that player was going down
    BNE .playerMovingDown
    
    ; dy => boxY1 + dy - 1 = ay2 => dy = ay2 - boxY1 + 1
    .playerMovingUp:      
      LDA ay2
      SEC
      SBC playerPlatformBoxY1
      STA genericDY
      INC genericDY
      RTS
      
    ; dy => boxY2 + dy + 1 = ay1 => dy = ay1 - boxY2 - 1
    .playerMovingDown:      
      LDA ay1
      SEC
      SBC playerPlatformBoxY2
      STA genericDY
      DEC genericDY
      RTS
        
;****************************************************************
; Name:                                                         ;
;   CheckPlayerCollisionHorizontal                              ;
;                                                               ;
; Description:                                                  ;
;   Check for horizontal collisions, updates genericDX          ;
;                                                               ;
; Output:                                                       ;
;   collision = 1 set on output if collision detected           ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   yPointerCache                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   enemyScreen                                                 ;
;   enemySpeed                                                  ;
;   elevatorSize                                                ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************

CheckPlayerCollisionHorizontal:

  ; preset collisionCache to 0
  LDA #$00
  STA collisionCache

  ; check move direction, set b to 0 (left) or 1 (right). This never gets called when DX = 0
  .directionCheck: 
    LDA #$00
    STA b
    LDA genericDX
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
    ; in either case also INC collisionCache
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
        INC collisionCache
        JMP .checkBoundsDone
         
    ; check right screen bound.
    ; carry set after adding means playerX + genericDX > 255 - cap at X_MAX
    ; then compare to X_MAX, carry clear means playerX + genericDX < X_MAX - continue
    ; otherwise cap at X_MAX. if capping at X_MAX just exit.
    ; in either case also INC collisionCache
    .checkRightBound:               
      LDA playerX
      CLC                           
      ADC genericDX
      BCS .offRight
      CMP #PLAYER_X_MAX
      BCC .checkBoundsDone
      .offRight:
        LDA #PLAYER_X_MAX
        SEC
        SBC playerX
        STA genericDX
        INC collisionCache
    
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

  ; don't check collisions with other elevators if player is already on an elevator.
  ; we will never have a vertical collision and horizontal collision with elevators in the same frame.
  ; POI - possible issue - make sure that's the case
  .playerOnElevator:
    LDA playerOnElevator
    BNE .checkCollisionsWithPlatforms
  
  ; check for collisions with elevators first.
  .checkCollisionsWithElevators:
    JSR CheckForElevatorCollision
    LDA collision
    BEQ .checkCollisionsWithPlatforms
  
    ; Collision found. Adjust DX. If still > 0, check for collisions with platforms. Otherwise exit.
    .adjustMovementForElevator:
      JSR .adjustMovementHorizontal
      INC collisionCache ; we must do this to make sure we do not lose the info about the collision if there are no platform ones
      LDA genericDX
      BNE .checkCollisionsWithPlatforms
      RTS
  
  ; check for collisions with platforms.
  ; check first screen first (c == 0), then second screen (c == 1) if no collisions found.
  ; if any collisions found, go to adjustMovement. Otherwise exit.
  .checkCollisionsWithPlatforms:
  
    .checkFirstScreen:
      LDA #$00
      STA c
      LDA platformsPointer
      STA genericPointer
      LDA platformsPointer + $01
      STA genericPointer + $01
      JSR CheckForPlatformOneScreen
      LDA collision
      BNE .adjustMovementHorizontal
                                      
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
      BNE .adjustMovementHorizontal
      
      ; no collision found with platforms.
      ; but we may have had an out of bounds collision, or an elevator collision - do collision = collisionCache and exit
      LDA collisionCache
      STA collision
      RTS
            
  ; Helper subroutine for adjusting horizontal movement  
  .adjustMovementHorizontal:
          
    LDA b ; 0 means that player was going left, 1 that player was going right
    BNE .playerMovingRight
    
    ; dx => boxX1 + dx - 1 = ax2 => dx = ax2 - boxX1 + 1
    .playerMovingLeft:
      LDA ax2
      SEC
      SBC playerPlatformBoxX1
      STA genericDX
      INC genericDX
      RTS
      
    ; dx => boxX2 + dx + 1 = ax1 => dx = ax1 - boxX2 - 1
    .playerMovingRight:
      LDA ax1
      SEC
      SBC playerPlatformBoxX2
      STA genericDX
      DEC genericDX
      RTS
        
;****************************************************************
; Name:                                                         ;
;   MovePlayerVertically                                        ;
;                                                               ;
; Description:                                                  ;
;   Moves the player vertically based on genericDY              ;
;   Sets genericDY to 0                                         ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;****************************************************************

MovePlayerVertically:

  LDA genericDY
  CLC   
  ADC playerY    
  STA playerY
  LDA #$00
  STA genericDY
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SetPlayerBoxesVertical                                      ;
;                                                               ;
; Description:                                                  ;
;   Sets the coordtinates of player's vertical boxes,           ;
;   based on the animation (boxes for crouching are smaller)    ;
;****************************************************************
  
SetPlayerBoxesVertical:

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
;   MovePlayerHorizontally                                      ;
;                                                               ;
; Description:                                                  ;
;   Moves the player horizontally based on genericDX.           ;
;   genericDX is updated (moved closer to 0 by 1).              ;
;****************************************************************

MovePlayerHorizontally:
  
  LDA genericDX                  
  CMP #$80                      
  BCS .goingLeft
  
  .goingRight:
    INC playerX
    DEC genericDX
    RTS
  
  .goingLeft:
    DEC playerX
    INC genericDX
    RTS
      
;****************************************************************
; Name:                                                         ;
;   SetPlayerBoxesHorizontal                                    ;
;                                                               ;
; Description:                                                  ;
;   Sets the coordtinates of player's horizontal boxes.         ;
;****************************************************************
    
SetPlayerBoxesHorizontal:

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