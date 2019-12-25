BulletControllerStart:

;****************************************************************
; BulletController                                              ;
; Responsible for spawning and updating bullets                 ;
;****************************************************************

;
; - bullets in memory in the following format (11 bytes):
;    - state (1 byte)
;    - x speed (1 byte)
;    - y speed (1 byte) 
;    - box dx (1 byte)
;    - box dy (1 byte)
;    - atts (1 byte)
;    - sprite id (1 byte)
;    - box width (1 byte)
;    - box height (1 byte)
;    - x position (1 byte)
;    - y position (1 byte)
;
; tags: depends_on_bullets_in_memory_format
;

;****************************************************************
; Name:                                                         ;
;   SpawnPlayerBullet                                           ;
;                                                               ;
; Description:                                                  ;
;   Spawns player's bullet if possible                          ;
;                                                               ;
; Used variables:                                               ;
;   Generic vars                                                ;
;   renderAtts                                                  ;
;   X                                                           ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_consts_format                            ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************
  
SpawnPlayerBullet:

  LDX #PLAYER_BULLET_LAST

  .findFreeSlotLoop:    
    LDA bullets, x
    BEQ .freeSlotFound ; BULLET_S_NOT_EXIST == 0
    TXA
    BEQ .noFreeSlots   ; PLAYER_BULLET_FIRST == 0
    SEC
    SBC #BULLET_MEMORY_BYTES
    TAX
    JMP .findFreeSlotLoop
    
  .noFreeSlots:
    RTS
    
  ; X points to the 'state' byte of a free bullet slot  
  .freeSlotFound:

  ; get the gun position.
    .getYPosition:                      
      LDA <playerAnimation                  
      CMP #PLAYER_CROUCH                
      BEQ .playerCrouching              
                                      
      .playerUp:
        LDA <playerY                    
        CLC                             
        ADC #PLAYER_GUN_OFF_Y
        BCC .gunOffScreen ; carry cleared means gun is off screen
        STA <genericY
        JMP .getXPositionAndDirection        

      .gunOffScreen:
        RTS

    .playerCrouching:                 
      LDA <playerY                    
      CLC                             
      ADC #PLAYER_GUN_OFF_Y_C
      BCC .gunOffScreen ; same as above.
      STA <genericY

  .getXPositionAndDirection:               
    LDA <playerDirection              
    BEQ .shootLeft ; DIRECTION_LEFT = 0
    
    .shootRight:                      
      LDA <playerX                    
      CLC                             
      ADC #PLAYER_GUN_OFF_X_R         
      BCS .gunOffScreen ; gun off screen
      STA <genericX
      LDA #PLAYER_BULLET_ATTS
      STA <renderAtts
      LDA #PLAYER_BULLET_SPEED_X
      STA <genericDX
      JMP .spawnBullet
                                      
    .shootLeft:                       
      LDA <playerX                    
      CLC                             
      ADC #PLAYER_GUN_OFF_X_L         
      BCC .gunOffScreen ; gun off screen
      STA <genericX
      LDA #PLAYER_BULLET_ATTS_FLIP
      STA <renderAtts
      LDA #PLAYER_BULLET_SPEED_X_FLIP
      STA <genericDX
  
  ; fill the memory
  .spawnBullet:
 
    ; reset the cooldown
    LDA #PLAYER_BULLET_COOLDOWN
    STA <playerBulletCooldown
    
    ; play the sound
    JSR SfxShot ; todo 0006 - is this the right place    
    
    ; state
    LDA #BULLET_S_JUST_SPAWNED
    STA bullets, x
    
    ; x speed
    INX
    LDA <genericDX
    STA bullets, x
    
    ; y speed = 0
    ; box dx = 0
    ; box dy = 0
    INX
    LDA #$00
    STA bullets, x
    INX
    STA bullets, x
    INX
    STA bullets, x
                                                                       
    ; atts                                  
    INX
    LDA <renderAtts
    STA bullets, x
      
    ; sprite
    INX
    LDA #PLAYER_BULLET_SPRITE
    STA bullets, x
  
    ; box width and height
    INX
    LDA #PLAYER_BULLET_BOX_WIDTH
    STA bullets, x
    INX
    LDA #PLAYER_BULLET_BOX_HEIGHT
    STA bullets, x
    
    ; position
    INX
    LDA <genericX
    STA bullets, x
    INX
    LDA <genericY
    STA bullets, x
    
    RTS

