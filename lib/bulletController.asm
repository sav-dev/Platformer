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
;   SpawnEnemyBullet                                            ;
;                                                               ;
; Description:                                                  ;
;   Spawns enemy bullet if possible                             ;
;                                                               ;
; Input:                                                        ;
;   enemyGunX, enemyGunY - point to spawn the bullet at         ;
;   genericDirection - current flip                             ;
;   enemyBulletPointer - pointer to the bullet type             ;
;   X - must be preserved!                                      ;
;                                                               ;
; Used variables:                                               ;
;   Generic vars                                                ;
;   X                                                           ;
;   Y                                                           ;
;   xPointerCache2                                              ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_consts_format                            ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************

SpawnEnemyBulletExit:
  RTS

SpawnEnemyBullet:
    
  ; first find a free slot, look for BULLET_S_NOT_EXIST == 0
  LDY #ENEMY_BULLET_LAST
  .findFreeSlotLoop:    
    LDA bullets, y
    BEQ .freeSlotFound ; BULLET_S_NOT_EXIST = 0
    CPY #ENEMY_BULLET_FIRST
    BEQ SpawnEnemyBulletExit
    TYA
    SEC
    SBC #BULLET_MEMORY_BYTES
    TAY
    JMP .findFreeSlotLoop
  
  ; free slot found, Y points to it. 
  ; cache X in xPointerCache2 (1st one is already used)
  ; then set the state to JUST_SPAWNED and INY to point to x speed
  .freeSlotFound:
    STX <xPointerCache2
    LDA #BULLET_S_JUST_SPAWNED
    STA bullets, y
    INY
    
    ; the first 5 bytes in the memory layout are: dx, dy, box dx, box dy, atts
    ; these are also the bytes in order in the consts, but we have to know if the enemy is flipped or not
    ; move the consts pointer if needed, copy, then move again if haven't moved already
    ; also there's a special subroutine for setting dy
    LDA <genericDirection
    BEQ .noFlip
    
    .flip:
      LDA <enemyBulletPointer
      CLC
      ADC #$05
      TAX
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      JSR SetEnemyBulletDy
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      JMP .spriteAndBoxSize
    
    .noFlip:
      LDX <enemyBulletPointer
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      JSR SetEnemyBulletDy
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      TXA
      CLC
      ADC #$05
      TAX
    
    ; when we get here:        
    ; next 3 bytes in both bullet consts and bullet data are sprite id and box dimensions. copy those.
    .spriteAndBoxSize:
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      LDA BulletConsts, x
      STA bullets, y
      INX
      INY
      
    ; the last byte in consts is the sound to play. play the sound.
    ; first cache y since playing the sound messes it up
    .playSound:
      LDA BulletConsts, x
      STA <sfxToPlay
      STY <yPointerCache
      JSR SfxLowPri
      LDY <yPointerCache
      
    ; consts are processed. next two bytes in bullet data are x and y position
    .setPosition:
      LDA <enemyGunX
      STA bullets, y
      INY
      LDA <enemyGunY
      STA bullets, y
  
    ; reload X from the cache
    .reloadX:
      LDX <xPointerCache2
      RTS

    ; small subroutine for setting bullet dy.
    ; x points to dy in consts, y points to dy in memory
    ; enemyBulletPointer points to the bullet
    SetEnemyBulletDy:
      LDA <enemyBulletPointer
      CMP #BOSS_RIGHT_HAND_BULLET ; BOSS_RIGHT_HAND_BULLET < BOSS_LEFT_HAND_BULLET
      BCC .regularBullet
      BEQ .bossRightHandBullet
      
      ; for bullets fired by the boss left hand, we want them to go upwards every other time
      ; make sure the shooting frequency is odd!
      .bossLeftHandBullet:
        LDA <frameCount
        AND #$01
        BNE .regularBullet
        LDA #$FF
        STA bullets, y        
        RTS
      
      ; for bullets fired by the boss right hand, we want them to go downwards every other time
      ; make sure the shooting frequency is odd!
      .bossRightHandBullet:
        LDA <frameCount
        AND #$01
        BNE .regularBullet
        LDA #$01
        STA bullets, y
        RTS           
      
      .regularBullet:
        LDA BulletConsts, x
        STA bullets, y
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
;   render vars                                                 ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************
  
