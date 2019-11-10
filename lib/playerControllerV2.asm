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
    JSR CheckCollisionVertical
    LDA collision
    BNE .verticalCollisionWhileCrouching
    
  ; Player was crouching in the last frame, but now there is no vertical collision.
  ; The only time this could happen is if the player was crouching on a horizontal elevator
  ; which made the player go into the wall and fall off the elevator.
  ; Move player by DY, then set the state to 'in air' and calculate boxes.
  ; Check for vertical collisions again in case player 'standing up' caused a collision.
  ; If collision found, move player by DY again (luckily CheckCollisionVertical assumes player went up if DY = 0).
  .noVerticalCollisionWhileCrouching:
    LDA #PLAYER_JUMP
    STA playerAnimation           ; update animation to jump
    JSR MovePlayerVertically      ; move player vertically by gravity
    JSR SetPlayerBoxesVertical    ; update boxes to make player 'stand up';
    JSR CheckCollisionVertical    ; check for collisions again. genericDY is 0 now so it will think player is below the obstacles
    JSR MovePlayerVertically      ; if no collision found, genericDY will be 0 and this is a no-op. POI - possible optimization - we could only do
    JSR SetPlayerBoxesVertical    ; these updates if collision found in the 2nd check, but this is so rare it's not worth the branching
    JMP .checkHorizontalMovement  ; go to the common horizontal movement code
  
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
      STA playerAnimation         ; update animation to jump
      JSR SetPlayerBoxesVertical  ; update boxes to make player 'stand up';
      JSR CheckCollisionVertical  ; check for collisions again. ignore any updates to DY, we just care whether a collision was found
      LDA collision
      BNE .playerCrouching        ; player must go back to the crouch if there is no room to stand up
      JMP .playerWantsToJump      ; go to the common jumping code
      
    ; No jump from crouch. Check if down is pressed. If yes, player wants to continue to crouch.
    ; Otherwise, 'stand up' and check for collisions. If any found, player must go back into crouch anyway.
    .noJumpFromCrouch:
      LDA controllerDown
      AND #CONTROLLER_DOWN
      BNE .playerCrouching
      LDA #PLAYER_STAND
      STA playerAnimation         ; update animation to jump
      JSR SetPlayerBoxesVertical  ; update boxes to make player 'stand up';
      JSR CheckCollisionVertical  ; check for collisions again. ignore any updates to DY, we just care whether a collision was found
      LDA collision
      BNE .playerCrouching        ; player must go back to the crouch if there is no room to stand up
      JMP .checkHorizontalMovement  ; go to the common horizontal movement code
      
    ; Player continues to crouch. No horizontal movement allowed in this case, so just set animation, update boxes and exit.
    .playerCrouching:
      LDA #PLAYER_CROUCH
      STA playerAnimation
      JSR SetPlayerBoxesVertical
      RTS
    
  .playerWasNotCrouching:
    LDA controllerDown
    AND #CONTROLLER_DOWN
    BEQ .playerWantsToJump
    LDA #PLAYER_CROUCH
    STA playerAnimation
    JSR SetPlayerBoxesVertical
  
  .playerWantsToJump:
    ; todo
  
  .checkHorizontalMovement:
    ; todo
  
  RTS

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
;  ; process vertical movement first
;  .verticalMovement:
;    
;    ; first check if player is riding on an elevator.
;    ; in such case, no collision checks are needed, just go to collisionGoingDown
;    .checkIfPlayerOnElevator:
;      LDA playerOnElevator
;      BNE .collisionGoingDown
;    
;    ; calculate DY based on either player jumping or gravity
;    .calculateDY:       
;
;      ; playerJump != 0 means the player is mid-jump animation, go to .processJump in that case
;      .checkJump:
;        LDA playerJump
;        BNE .processJump
;                                      
;      ; if not mid-jump, apply gravity, then go to check vertical collision
;      .applyGravity:                  
;        LDA #GRAVITY                    
;        STA genericDY                 
;        JMP .checkVerticalCollision        
;     
;      ; process jump 
;      ; note - remove everything from here up to and including
;      ; JMP .lookupJumpDistance to get rid of the 'keep A to jump' mechanic)      
;      .processJump:
;      
;        ; first check if we're at a point where we require A to be pressed to continue the jump (jump var > jump counter)
;        CMP #JUMP_PRESS               
;        BCS .updateJumpCounter
;      
;        ; we require A to be pressed, see if it's down.
;        ; if it is, process the jump normally
;        .jumpCheckA:
;          LDA controllerDown
;          AND #CONTROLLER_A 
;          BNE .updateJumpCounter
;          
;          ; A is no longer pressed.
;          ; if player jump is past (<=) the slowdown, continue normally.
;          ; otherwise, move the jump to the slowdown point.
;          .jumpANotDown:
;            LDA playerJump
;            CMP #JUMP_SLOWDOWN + $01
;            BCC .updateJumpCounter
;            LDA #JUMP_SLOWDOWN
;            STA playerJump
;            JMP .lookupJumpDistance
;        
;        ; we get here when jump is processed naturally.
;        ; decrement the jump counter.
;        .updateJumpCounter:
;          DEC playerJump
;          
;        ; we get here when the jump counter has been updated (via any way).
;        ; lookup the distance, set genericDY and go check for collisions.        
;        .lookupJumpDistance:
;          LDX playerJump              
;          LDA jumpLookupTable, x          
;          STA genericDY
;                                    
;    ; check for vertical collision - this will update genericDY and set collision and b (b = 1 means player is not standing on something).
;    ; apply movement (with updated DY), and then, if collision was detected, go process the collision.
;    .checkVerticalCollision:
;      JSR CheckCollisionVertical
;      JSR MovePlayerVertically
;      LDA collision 
;      BNE .processCollision
;      
;    ; we get here when no vertical collision was found - that means player is mid-air, set the animation to JUMP.
;    .playerMidAir:
;      LDA #PLAYER_JUMP
;      STA playerAnimation
;      JMP .verticalMovementDone       
;        
;    ; we get here when vertical collision was detected. Check if it was going up or going down.
;    .processCollision:  
;      LDA b
;      BNE .collisionGoingDown
;      
;     ; collision was when going up, cancel the jump (set to peak) and exit.
;     .collisionGoingUp:  
;       LDA #$00
;       STA playerJump
;       LDA #PLAYER_JUMP
;       STA playerAnimation
;       JMP .verticalMovementDone
;       
;     ; collision going down, cancel jump.
;     ; player is on the ground now, can either jump or crouch
;     .collisionGoingDown:
;       LDA #$00  
;       STA playerJump
;
;      ; if we get here it means the player is either on a platform or an elevator.
;      .playerOnTheGround:
;      
;        ; check if player wants to jump, update jump var and animation if yes.
;        ; also by jumping player gets off a platform.
;        .checkA:  
;          LDA controllerPressed
;          AND #CONTROLLER_A
;          BEQ .checkADone
;          LDA #JUMP_FRAMES
;          STA playerJump
;          LDA #PLAYER_JUMP
;          STA playerAnimation
;          LDA #$00
;          STA playerOnElevator
;          JMP .verticalMovementDone
;        .checkADone:
;        
;        ; check if player wants to crouch, update animation if yes
;        ; also set DY to 0 and 'move' player to update the threat box.
;        .checkDown:  
;          LDA controllerDown 
;          AND #CONTROLLER_DOWN
;          BEQ .checkDownDone
;          LDA #PLAYER_CROUCH
;          STA playerAnimation
;          LDA #$00
;          STA genericDY
;          JSR MovePlayerVertically
;          JMP .verticalMovementDone
;        .checkDownDone:
;        
;        ; no jump or crouch input.
;        ; if state is RUN leave it as so, otherwise set to STAND.
;        .noInput:
;          LDA playerAnimation
;          CMP #PLAYER_RUN
;          BEQ .verticalMovementDone
;          LDA #PLAYER_STAND
;          STA playerAnimation
;  
;  ; vertical movement has now been processed.
;  .verticalMovementDone:
;     
;  ; process horizontal movement now
;  .horizontalMovement:
;    
;    ; check if left is pressed, if yes update player's direction and - if not crouching - set DX.
;    .checkLeft:
;      LDA controllerDown
;      AND #CONTROLLER_LEFT
;      BEQ .checkLeftDone
;      LDA #DIRECTION_LEFT
;      STA playerDirection
;      LDA playerAnimation
;      CMP #PLAYER_CROUCH
;      BEQ .notMovingHorizontally
;      LDA #PLAYER_SPEED_NEGATIVE
;      STA genericDX
;      JMP .movingHorizontally
;    .checkLeftDone:
;    
;    ; check if right is pressed, if yes update player's direction and - if not crouching - set DX.
;    .checkRight:
;      LDA controllerDown
;      AND #CONTROLLER_RIGHT
;      BEQ .checkRightDone
;      LDA #DIRECTION_RIGHT
;      STA playerDirection
;      LDA playerAnimation
;      CMP #PLAYER_CROUCH
;      BEQ .notMovingHorizontally
;      LDA #PLAYER_SPEED_POSITIVE
;      STA genericDX
;      JMP .movingHorizontally
;    .checkRightDone:
;    
;    ; if we get here it means player is not moving vertically. set genericDX to 0.
;    ; if player is in the RUN state, replace it with the STAND State.
;    .notMovingHorizontally:
;      LDA #$00
;      STA genericDX
;      LDA playerAnimation
;      CMP #PLAYER_RUN                 
;      BEQ .changeStateToStand
;      JMP .checkHorizontalCollision
;      .changeStateToStand:
;        LDA #PLAYER_STAND
;        STA playerAnimation
;        JMP .checkHorizontalCollision
;    
;    ; if we get here it means player is moving vertically.
;    ; first update the animation:
;    ;   - if player in the JUMP animation, no updates needed
;    ;   - if player is in the STAND animation, change to RUN
;    ;   - if player is in the RUN animation, update the animation 
;    .movingHorizontally:
;      LDA playerAnimation
;      CMP #PLAYER_JUMP
;      BEQ .checkHorizontalCollision
;      CMP #PLAYER_STAND
;      BEQ .startRunning
;      DEC playerCounter
;      BNE .checkHorizontalCollision
;      LDA #PLAYER_ANIM_SPEED
;      STA playerCounter
;      DEC playerAnimationFrame
;      BNE .checkHorizontalCollision
;      LDA #PLAYER_ANIM_FRAMES
;      STA playerAnimationFrame
;      JMP .checkHorizontalCollision
;      
;    .startRunning:
;      LDA #PLAYER_RUN
;      STA playerAnimation
;      LDA #PLAYER_ANIM_SPEED
;      STA playerCounter
;      LDA #PLAYER_ANIM_FRAMES
;      STA playerAnimationFrame  
;    
;    ; animation has been updated, now check for a horizontal collision. this updates DX.
;    .checkHorizontalCollision:
;      JSR CheckCollisionHorizontal
;    
;    ; now apply the movement after collision checks.
;    ; depending on the player's position and scroll we want to either move the player or scroll the screen.
;    ; update the position by 1 at a time.
;    .applyHorizontalMovement:          
;      
;      ; if genericDX is 0 it means the movement update is done
;      ; it's also possible it will be 0 initially after checking for horizontal collisions.
;      LDA genericDX   
;      BEQ .horizontalMovementDone
;                    
;      ; POI - possible issue - this doesn't work if level is shorter than two screens
;                    
;      ; load scroll high byte, compare with max scroll high byte
;      LDA scroll + $01                
;      CMP maxScroll + $01
;      BEQ .highBytesMatch             
;                         
;      ; high bytes don't match.
;      ; check if low byte isn't 0 - in that case we should scroll
;      LDA scroll                      
;      BNE .scrollHorizontally
;                                      
;      ; high bytes don't match, low byte is 0.
;      ; check if high byte is 0, in that case we're on the left end.
;      ; otherwise we should scroll.
;      LDA scroll + $01                
;      BEQ .leftMost
;      JMP .scrollHorizontally
;
;      ; high bytes match, check if scroll == max scroll - in that case we're at the right end.
;      ; otherwise we should scroll.
;      .highBytesMatch:                
;        LDA scroll
;        CMP maxScroll
;        BEQ .rightMost
;        JMP .scrollHorizontally
;
;      ; we're on the left most screen.
;      ; check if player is on the left side of the screen (position != screen center). in such case, move the player.
;      ; otherwise, check which direction player is going - if going right, scroll, otherwise move.
;      .leftMost:                      
;        LDA playerX
;        CMP #PLAYER_SCREEN_CENTER
;        BNE .moveHorizontally
;        LDA genericDX                  
;        CMP #$80                      
;        BCC .scrollRight
;        JMP .moveHorizontally
;                             
;      ; we're on the right most screen.
;      ; check if player is on the right side of the screen (position != screen center). in such case, move the player.
;      ; otherwise, check which direction player is going - if going left, scroll, otherwise move.
;      .rightMost:                     
;        LDA playerX
;        CMP #PLAYER_SCREEN_CENTER
;        BNE .moveHorizontally
;        LDA genericDX                  
;        CMP #$80                      
;        BCS .scrollLeft
;        JMP .moveHorizontally
;                             
;      ; if we get here it means we want to move the player.
;      .moveHorizontally:              
;        JSR MovePlayerHorizontally
;        JMP .applyHorizontalMovement
;                        
;      ; if we get here it means we want to scroll the screen. 
;      ; check which direction player is going, and scroll.
;      .scrollHorizontally:
;        LDA genericDX                  
;        CMP #$80                      
;        BCC .scrollRight
;                                       
;        .scrollLeft:                   
;          JSR DecrementScroll          
;          LDA #$01
;          STA b
;          JSR ScrollBullets
;          INC genericDX
;          JMP .applyHorizontalMovement  
;          
;        .scrollRight:
;          JSR IncrementScroll          
;          LDA #$00
;          STA b
;          JSR ScrollBullets
;          DEC genericDX
;          JMP .applyHorizontalMovement
;          
;  ; horizontal movement has now been processed.
;  .horizontalMovementDone: 
;
;    ; POI - possible optimization? - this is a waste if player hasn't moved horizontally.
;    ; but probably still worth doing once on each frame than multiple times on some frames.
;    JSR SetPlayerBoxesHorizontal
;  
;  ; now that player has been moved, check if the player is still on an elevator and clear the flag if not
;  ; if player is not on an elevator, just skip.
;  ; otherwise, set the 'b' boxes to player platform box, but increment by2 by 1 to check for collision.
;  ; then check for collision with the elevator the player was on, if none found clear the flag.
;  ; POI - possible optimization - are the 'b' boxes still set from before?
;  .checkIfPlayerStillOnElevator:
;    LDA playerOnElevator
;    BEQ .renderPlayer
;    LDA playerPlatformBoxX1
;    STA bx1
;    LDA playerPlatformBoxX2
;    STA bx2
;    LDA playerPlatformBoxY1
;    STA by1
;    LDA playerPlatformBoxY2
;    STA by2
;    INC by2    
;    LDA #$00
;    STA collision
;    LDY playerElevatorId
;    JSR SingleElevatorCollision
;    LDA collision
;    BNE .renderPlayer
;    LDA #$00
;    STA playerOnElevator
;  
;  ; we can render the player now.
;  .renderPlayer:
;    JSR RenderPlayer
;
;  ; the player has been moved, check if player is falling off screen, change the state in that case.
;  .checkIfFallingOffScreen:
;    LDA playerY
;    CMP #PLAYER_Y_MAX
;    BNE .checkThreats
;    LDA #PLAYER_FALLING
;    STA playerState
;    RTS
;    
;  ; check for collisions with threats, explode player if any detected.
;  .checkThreats:
;    JSR CheckForThreatCollisions
;    LDA collision
;    BEQ .checkExit
;    JMP ExplodePlayer
;  
;  ; check if player wants to exit the stage and whether is at the exit.
;  .checkExit:
;    LDA controllerPressed
;    AND #CONTROLLER_UP
;    BNE .doCheckExit
;    RTS
;    .doCheckExit:
;      JMP CheckExit
      
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
;****************************************************************
; Name:                                                         ;
;   CheckCollisionVertical                                      ;
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

CheckCollisionVertical:
  
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