;****************************************************************
; Name:                                                         ;
;   UpdatePlayerBullets                                         ;
;                                                               ;
; Description:                                                  ;
;   Updates player bullets                                      ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   generic vars                                                ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************
  
UpdatePlayerBullets:  

  ; j = last bullet to update + bullet size
  ; k = first bullet to update
  ; l = 0 means we're updating player bullets
  LDA #PLAYER_BULLET_LAST + BULLET_MEMORY_BYTES
  STA <j
  LDA #PLAYER_BULLET_FIRST
  STA <k
  ;LDA #$00                 ; not needed since PLAYER_BULLET_FIRST == 0
  STA <l
  JSR UpdateBullets
  RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdateEnemyBullets                                          ;
;                                                               ;
; Description:                                                  ;
;   Updates enemy bullets                                       ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   generic vars                                                ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************

UpdateEnemyBullets:

  ; j = last bullet to update + bullet size
  ; k = first bullet to update
  ; l = 1 means we're updating enemy bullets
  LDA #ENEMY_BULLET_LAST + BULLET_MEMORY_BYTES
  STA <j                    
  LDA #ENEMY_BULLET_FIRST
  STA <k                    
  LDA #$01
  STA <l                    
  JSR UpdateBullets
  RTS
  
;****************************************************************
; Name:                                                         ;
;   UpdateBullets                                               ;
;                                                               ;
; Description:                                                  ;
;   Updates all bullets                                         ;
;    - move                                                     ;
;    - platform & threat collision check                        ;
;    - player collision check (for enemy bullets)               ;
;    - render                                                   ;
;                                                               ;
; Input variables:                                              ;
;   j - last bullet to update                                   ;
;   k - first bullet to update                                  ;
;   l - set to 0 if player bullets are updated,                 ;
;       set to 1 if enemy bullets are update                    ;  
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   generic vars                                                ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************
  