UpdateBullets:
  
  ; update loop expects A to point to one bullet ahead of the one we want to update.
  ; first load j = last bullet to update.
  LDA <j
  UpdateLoop:
  
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
    JMP UpdateLoopCheck
    
    ; if we get here it means the bullet exists. compare to BULLET_S_SMTH_HIT.
    ; carry clear if state < BULLET_S_SMTH_HIT - meaning either BULLET_S_JUST_SPAWNED or BULLET_S_NORMAL
    .bulletExists:
      CMP #BULLET_S_SMTH_HIT
      BCC UpdateActiveBullet
    
    ; if we get here it means the bullet is exploding.
    ; increment the state by 1, and compare to the max.
    ; if not equal to the max, update explosion, otherwise clear the bullet.
    .bulletExploding:
      CLC
      ADC #$01
      CMP #BULLET_S_TO_CLEAR
      BNE .updateExplosion      
      JMP ClearBullet
      
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
      JMP RenderBullet
      
    ; if we got here, the bullet is active.
    UpdateActiveBullet:

      ; cache state in genericFrame
      STA <genericFrame
      CMP #BULLET_S_JUST_SPAWNED
      BNE .loadSpeed
      
      ; if bullet has just been spawned we don't want to move it.      
      ; set speed vars to 0
      .setSpeedTo0:
        LDA #$00
        STA <genericDX
        STA <genericDY
        INX ; 1 = x speed
        INX ; 2 = y speed
        JMP .preloadRemainingVars
    
       ; load the bullet speed vars:
       ;   x speed -> set to genericDX
       ;   y speed -> set to genericDY
      .loadSpeed:
        INX ; 1 = x speed
        LDA bullets, x
        STA <genericDX
        INX ; 2 = y speed
        LDA bullets, x
        STA <genericDY
    
      ; load the remaining variables in order up to x position and process:
      ;   box dx -> set to bx1
      ;   box dy -> set to by1
      ;   atts -> set to renderAtts
      ;   sprite id -> set to renderTile
      ;   box width -> set to genericWidth
      ;   box height -> set to genericHeight
      .preloadRemainingVars:
        INX ; 3 = box dx
        LDA bullets, x
        STA <bx1
        INX ; 4 = box dy
        LDA bullets, x
        STA <by1
        INX ; 5 = atts
        LDA bullets, x
        STA <renderAtts
        INX ; 6 = sprite id
        LDA bullets, x
        STA <renderTile
        INX ; 7 = box width
        LDA bullets, x
        STA <genericWidth
        INX ; 8 = box height
        LDA bullets, x
        STA <genericHeight       
              
      .updateXPosition:
        INX ; 9 = x position
        LDA <genericDX
        BPL .positiveDX
        
        .negativeDX:
          CLC
          ADC bullets, x
          BCS .setXPosition
          JMP ClearBullet ; carry not set means bullet went off the screen to the left
          
        .positiveDX:
          CLC
          ADC bullets, x
          BCC .setXPosition
          JMP ClearBullet ; carry set means bullet went off the screen to the right
          
        ; A is set to the updated X position
        ;   update the bullets memory;
        ;   set to renderXPos
        ;   add to bx1 - on overflow clear the bullet
        ;   bx2 = bx1 + genericWidth - on overflow cap at max
        .setXPosition:
          STA bullets, x
          STA <renderXPos
          CLC
          ADC <bx1
          BCC .setBX1
          JMP ClearBullet
          
          .setBX1:
            STA <bx1
            CLC
            ADC <genericWidth
            BCC .setBX2
            
            .capBX2:
              LDA #$FF              
              
            .setBX2:
              STA <bx2
              
      .updateYPosition:
        INX ; 10 = y position
        LDA <genericDY
        BPL .positiveDY
        
        .negativeDY:
          CLC
          ADC bullets, x
          BCS .setYPosition
          JMP ClearBullet ; carry not set means bullet went off the screen up
          
        .positiveDY:
          CLC
          ADC bullets, x
          CMP #SCREEN_HEIGHT
          BCC .setYPosition
          JMP ClearBullet ; carry set means bullet went off the screen down
          
        ; A is set to the updated Y position
        ;   update the bullets memory;
        ;   set to renderYPos
        ;   add to by1 - on >SCREEN_HEIGHT clear the bullet
        ;   by2 = by1 + genericHeight - no need to check for overflow
        .setYPosition:
          STA bullets, x
          STA <renderYPos
          CLC
          ADC <by1
          CMP #SCREEN_HEIGHT
          BCC .setBY1andBY2
          JMP ClearBullet
          
          .setBY1andBY2:
            STA <by1
            CLC
            ADC <genericHeight
            STA <by2
      
      ; when we get here, X points to the y position and the 'b' boxes are set to the bullet
      .checkCollisions: ; F5F3
  
        JSR CheckForCollisionsPlatThDoor
        LDA <collision
        BNE .collisionFound
        JSR CheckForElevatorCollision
        LDA <collision
        BNE .collisionFound
  
      ; no collision with scenery. If needed, check for collision with player.  
      .noCollisionWithScenery:
        LDA <l
        BNE .checkPlayerState
        JMP .noCollision
        
        ; only check for collisions with player if player is PLAYER_NORMAL
        .checkPlayerState:
          LDA <playerState
          BEQ .checkPlayerYState ; PLAYER_NORMAL = 0
          JMP .noCollision
          
        ; only check for collisions with player if playerYState != PLAYER_Y_STATE_EXIT_UP
        .checkPlayerYState:
          LDA <playerYState
          BNE .collisionWithPlayerCheck ; PLAYER_Y_STATE_EXIT_UP = 0
          JMP .noCollision
        
        ; check for collision with player.
        ; bullet's box is still in 'b' boxes, set the player's box in 'a' boxes.
        .collisionWithPlayerCheck:        
          LDA <playerThreatBoxX1
          STA <ax1
          LDA <playerThreatBoxX2
          STA <ax2
          LDA <playerThreatBoxY1
          STA <ay1
          LDA <playerThreatBoxY2
          STA <ay2
          JSR CheckForCollision
          LDA <collision
          BNE .explodePlayer
          JMP .noCollision
          
        ; collision with player detected - explode player, then flow to .collisionFound
        .explodePlayer:
          JSR ExplodePlayer
        
      ; collision was found.
      ; 'b' boxes set to the bullet boxes
      ; 'a' boxes set to whatever was hit
      ; genericDX/genericDY set to bullet speed
      ; if the bullet was just spawned, just clear it. otherwise explode it
      .collisionFound:
        LDA <genericFrame
        CMP #BULLET_S_JUST_SPAWNED
        BNE .moveBullet
        JMP ClearBullet    
        
      ; move the bullet to a place where it hit the obstacle.
      .moveBullet:
        
        ; genericX/genericY will dictate how to move the bullet.
        ;   0 => don't move in this plane
        ;   != 0 => move in this plane
        LDA #$00
        STA <genericX
        STA <genericY
      
        ; check if bullet has moved horizontally.
        LDA <genericDX
        BEQ .checkVertical ; not moving horizontally
        BPL .goingRight
        
      .goingLeft:
        
        ; we moved left by genericDX.
        ; now we have to move right by some amount.
        ; set genericHorDirLeft to 0 (meaning bullet should be moved right)
        LDA #$00
        STA <genericHorDirLeft
        
        ; set genericX to -genericDX for now
        ; then add (explosionWidth - genericWidth) (see below)
        LDA #$00
        SEC
        SBC <genericDX
        CLC
        ADC #BULLET_E_WIDTH
        SEC
        SBC <genericWidth
        STA <genericX
        
        ; we want to move right by: ax2 - bx1 + explosionWidth - genericWidth
        ; dx = ax2 - bx1 + explosionWidth - genericWidth
        LDA <ax2
        SEC
        SBC <bx1
        CLC
        ADC #BULLET_E_WIDTH
        SEC
        SBC <genericWidth
        STA <genericDX
          
        ; A contains the amount we want to move by.
        ; compare it to how much we moved by.
        ; if the absolute value is higher it means the bullet is moving diagonally
        ; and moving in the other plane caused the collision
        CMP <genericX
        BCS .goingLeftOtherPlaneCausedCollision ; carry set means A > genericX
        
        ; Moving in this plane caused the collision.
        ; Set genericX to absolute value
        .goingLeftCausedCollision:
          STA <genericX
          JMP .checkVertical
          
        ; Moving in the other plane caused the collision.
        ; Set genericX to FF to mark this
        .goingLeftOtherPlaneCausedCollision:
          LDA #$FF
          STA <genericX
          JMP .checkVertical
        
      .goingRight:
      
        ; we moved right by genericDX.
        ; now we have to move left by some amount.
        ; set genericHorDirLeft to 1 (meaning bullet should be moved left)
        LDA #$01
        STA <genericHorDirLeft
        
        ; set genericX to -genericDX for now
        ; then add (- explosionWidth + genericWidth) (see below)
        LDA #$00
        SEC
        SBC <genericDX
        SEC
        SBC #BULLET_E_WIDTH
        CLC
        ADC <genericWidth
        STA <genericX
      
        ; move left by: bx2 - ax1 + explosionWidth - genericWidth
        ; -genericDX = bx2 - ax1 + explosionWidth - genericWidth
        ; genericDX = ax1 - bx2 - explosionWidth + genericWidth
        ; genericX = -genericDX
        LDA <ax1
        SEC
        SBC <bx2
        SEC
        SBC #BULLET_E_WIDTH
        CLC
        ADC <genericWidth
        STA <genericDX

        ; A contains the amount we want to move by.
        ; compare it to how much we moved by.
        ; if the absolute value is higher it means the bullet is moving diagonally
        ; and moving in the other plane caused the collision
        CMP <genericX
        BEQ .goingRightOtherPlaneCausedCollision
        BCC .goingRightOtherPlaneCausedCollision ; carry clear means A < genericX but both are negative
        
        ; Moving in this plane caused the collision.
        ; Set genericX to absolute value
        .goingRightCausedCollision:
          LDA #$00
          SEC
          SBC <genericDX
          STA <genericX
          JMP .checkVertical
          
        ; Moving in the other plane caused the collision.
        ; Set genericX to FF to mark this
        .goingRightOtherPlaneCausedCollision:
          LDA #$FF
          STA <genericX              
        
      .checkVertical:
        LDA <genericDY
        BEQ .updateBulletPosition ; not moving vertically
        BPL .goingDown
        
      .goingUp:
        
        ; we moved up by genericDY.
        ; now we have to move down by some amount.
        ; set genericHorDirUp to 0 (meaning bullet should be moved down)
        LDA #$00
        STA <genericHorDirUp
        
        ; set genericY to -genericDY for now
        ; then add (explosionHeight - genericHeight) (see below)
        LDA #$00
        SEC
        SBC <genericDY
        CLC
        ADC #BULLET_E_HEIGHT
        SEC
        SBC <genericHeight
        STA <genericY
        
        ; move down by: ay2 - by1 + explosionHeight - genericHeight
        ; genericDY = ay2 - by1 + explosionHeight - genericHeight
        ; genericY = genericDY
        LDA <ay2
        SEC
        SBC <by1
        CLC
        ADC #BULLET_E_HEIGHT
        SEC
        SBC <genericHeight
        STA <genericDY

        ; A contains the amount we want to move by.
        ; compare it to how much we moved by.
        ; if the absolute value is higher it means the bullet is moving diagonally
        ; and moving in the other plane caused the collision
        CMP <genericY
        BCS .goingUpOtherPlaneCausedCollision ; carry set means A > genericY
        
        ; Moving in this plane caused the collision.
        ; Set genericY to absolute value
        .goingUpCausedCollision:
          STA <genericY
          JMP .updateBulletPosition
          
        ; Moving in the other plane caused the collision.
        ; Set genericY to FF to mark this
        .goingUpOtherPlaneCausedCollision:
          LDA #$FF
          STA <genericY
          JMP .updateBulletPosition
        
      .goingDown:
      
        ; we moved down by genericDY.
        ; now we have to move up by some amount.
        ; set genericHorDirUp to 1 (meaning bullet should be moved up)
        LDA #$01
        STA <genericHorDirUp
        
        ; set genericY to -genericDY for now
        ; then add (-explosionHeight + genericHeight) (see below)
        LDA #$00
        SEC
        SBC <genericDY
        SEC         
        SBC #BULLET_E_HEIGHT
        CLC
        ADC <genericHeight
        STA <genericY
      
        ; move up by: by2 - ay1 + explosionHeight - genericHeight
        ; -genericDY = by2 - ay1 + explosionHeight - genericHeight
        ; genericDY = ay1 - by2 - explosionHeight + genericHeight
        ; genericY = -genericDY
        LDA <ay1
        SEC
        SBC <by2
        SEC         
        SBC #BULLET_E_HEIGHT
        CLC
        ADC <genericHeight
        STA <genericDY
        
        ; A contains the amount we want to move by.
        ; compare it to how much we moved by.
        ; if the absolute value is higher it means the bullet is moving diagonally
        ; and moving in the other plane caused the collision
        CMP <genericY
        BEQ .goingDownOtherPlaneCausedCollision
        BCC .goingDownOtherPlaneCausedCollision ; carry clear means A < genericY but both are negative
        
        ; Moving in this plane caused the collision.
        ; Set genericY to absolute value
        .goingDownCausedCollision:          
          LDA #$00
          SEC
          SBC <genericDY
          STA <genericY
          JMP .updateBulletPosition
          
        ; Moving in the other plane caused the collision.
        ; Set genericY to FF to mark this
        .goingDownOtherPlaneCausedCollision:
          LDA #$FF
          STA <genericY
        
      ; genericDX and genericDY set to what we should move the bullets by.      
      .updateBulletPosition:
        LDA <genericX
        BEQ .movingOnlyVertically
        LDA <genericY
        BEQ .movingOnlyHorizontally
        
      ; if we get here it means the bullet is moving in both planes.
      ; move by the smaller absolute
      ; it all works because we set genericX/Y to FF if moving in the other plane caused the collision
      .movingInBothPlanes:
        LDA <genericY
        CMP <genericX
        BCS .moveBothByGenericX ; carry set means genericY >= genericX
        STA <genericX
        
        ; genericX now contains the value we should move the bullet by in both planes
        .moveBothByGenericX:
        
          .moveXByGenericX:
            LDA <genericHorDirLeft
            BEQ .moveXByGenericXGoRight
            
            .moveXByGenericXGoLeft:
              LDA #$00
              SEC
              SBC <genericX
              STA <genericDX
              JMP .moveYByGenericX
            
            .moveXByGenericXGoRight:
              LDA <genericX
              STA <genericDX
          
          .moveYByGenericX:
            LDA <genericHorDirUp
            BEQ .moveYByGenericXGoDown
            
            .moveYByGenericXGoUp:
              LDA #$00
              SEC
              SBC <genericX
              STA <genericDY
              JMP .updatePositionInBothPlanes
              
            .moveYByGenericXGoDown:
              LDA <genericX
              STA <genericDY
          
        ; when we get here, genericDX and genericDY are both set.
        .updatePositionInBothPlanes:     
          LDA <renderYPos
          CLC
          ADC <genericDY
          STA <renderYPos
          STA bullets, x        
          DEX
          LDA <renderXPos
          CLC
          ADC <genericDX
          STA <renderXPos
          STA bullets, x 
          JMP .updateBulletState
      
      .movingOnlyVertically:
        LDA <renderYPos
        CLC
        ADC <genericDY
        STA <renderYPos
        STA bullets, x
        DEX
        LDA <renderXPos
        SEC
        SBC #$02 ; we could move by width / 2 but it will pretty much always be 2
        BCC ClearBullet
        STA <renderXPos
        STA bullets, x        
        JMP .updateBulletState        
        
      .movingOnlyHorizontally:
        LDA <renderYPos
        SEC
        SBC #$02 ; we could move by width / 2 but it will pretty much always be 2
        BCC ClearBullet
        STA <renderYPos
        STA bullets, x
        DEX
        LDA <renderXPos
        CLC
        ADC <genericDX
        STA <renderXPos
        STA bullets, x 
        
      ; update bullet state.
      .updateBulletState:
        LDX <xPointerCache
        LDA #BULLET_S_SMTH_HIT
        STA bullets, x
        LDA #BULLET_SPRITE_E
        STA <renderTile
        LDA #BULLET_ATTS_E
        STA <renderAtts
        JMP RenderBullet
        
      ; no collisions detected.
      ; load X from xPointerCache to point to the state, then set it to BULLET_S_NORMAL
      ; (in case it's currently set to BULLET_S_JUST_SPAWNED).
      ; then go to render the bullet.
      .noCollision:
        LDX <xPointerCache
        LDA bullets, x
        CMP #BULLET_S_JUST_SPAWNED
        BNE RenderBullet
        LDA #BULLET_S_NORMAL
        STA bullets, x
        
      ; for player bullets, we don't want to play the sound if the player is against the wall 
      ; and the bullet doesn't show up. Play it here.
      ; for enemy bullets, we play the sound when the bullet is spawned as we control the position 
      ; and we can make sure they won't fire when against the wall.
      .playSoundIfPlayerBullet:
        LDA <l       
        BNE RenderBullet
        PlaySfxHighPri #sfx_index_sfx_shot ; todo 0007: update the sound

      ; render the bullet
      ; we expect all 4 render vars to be set when we get here
      RenderBullet:      
        JSR RenderSprite
        JMP UpdateLoopCheck
        
      ; we get here if we want to clear the bullet.
      ; load X from xPointerCache to point to the state, then set it to BULLET_S_NOT_EXIST
      ClearBullet:
        LDX <xPointerCache
        LDA #BULLET_S_NOT_EXIST 
        STA bullets, x 
          
      ; loop check. load the pointer of the bullet we just processed,
      ; and compare it to the lower bound param to see if we should exit the loop.
      UpdateLoopCheck:
        LDA <xPointerCache
        CMP <k
        BEQ .updateDone
        JMP UpdateLoop
  
  .updateDone:
    RTS
      
;****************************************************************
; Name:                                                         ;
;   ScrollBullets                                               ;
;                                                               ;
; Description:                                                  ;
;   Moves all bullets by frameScroll as part of the scroll      ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************  

ScrollBulletsExit:
  RTS
      
ScrollBullets:
  LDA <frameScroll
  BEQ ScrollBulletsExit
  BMI ScrollBulletsRight ; scroll < 0 means we should scroll right.
  ; flow into ScrollBulletsLeft
      
;****************************************************************
; Name:                                                         ;
;   ScrollBulletsLeft                                           ;
;                                                               ;
; Description:                                                  ;
;   Moves all bullets by frameScroll as part of the scroll      ;
;   Called when incrementing scroll, we must move bullets left  ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************  

ScrollBulletsLeft:

  ; start by pointing to the last bullet + 1 bullet ahead
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
  
    ; bullet exists. point to the x position
    TXA
    CLC
    ADC #BULLET_MEMORY_X_OFF
    TAX
    
    ; move the bullet
    LDA bullets, x
    SEC
    SBC <frameScroll
    BCS .setX
    
    ; carry clear means bullet went off screen to the left. clear it.
    .clearBullet:
      LDX <xPointerCache
      LDA #BULLET_S_NOT_EXIST
      STA bullets, x
      JMP .updateLoopCheck
      
    ; set position and flow into the loop check
    .setX:
      STA bullets, x
  
    .updateLoopCheck:
      LDA <xPointerCache
      BNE .updateLoop
      RTS  
    
;****************************************************************
; Name:                                                         ;
;   ScrollBulletsRight                                          ;
;                                                               ;
; Description:                                                  ;
;   Moves all bullets by frameScroll as part of the scroll      ;
;   Called when decrementing scroll, we must move bullets right ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;                                                               ;
; Tags:                                                         ;
;   depends_on_bullets_in_memory_format                         ;
;****************************************************************  

ScrollBulletsRight:

  ; start by pointing to the last bullet + 1 bullet ahead
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
  
    ; bullet exists. point to the x position
    TXA
    CLC
    ADC #BULLET_MEMORY_X_OFF
    TAX
    
    ; move the bullet
    LDA bullets, x
    SEC
    SBC <frameScroll
    BCC .setX
    
    ; carry set means bullet went off screen to the right. clear it.
    .clearBullet:
      LDX <xPointerCache
      LDA #BULLET_S_NOT_EXIST
      STA bullets, x
      JMP .updateLoopCheck
      
    ; set position and flow into the loop check
    .setX:
      STA bullets, x
  
    .updateLoopCheck:
      LDA <xPointerCache
      BNE .updateLoop
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