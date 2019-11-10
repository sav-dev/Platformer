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
;   N/I                                                         ;
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

  .include "lib\playerControllerV2.asm"
    
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
;   CheckCollisionHorizontal                                    ;
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
;                                                               ;
; Remarks:                                                      ;
;   depends_on_elevator_in_memory_format                        ;
;****************************************************************

CheckCollisionHorizontal:

  ; preset collisionCache to 0
  LDA #$00
  STA collisionCache

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
  .playerOnElevator:
    LDA playerOnElevator
    BNE .checkCollisionsWithPlatforms
  
  ; check for collisions with elevators.  
  ; if none found, go check collisions with platforms.
  .checkCollisionsWithElevators:
    JSR CheckForElevatorCollision
    LDA collision
    BNE .handleHorizontalCollisionWithElevator
  
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
      BNE .adjustMovementForPlatforms
                                      
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
      BNE .adjustMovementForPlatforms
      
      ; no collision found with either platforms or elevators
      ; but we may have had an out of bounds collision - do collision = collisionCache and exit
      LDA collisionCache
      STA collision
      RTS
      
    ; adjust movement
    .adjustMovementForPlatforms:   
      
      ; b = 0 means player was going left (genericDX < 0)
      ; b > 0 means player was going right (genericDX > 0)
      LDA b
      BNE .putPlayerOnTheLeft      
      JMP .putPlayerOnTheRight     
  
  ; We had a horizontal collision with an elevator. We must adjust the genericDX.
  ;
  ; If we get here:
  ;   'a' box is set to the box of the elevator that was hit
  ;   yPointerCache points to the elevator that was hit
  ;
  ; This is the logic to handle these collisions:
  ;
  ;   Elevator direction is stationary horizontally:
  ;       genericDX < 0 -> put on the RIGHT
  ;       genericDX > 0 -> put on the LEFT 
  ;       
  ;   Elevator is going left:
  ;       genericDX == 0 -> put on the LEFT
  ;       genericDX > 0 -> put on the LEFT
  ;       genericDX < 0:
  ;           elevatorSpeed > playerSpeed -> put on the LEFT
  ;           elevatorSpeed < playerSpeed -> put on the RIGHT
  ;
  ;   Elevator is going right:
  ;       genericDX == 0 -> put on the RIGHT
  ;       genericDX < 0 -> put on the RIGHT
  ;       genericDX > 0:
  ;           elevatorSpeed > playerSpeed -> put on the RIGHT
  ;           elevatorSpeed < playerSpeed -> put on the LEFT  
  ;
  .handleHorizontalCollisionWithElevator:
    
    ; first step is to check the direction of the elevator - Y = yPointerCache + 5 to point to the direction
    .checkElevatorDirection:
      LDA yPointerCache
      CLC
      ADC #$05
      TAY
      LDA elevators, y
      BEQ .elevatorGoingLeft ; DIRECTION_LEFT = 0
      CMP #DIRECTION_RIGHT
      BEQ .elevatorGoingRight
        
      .elevatorStaticHorizontally:
        ; we can just reuse the same logic we use for platforms here
        JMP .adjustMovementForPlatforms
                
      .elevatorGoingLeft:
        LDA genericDX
        BEQ .putPlayerOnTheLeft
        LDA b ; b > 0 means genericDX > 0
        BNE .putPlayerOnTheLeft        
        
        ; must compare speeds. Y = yPointerCache + 2 to point to the elevator speed
        ; load it and cache it in enemySpeed
        LDY yPointerCache
        INY
        INY
        LDA elevators, y
        JSR ProcessSpecialSpeed
        
        ; we now must get the absolute value of playerDX.
        LDA #$00
        SEC
        SBC genericDX
        
        ; A now contains absolute value of player speed. compare with elevator speed.
        CMP enemySpeed
        
        ; carry set means player speed > elevator speed - put on the right. otherwise put on the left
        BCS .putPlayerOnTheRight
        JMP .putPlayerOnTheLeft
        
      .elevatorGoingRight:
        LDA b ; b == 0 means genericDX <= 0
        BEQ .putPlayerOnTheRight
        
        ; must compare speeds. Y = yPointerCache + 2 to point to the elevator speed. load it and compare with player's speed
        LDY yPointerCache
        INY
        INY
        LDA elevators, y
        JSR ProcessSpecialSpeed
        CMP genericDX

        ; carry set means elevator speed > player speed - put on the right. otherwise put on the left
        BCS .putPlayerOnTheRight
        JMP .putPlayerOnTheLeft
  
  ; routines below put player on the left or the right of the a box
  
  ; dx => boxX1 + dx - 1 = ax2 => dx = ax2 - boxX1 + 1
  .putPlayerOnTheRight:
    LDA ax2
    SEC
    SBC playerPlatformBoxX1
    STA genericDX
    INC genericDX
    RTS
    
  ; dx => boxX2 + dx + 1 = ax1 => dx = ax1 - boxX2 - 1
  .putPlayerOnTheLeft:
    LDA ax1
    SEC
    SBC playerPlatformBoxX2
    STA genericDX
    DEC genericDX
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
;   LoadPlayer                                                  ;
;                                                               ;
; Description:                                                  ;
;   Loads player in the standing position.                      ;
;   Sets all variables.                                         ;
;   playerX and playerY should be set on input                  ;
;****************************************************************

LoadPlayer:
    
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
  
  .setBoxes:
    JSR SetPlayerBoxesHorizontal
    JSR SetPlayerBoxesVertical
  
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
; Input variables:                                              ;
;   playerDirection (left/right)                                ;
;   playerAnimation (courch/run/stand)                          ;                                                   
;   playerY, playerX                                            ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b ~ i used as pointers                                      ;
;****************************************************************
    
RenderPlayer:

  .stateCheck:
    LDA playerState
    BEQ .directionCheck           ; normal = 0
    RTS                           ; only render in the normal state, other states render in their 'update' routine
  
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
      JMP .animationCheck   
        
    .facingLeft:    
      LDA #LOW(playerXOffLeft)    
      STA h   
      LDA #HIGH(playerXOffLeft)   
      STA i   
        
      LDA #LOW (playerAttsLeft)   
      STA f   
      LDA #HIGH (playerAttsLeft)    
      STA g   
        
  .animationCheck:    
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