UpdateBullets:
  
  ; update loop expects A to point to one bullet ahead of the one we want to update.
  ; first load j = last bullet to update.
  LDA <j
  .updateLoop:
  
    ; subtract bullet size, and store it in x and xPointerCache
    SEC
    SBC #BULLET_MEMORY_BYTES
    STA <xPointerCache
    TAX
  
    ; now X points to the start of the bullet we are updating
    ; load the bullet state
    LDA bullets, x
  
    ; BULLET_S_NOT_EXIST == 0, go to bulletExists on anything else.
    ; otherwise jump to the loop check
    BNE .bulletExists
    JMP .updateLoopCheck
    
    ; if we get here it means the bullet exists. compare to BULLET_S_SMTH_HIT.
    ; carry clear if state < BULLET_S_SMTH_HIT - meaning either normal or just spawned
    .bulletExists:
      CMP #BULLET_S_SMTH_HIT
      BCC .checkDirection
    
    ; if we get here it means the bullet is exploding.
    ; increment the state by 1, and compare to the max.
    ; if not equal to the max, update explosion, otherwise clear the bullet.
    .bulletExploding:
      CLC
      ADC #$01
      CMP #BULLET_S_TO_CLEAR
      BNE .updateExplosion      
      JMP .clearBullet
      
    ; bullet still exploding. first store the updated state, then calculate atts
    .updateExplosion:
      STA bullets, x
      
      ; calculate attributes, currently A = 00, 01, 10 or 11 based on current state
      ; then to ROR 3 times, afterwards A = 00000000, 01000000, 10000000, 11000000 meaning different rotations
      ; no need to ORA #BULLET_ATTS_E since BULLET_ATTS_E = 0
      AND #%00000011              
      ROR A
      ROR A
      ROR A
      STA <renderAtts
            
      ; point X to the x position, then store renderXPos
      TXA
      CLC
      ADC #(BULLET_MEMORY_X_OFF - BULLET_MEMORY_STATE)
      TAX 
      LDA bullets, x
      STA <renderXPos
      
      ; X += 1 to point to y position, then store renderYPos
      INX
      LDA bullets, x
      STA <renderYPos
      
      ; set render tile to exploding bullet
      LDA #BULLET_SPRITE_E
      STA <renderTile  
      
      ; render bullet
      JMP .renderBullet
      
    ; if we got here, the bullet is active.
    ; first cache the state in the genericFrame variable.
    ; first get the direction - X += 1 to point to it, then cache it in genericDirection
    .checkDirection:

  ;
  ;    STA <genericFrame
  ;    INX
  ;    LDA bullets, x 
  ;    STA <genericDirection
  ;  
  ;  ; move the bullet (unless just spawned) and set all render vars.
  ;  ; if we go there we still have direction loaded, so first check if it's left (DIRECTION_LEFT = 0),
  ;  ; then compare with other directions.
  ;  .moveAndPreset:
  ;    BEQ .goingLeft
  ;    CMP #DIRECTION_RIGHT  
  ;    BEQ .goingRight  
  ;    CMP #DIRECTION_DOWN 
  ;    BEQ .goingDown
  ;    JMP .goingUp
  ;                
  ;      ; bullet going right. first X += 1 to point to x position.
  ;      ; then load the state and check if the bullet just spawned - don't move it in that case.
  ;      ; otherwise, move the bullet (go to .clearBullet if it's off screen), preset bx1, renderXPos, and atts.
  ;      .goingRight:
  ;        INX
  ;        LDA <genericFrame
  ;        CMP #BULLET_S_JUST_SPAWNED
  ;        BEQ .dontMoveRight
  ;        LDA bullets, x
  ;        CLC
  ;        ADC #BULLET_SPEED
  ;        BCC .moveRight                ; carry clear if bx1 + bullet speed <= screen width: bullet on screen
  ;        JMP .clearBullet
  ;      
  ;        .dontMoveRight:
  ;          LDA bullets, x
  ;      
  ;        .moveRight:
  ;          STA bullets, x
  ;          STA <bx1
  ;          STA <renderXPos
  ;          LDA #BULLET_ATTS_RIGHT
  ;          STA <renderAtts
  ;          JMP .goingHorizontally
  ;        
  ;      ; same logic as goingRight
  ;      .goingLeft:
  ;        INX
  ;        LDA <genericFrame
  ;        CMP #BULLET_S_JUST_SPAWNED
  ;        BEQ .dontMoveLeft
  ;        LDA bullets, x 
  ;        SEC 
  ;        SBC #BULLET_SPEED
  ;        BCS .moveLeft                 ; carry set if bx1 - bullet speed >= 0: bullet on screen
  ;        JMP .clearBullet
  ;      
  ;        .dontMoveLeft:
  ;          LDA bullets, x 
  ;          
  ;        .moveLeft:
  ;          STA bullets, x
  ;          STA <bx1
  ;          STA <renderXPos
  ;          LDA #BULLET_ATTS_LEFT
  ;          STA <renderAtts
  ;        
  ;      ; get get here for either goingLeft or goingRight.
  ;      ; set tile, X += 1 to point to the y position, set by1, renderYPos, calculate by2, calculate bx2 (capping at screen width)
  ;      .goingHorizontally:
  ;        LDA #$99
  ;        STA <renderTile
  ;        INX
  ;        LDA bullets, x
  ;        STA <by1
  ;        STA <renderYPos
  ;        CLC
  ;        ADC #BULLET_HEIGHT            ; height because going horizontally
  ;        STA <by2
  ;        LDA <bx1
  ;        CLC
  ;        ADC #BULLET_WIDTH             ; width because going horizontally
  ;        BCS .boxHCapX2
  ;        STA <bx2
  ;        JMP .checkCollisions
  ;        
  ;        .boxHCapX2:
  ;          LDA #SCREEN_WIDTH
  ;          STA <bx2
  ;          JMP .checkCollisions
  ;          
  ;      ; bullet going down. first X += 1 to point to x position. store it in bx1 and renderXPos.
  ;      ; then X += 1 to point to y position.
  ;      ; then load the state and check if the bullet just spawned - don't move it in that case.
  ;      ; otherwise, move the bullet (go to .clearBullet if it's off screen), preset by1, renderYPos, and atts.
  ;      .goingDown:
  ;        INX
  ;        LDA bullets, x 
  ;        STA <bx1
  ;        STA <renderXPos
  ;        INX
  ;        LDA <genericFrame
  ;        CMP #BULLET_S_JUST_SPAWNED
  ;        BEQ .dontMoveDown
  ;        LDA bullets, x
  ;        CLC 
  ;        ADC #BULLET_SPEED
  ;        CMP #SCREEN_HEIGHT        
  ;        BCC .moveDown                 ; carry clear if by1 + bullet speed < screen height: bullet on screen
  ;        JMP .clearBullet
  ;        
  ;        .dontMoveDown:
  ;          LDA bullets, x
  ;        
  ;        .moveDown:
  ;          STA bullets, x
  ;          STA <by1
  ;          STA <renderYPos
  ;          LDA #BULLET_ATTS_DOWN 
  ;          STA <renderAtts
  ;          JMP .goingVertically
  ;        
  ;      ; same logic as goingDown
  ;      .goingUp:
  ;        INX
  ;        LDA bullets, x 
  ;        STA <bx1
  ;        STA <renderXPos
  ;        INX
  ;        LDA <genericFrame
  ;        CMP #BULLET_S_JUST_SPAWNED
  ;        BEQ .dontMoveUp
  ;        LDA bullets, x
  ;        SEC 
  ;        SBC #BULLET_SPEED
  ;        BCS .moveUp                   ; carry set if by1 - bullet speed >= 0: bullet on screen
  ;        JMP .clearBullet
  ;      
  ;        .dontMoveUp:
  ;          LDA bullets, x
  ;      
  ;        .moveUp:
  ;          STA bullets, x
  ;          STA <by1
  ;          STA <renderYPos
  ;          LDA #BULLET_ATTS_UP 
  ;          STA <renderAtts
  ;        
  ;      ; get get here for either goingUp or goingDown.
  ;      ; set tile, calculate by2, calculate bx2 (capping at screen width)
  ;      .goingVertically:
  ;        LDA #$9A
  ;        STA <renderTile
  ;        LDA <by1
  ;        CLC
  ;        ADC #BULLET_WIDTH             ; width because going vertically
  ;        STA <by2
  ;        LDA <bx1
  ;        CLC
  ;        ADC #BULLET_HEIGHT            ; height because going vertically
  ;        BCS .boxVCapX2
  ;        STA <bx2
  ;        JMP .checkCollisions         
  ;            
  ;        .boxVCapX2:
  ;          LDA #SCREEN_WIDTH
  ;          STA <bx2
  ;            
  ;    ; when we get here the bullet has been moved in memory, box is set, rendering vars are set
  ;    ; check for collisions with platforms and threats.
  ;    .checkCollisions:
  ;      JSR CheckForCollisionsPlatThDoor
  ;      LDA <collision
  ;      BEQ .noCollisionWithPlatAndTh
  ;              
  ;    ; if we get here, a collision has been detected. X still points to the Y position.
  ;    ; if it was just spawn, just clear it. otherwise we must update it's position
  ;    .collisionWithPlatOrTh:
  ;      LDA <genericFrame
  ;      CMP #BULLET_S_JUST_SPAWNED
  ;      BNE .collisionCheckDirection
  ;      JMP .clearBullet
  ;    
  ;    ; check the direction the bullet was going
  ;    ; to update the position we'll use the fact that 'a' boxes contain the position of whatever we hit
  ;    .collisionCheckDirection:
  ;      LDA <genericDirection
  ;      BEQ .collisionLeft              ; DIRECTION_LEFT = 0
  ;      CMP #DIRECTION_RIGHT  
  ;      BEQ .collisionRight
  ;      CMP #DIRECTION_DOWN 
  ;      BEQ .collisionDown
  ;      
  ;      ; collision going up, meaning bullet y should be set to ay2 + 1
  ;      .collisionUp:                   
  ;        INC <ay2
  ;        LDA <ay2
  ;        STA bullets, x
  ;        STA <renderYPos
  ;        JMP .collisionUpdateState
  ;      
  ;      ; collision going down, meaning bullet y should be set to ay1 - tile size
  ;      .collisionDown:
  ;        LDA <ay1
  ;        SEC
  ;        SBC #BULLET_E_HEIGHT
  ;        STA bullets, x
  ;        STA <renderYPos
  ;        JMP .collisionUpdateState
  ;            
  ;      ; collision going left, meaning bullet y should be set to ax2 + 1
  ;      ; but first X -= 1 to point to the x position
  ;      .collisionLeft:                
  ;        DEX
  ;        INC <ax2
  ;        LDA <ax2
  ;        STA bullets, x
  ;        STA <renderXPos
  ;        JMP .collisionUpdateState
  ;      
  ;      ; collision going right, meaning bullet y should be set to ax1 - tile size
  ;      ; but first X -= 1 to point to the x position
  ;      .collisionRight:                
  ;        DEX
  ;        LDA <ax1
  ;        SEC
  ;        SBC #BULLET_E_WIDTH
  ;        STA bullets, x
  ;        STA <renderXPos
  ;        
  ;    ; when we get here, position has been updated in memory and in render vars.
  ;    ; we must update the state to BULLET_S_SMTH_HIT, and update the tiles we want to render.
  ;    ; but first load X from xPointerCache to point to the state.
  ;    ; then go to render the bullet.
  ;    .collisionUpdateState:
  ;      LDX <xPointerCache
  ;      LDA #BULLET_S_SMTH_HIT
  ;      STA bullets, x
  ;      LDA #BULLET_SPRITE_E
  ;      STA <renderTile
  ;      LDA #BULLET_ATTS_E
  ;      STA <renderAtts
  ;      JMP .renderBullet
  ;      
  ;    ; we get here if no collision with platforms or threats was detected.
  ;    ; check for collisions with elevators.      
  ;    .noCollisionWithPlatAndTh:        
  ;      JSR CheckForElevatorCollision
  ;      LDA <collision
  ;      BEQ .noCollisionWithElevators
  ;      
  ;    ; collision with elevator detected.
  ;    ; if bullet has just been spawned, clear it.
  ;    ; otherwise explode the bullet.
  ;    ; backlog - move the bullet to the place it actually hit the platform
  ;    .collisionWithElevator:
  ;      LDA <genericFrame
  ;      CMP #BULLET_S_JUST_SPAWNED
  ;      BNE .collisionUpdateState
  ;      JMP .clearBullet
  ;      
  ;    ; we get here if no collision with platforms, threats or elevators was detected.  
  ;    ; check for collisions with player for enemy bullets.
  ;    .noCollisionWithElevators:
  ;      LDA <l
  ;      BEQ .noCollision
  ;      
  ;      ; only check for collisions with player if player is PLAYER_NORMAL
  ;      .checkPlayerState:
  ;        LDA <playerState
  ;        BEQ .checkPlayerYState ; PLAYER_NORMAL = 0
  ;        JMP .noCollision
  ;        
  ;      ; only check for collisions with player if playerYState != PLAYER_Y_STATE_EXIT_UP
  ;      .checkPlayerYState:
  ;        LDA <playerYState
  ;        BNE .collisionWithPlayerCheck ; PLAYER_Y_STATE_EXIT_UP = 0
  ;        JMP .noCollision
  ;      
  ;    ; check for collision with player.
  ;    ; bullet's box is still in 'b' boxes, set the player's box in 'a' boxes.
  ;    .collisionWithPlayerCheck:        
  ;      LDA <playerThreatBoxX1
  ;      STA <ax1
  ;      LDA <playerThreatBoxX2
  ;      STA <ax2
  ;      LDA <playerThreatBoxY1
  ;      STA <ay1
  ;      LDA <playerThreatBoxY2
  ;      STA <ay2
  ;      JSR CheckForCollision
  ;      LDA <collision
  ;      BEQ .noCollision
  ;      
  ;      ; collision with player detected - explode player, then go to .collisionUpdateState
  ;      JSR ExplodePlayer
  ;      JMP .collisionUpdateState        
  ;    
  ;    ; no collisions detected.
  ;    ; load X from xPointerCache to point to the state, then set it to BULLET_S_NORMAL
  ;    ; (in case it's currently set to BULLET_S_JUST_SPAWNED).
  ;    ; then go to render the bullet.
  ;    .noCollision:
  ;      LDX <xPointerCache
  ;      LDA #BULLET_S_NORMAL
  ;      STA bullets, x
        
      ; render the bullet
      ; we expect all 4 render vars to be set when we get here
      .renderBullet:      
        JSR RenderSprite
        JMP .updateLoopCheck
        
      ; we get here if we want to clear the bullet.
      ; load X from xPointerCache to point to the state, then set it to BULLET_S_NOT_EXIST
      .clearBullet:
        LDX <xPointerCache
        LDA #BULLET_S_NOT_EXIST 
        STA bullets, x 
          
      ; loop check. load the pointer of the bullet we just processed,
      ; and compare it to the lower bound param to see if we should exit the loop.
      .updateLoopCheck:
        LDA <xPointerCache
        CMP <k
        BEQ .updateDone
        JMP .updateLoop
  
  .updateDone:
    RTS
      
;****************************************************************
; Name:                                                         ;
;   ScrollBullets                                               ;
;                                                               ;
; Description:                                                  ;
;   Moves all bullets by 1 as part of the scroll                ;
;                                                               ;
; Input values:                                                 ;
;   b - 0 means we're incrementing scroll (move left)           ;
;       1 means we're decrementing scroll (move right)          ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************  

ScrollBullets:

  ; update loop expects A to point to the bullet 4 bytes ahead of the one we want to update.
  LDA #TOTAL_BULLET_LAST + BULLET_MEMORY_BYTES
  .updateLoop:
  
    ; subtract bullet size, and store it in x and xPointerCache
    SEC
    SBC #BULLET_MEMORY_BYTES
    STA <xPointerCache
    TAX
  
    ; load the bullet state, do nothing if the bullet doesn't exist (0 == BULLET_S_NOT_EXIST)
    LDA bullets, x
    BEQ .updateLoopCheck
    
    ; we must move the bullet. X += 2 to point to the x position
    INX
    INX
    
    ; check which direction we're scrolling in
    LDA <b
    BEQ .moveLeft
    
    ; move bullet right
    .moveRight:
      LDA bullets, x
      CLC
      ADC #$01
      BCS .offScreen
      STA bullets, x
      JMP .updateLoopCheck
    
    ; move bullet left
    .moveLeft:       
      LDA bullets, x
      SEC
      SBC #$01
      BCC .offScreen
      STA bullets, x
      JMP .updateLoopCheck
    
    ; if we got here, it means the bullet is off screen.
    ; load the pointer to the state, then clear the bullet.
    .offScreen:
      LDX <xPointerCache
      LDA #BULLET_S_NOT_EXIST 
      STA bullets, x 
      JMP .updateLoopCheck
        
    .updateLoopCheck:
      LDA <xPointerCache
      BEQ .updateDone
      JMP .updateLoop
  
  .updateDone:
    RTS      
    
;****************************************************************
; Name:                                                         ;
;   CheckForCollisionsPlatThDoor                                ;
;                                                               ;
; Description:                                                  ;
;   Checks for platforms, threats and door collisions on both   ;
;   screens with the 'b' hitbox                                 ;
;                                                               ;
; Input variables:                                              ;
;   'b' hitboxes                                                ;
;                                                               ;
; Output variables:                                             ;
;   collision set to 1 means collision has been detected        ;
;   'a' hitboxes remain set to whatever the collision was with  ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   collision vars                                              ;
;   genericPointer                                              ;
;****************************************************************
  
CheckForCollisionsPlatThDoor:

  .checkDoor:
    JSR CheckForDoorCollision
    LDA <collision
    BNE .collisionCheckDone

  .checkFirstPlatformScreen:
    LDA #$00
    STA <c
    LDA <platformsPointer
    STA <genericPointer
    LDA <platformsPointer + $01
    STA <genericPointer + $01
    JSR CheckForPlatformOneScreen
    LDA <collision
    BNE .collisionCheckDone

  .checkFirstThreatScreen:
    LDA <threatsPointer
    STA <genericPointer
    LDA <threatsPointer + $01
    STA <genericPointer + $01
    JSR CheckForPlatformOneScreen
    LDA <collision
    BNE .collisionCheckDone
  
  .checkSecondPlatformScreen:
    INC <c
    JSR MovePlatformsPointerForward
    LDA <platformsPointer
    STA <genericPointer
    LDA <platformsPointer + $01
    STA <genericPointer + $01
    JSR CheckForPlatformOneScreen
    JSR MovePlatformsPointerBack
    LDA <collision
    BNE .collisionCheckDone
  
  .checkSecondThreatScreen:
    JSR MoveThreatsPointerForward
    LDA <threatsPointer
    STA <genericPointer
    LDA <threatsPointer + $01
    STA <genericPointer + $01
    JSR CheckForPlatformOneScreen
    JSR MoveThreatsPointerBack  
    
  .collisionCheckDone:
    RTS
    
;****************************************************************
; EOF                                                           ;
;****************************************************************

BulletControllerEnd: