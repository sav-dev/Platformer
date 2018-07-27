;****************************************************************
; EnemiesManager                                                ;
; Responsible for rendering and updating enemies                ;
;****************************************************************

;
; - enemies in level data the following format:
;   - pointer to next screen (from here): (n x 15) + 3 (1 byte)
;   - number of enemies (1 byte)
;   - n times the enemy data (15 bytes)
;        - 1st byte of id - pointer to the right variable (1 byte)
;        - 2nd byte of id - a mask in the right variable (1 byte) 
;        - slot to put enemy in (1 byte)
;        - pointer to const. data (1 byte)
;        - screen the enemy is on (1 byte)
;        - movement speed (1 byte)
;        - max movement distance (1 byte)
;        - initial flip (1 byte)
;        - initial movement left (1 byte)
;        - movement direction (1 byte)
;        - x position (1 byte)
;        - y position (1 byte)            
;        - initial life (1 byte)
;        - shooting frequency initial (1 byte)
;        - shooting frequency (1 byte)
;   - pointer to the previous screen (from here): (n x 15) + 2 (1 byte)
;
; - enemies in memory in the following format (16 bytes):
;    - state (1 byte)
;    - id (1 byte)
;    - pointer to const. data (1 byte)
;    - screen the enemy is on (1 byte)
;    - movement speed (1 byte)
;    - max movement distance (1 byte)
;    - current flip (1 byte)
;    - movement left (1 byte)
;    - movement direction (1 byte)
;    - x position (1 byte)
;    - y position (1 byte)
;    - remaining life (1 byte)  
;    - shooting timer (1 byte)
;    - shooting frequency (1 byte)
;    - animation timer (1 byte)
;    - animation frame (1 byte)
;

;****************************************************************
; Name:                                                         ;
;   UpdateActiveEnemy                                           ;
;                                                               ;
; Description:                                                  ;
;   Updates an active enemy pointed to by the X register        :
;   X register points to the state on input                     ;
;   xPointerCache can also be used to go back to the top        ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   enemyOrientation                                            ;
;   enemyScreen                                                 ;
;   enemySpeed                                                  ;
;   enemyAnimationSpeed                                         ;
;   enemyFrameCount                                             ;
;   enemyGunX                                                   ;
;   enemyGunY                                                   ;
;   enemyRender                                                 ;
;   enemyCollisions                                             ;
;   enemyMaxDistance                                            ;
;   genericDirection                                            ;
;   genericX                                                    ;
;   genericY                                                    ;
;   genericDX                                                   ;
;   genericDY                                                   ;
;   removeEnemy - incremented if enemy should be exploded       ;
;   render vars                                                 ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************
 
UpdateActiveEnemy:

  ; assume the enemy should be rendered.
  ; also, while we're here, assume collision check is needed and enemy is not flashing
  LDA #$01
  STA enemyOnScreen
  STA enemyCollisions
  STA enemyNotFlashing

  ; at this point, X points to the state.
  ; check if enemy is flashing - compare state to 3 (ENEMY_STATE_ACTIVE + 1),
  ; if carry clear enemy is not flashing.
  ; otherwise, check if state % 2 == 1, in that case DEC enemyNotFlashing.
  ; finally, DEC the state.
  .checkIfFlashing:
    LDA enemies, x
    CMP #ENEMY_STATE_ACTIVE + $01
    BCC .cachePointerAndScreen
    AND #$01
    BEQ .decState
    DEC enemyNotFlashing
    .decState:
      DEC enemies, x
  
  ; X still points to the state.
  ; cache the const data pointer in Y and the screen the enemy is on in enemyScreen
  ; first do X += 3 to skip state and id. we'll point to the const data.
  ; then do X += 1 to point to the screen.
  ; then to X += 1 to point to the next byte after the screen (speed).
  .cachePointerAndScreen:
    INX
    INX
    INX
    LDA enemies, x
    TAY
    INX
    LDA enemies, x
    STA enemyScreen
    INX
    
  ; the next 7 bytes are:
  ;  - movement speed (currently pointed to by X)
  ;  - max movement distance
  ;  - current flip
  ;  - movement left
  ;  - movement direction
  ;  - x position
  ;  - y position
  ;
  ; use them to move the enemy, updating:
  ;  - current movement distance
  ;  - current flip (potentially)
  ;  - x position
  ;  - y position
  ;
  ; we need these cached for later:
  ;  - current flip
  ;  - x position
  ;  - y position
  EnemyMove:
    
    ; set DX and DY to 0 for starters
    ; also while we're here, set genericOffScreen to 0
    LDA #$00
    STA genericDX
    STA genericDY
    STA genericOffScreen
    
    ; load and cache the speed
    LDA enemies, x
    STA enemySpeed
        
    ; do X += 1 to point to the max distance, then load it and cache it
    INX
    LDA enemies, x
    STA enemyMaxDistance
      
    ; do X += 1 to point to the current flip, then cache it in genericDirection
    INX
    LDA enemies, x
    STA genericDirection
    
    ; do X += 1 to point to movement left, then load it
    ; movementLeft == 0 means the enemy is static
    ; (it will never be 0 for moving enemies; in this case speed must be 0 and movement type must be none).
    ; in that case, skip the updates. otherwise, update movement left
    INX
    LDA enemies, x
    BEQ .calculateDiffs
    SEC
    SBC enemySpeed
    STA enemies, x
    BNE .calculateDiffs
    
    ; if we get here, it means an extreme has been met.
    ; we must:
    ;   - set movement left to max distance
    ;   - X -= 1 to point to flip, update it but *do not* re-cache
    ;   - x += 1 to point back to movement left
    .extremeMet:
      LDA enemyMaxDistance
      STA enemies, x
      DEX
      LDA enemies, x
      EOR #%00000001
      STA enemies, x
      INX
    
    ; once we get here, x is still pointing to movement left, but everything has been updated.
    ; first do a X += 1 to point at movement direction, load it, and cache it in enemyOrientation
    ;
    ; that var is a bit complicated.
    ; possible values:
    ;   0 = 00000000 - none
    ;   1 = 00000001 - static horizontal
    ;   2 = 00000010 - static vertical
    ;   5 = 00000101 - moving horizontal
    ;   6 = 00000110 - moving vertical
    ;
    ; for sake of movement, anything < 5 means no movement - in that case, skip this section
    ; otherwise, based on the direction and flip (cached in genericDirection), set DX and DY
    ;
    ; POI - possible optimization - have separate vars for movement type and pointing direction?   
    .calculateDiffs:
      INX
      LDA enemies, x
      STA enemyOrientation
      CMP #ENEMY_MOVE_HORIZONTAL
      BCC .applyMovement
      BEQ .horizontalMovement
      
      ; in the verticalMovement and horizontalMovement sections we:
      ;   - check genericDirection
      ;   - if it's 0 (no flip) we set DX/DY to enemySpeed
      ;   - if it's 1 (flip) we set DX/DY to -enemySpeed
      .verticalMovement:
        LDA genericDirection
        BEQ .verticalNoFlip
      
        .verticalFlip:
          LDA #$00
          SEC
          SBC enemySpeed
          STA genericDY
          JMP .applyMovement
        
        .verticalNoFlip:
          LDA enemySpeed
          STA genericDY
          JMP .applyMovement
      
      .horizontalMovement:
        LDA genericDirection
        BEQ .horizontalNoFlip
      
        .horizontalFlip:
          LDA #$00
          SEC
          SBC enemySpeed
          STA genericDX
          JMP .applyMovement
        
        .horizontalNoFlip:
          LDA enemySpeed
          STA genericDX
          
    ; once we get here, x is still pointing to movement direction, and diffs are set.
    ; do X += 1 and apply DX, caching the result in genericX
    ; then do X += 1 and apply DY, caching the result in genericY
    ; finally do a X += 1 to point the register to the next byte
    .applyMovement:
      INX
      LDA enemies, x
      CLC
      ADC genericDX
      STA enemies, x
      STA genericX
      INX
      LDA enemies, x
      CLC
      ADC genericDY
      STA enemies, x
      STA genericY
      INX      
      
  ; once we get here, movement has been updated, and the following are set:
  ;   - X set to remaining life
  ;   - Y set to the const data pointer (1st byte: width)
  ;   - genericDirection set to current flip
  ;   - genericX and genericY set to the current position
  ;   - genericOffScreen is set to 0
  ;
  ; we have to figure out if enemy should even be rendered. 
  EnemyShouldRender:   
    
    ; transpose X. First check if enemy is on the current screen or the next
    .transposeX:
      LDA enemyScreen
      CMP scroll + $01
      BEQ .currentScreen
    
    ; enemy is on the next  screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;   - first calculate A = 255 - scroll + 1. If this overflows,
    ;     it means scroll = 0, i.e. enemy is off screen
    ;   - then calculate A = A + x. Again, overflow means enemy off screen
    ;   - if enemy is off screen, jump to processShooting - we can skip everything until then
    .nextScreen:
      LDA #SCREEN_WIDTH
      SEC
      SBC scroll
      CLC
      ADC #$01
      BCS .enemyOffScreen
      ADC genericX
      BCS .enemyOffScreen
      STA genericX
      JMP EnemyProcessConsts
      
      ; enemy off screen, no need to check for collisions
      .enemyOffScreen:
        DEC enemyOnScreen
        JMP EnemyProcessShooting
    
    ; enemy is on the current screen. Transpose logic:
    ;   - x' = x - low byte of scroll
    ;   - if x' < 0 (carry cleared after the subtraction), set genericOffScreen to 1
    ;     - we then have to check the width from the const data to see if enemy is truly on screen
    ;     - logic: A = width + generic X
    ;     - if carry not set - off screen
    ;     - else if result < 8 (sprite width) - off screen
    ;     - else - on screen
    .currentScreen:
      LDA genericX
      SEC
      SBC scroll
      STA genericX
      BCS EnemyProcessConsts
      INC genericOffScreen
      CLC
      ADC EnemyConsts, y
      BCC .enemyOffScreen
      CMP #SPRITE_DIMENSION
      BCC .enemyOffScreen

  ; time to process the consts (we've only loaded the width above).
  EnemyProcessConsts:    
        
    ; first we'll use the next 2 bytes to calculate the hitbox X positions
    ; bytes in order: x off, width. We'll store the result in ax1 and ax2
    ; if hitbox is offscreen, we'll set enemyCollisions to 0 (currently it's at 1)
    ; but first do a Y += 1 to skip the width and point at hitbox x off
    .hitboxX:  
      INY
      LDA genericOffScreen
      BEQ .hitboxXOnScreen
      
      ; if off screen:
      ;   - load generic X
      ;   - add hitbox X offset
      ;   - if carry clear, it means the box starts at the previous screen
      .hitboxXOffScreen:
        LDA genericX
        CLC
        ADC EnemyConsts, y        
        BCC .hitboxXPartiallyOffscreen
      
        ; box fully on screen, A still holds calculated x1
        ;   - set x1
        ;   - Y += 1 to point at hitbox width
        ;   - x2 = x1 + width
        .hitboxXFullyOnScreen:
          STA ax1
          INY
          CLC
          ADC EnemyConsts, y
          STA ax2
          JMP .hitboxY
        
        ; box partially off screen, A still holds calculated x1
        ;   - Y += 1 to point at hitbox width
        ;   - x2 = x1 + width, if carry clear it means hitbox is off screen - jump to .noCollisions
        ;   - x1 = 0
        .hitboxXPartiallyOffscreen:
          INY
          CLC
          ADC EnemyConsts, y
          BCC .noCollisions
          STA ax2
          LDA #$00
          STA ax1
          JMP .hitboxY
      
        ; we reach this code if we decide hitbox is off screen
        ; .gunPosition expects Y to point to screen width
        ; we sometimes have to do an INY to skip to hitbox width,
        ; and we always have to do two INYs to skip hitbox y vars
        .noCollisionsIny:
          INY
        .noCollisions:
          INY
          INY
          DEC enemyCollisions
          JMP .gunPosition
      
      ; if on screen:
      ;   - load generic X
      ;   - add hitbox X offset
      ;   - if carry set - don't check collisions
      ;   - Y += 1 to point at hitbox width
      ;   - add hitbox width
      ;   - if carry set - cap at screen width 
      .hitboxXOnScreen:
        LDA genericX
        CLC
        ADC EnemyConsts, y
        BCS .noCollisionsIny
        STA ax1
        INY
        CLC
        ADC EnemyConsts, y
        BCS .capX2
        STA ax2
        JMP .hitboxY
        
        .capX2:
          LDA #SCREEN_WIDTH
          STA ax2
       
    ; use the next 2 bytes (y off, height) to calculate hitbox Y positions.
    ; store the result in ay1 and ay2. no special logic here.
    ; we expect Y to point to the hitbox width when we get here
    ; first do a Y += 1 since Y is still pointing at hitbox width
    .hitboxY:
      INY
      LDA genericY
      CLC
      ADC EnemyConsts, y
      STA ay1
      INY
      CLC
      ADC EnemyConsts, y
      STA ay2      
      
    ; get the position of the gun.
    ; we expect Y to point to the hitbox height when we get here
    ;
    ; the next 4 const bytes are:
    ;  - gun x off
    ;  - gun y off
    ;  - gun x off (flip)
    ;  - gun y off (flip)
    ;    
    ; first do Y += 1 to point to x off
    ; then check direction, and set enemyGunX and enemyGunY to a right const value.
    ; make sure we do Y += 4 (5 including the initial one) to point to animation speed.
    .gunPosition:
      INY
      LDA genericDirection
      BEQ .gunPositionNoFlip
      
      .gunPositionFlip:
        INY
        INY
        LDA EnemyConsts, y
        STA enemyGunX
        INY
        LDA EnemyConsts, y
        STA enemyGunY
        INY
        JMP .animationConsts
      
      .gunPositionNoFlip:
        LDA EnemyConsts, y
        STA enemyGunX
        INY
        LDA EnemyConsts, y
        STA enemyGunY
        INY
        INY
        INY            
    
    ; cache animation consts.
    ; this expects Y to point to the animation speed
    ; two bytes are: animation speed and number of frames
    .animationConsts:
      LDA EnemyConsts, y
      STA enemyAnimationSpeed
      INY
      LDA EnemyConsts, y
      STA enemyFrameCount
      INY
            
    ; cache the render pointer in generic pointer
    ; when we get here, Y points to the pointer already
    .renderPointer:
      LDA EnemyConsts, y
      STA genericPointer
      INY
      LDA EnemyConsts, y
      STA genericPointer + $01
    
  ; when we get here, X points to remaining life.
  ; check for collisions between the enemy and the player,
  ; and between the enemy and player's bullets.
  EnemyCheckCollisions:
  
    ; check if collisions should be checked.
    ; POI - possible optimization - branch order
    LDA enemyCollisions
    BNE .collisionWithPlayer
    JMP EnemyProcessShooting
  
    ; only check for collisions if player  state == 0 (PLAYER_NORMAL)
    .collisionWithPlayer:
      LDA playerState
      BEQ .collisionWithPlayerCheck
      JMP .collisionWithBullets
      
      ; load player's threat box into the 'b' vars and check for collisions.
      ; explode player if collision detected ('collision' not 0 after CheckForCollision).
      .collisionWithPlayerCheck:
        LDA playerThreatBoxX1
        STA bx1
        LDA playerThreatBoxX2
        STA bx2
        LDA playerThreatBoxY1
        STA by1
        LDA playerThreatBoxY2
        STA by2
        JSR CheckForCollision
        LDA collision
        BEQ .collisionWithBullets
        JSR ExplodePlayer
    
    ; check collisions between the enemy and player's bullets.
    ; use Y to iterate the bullets - we don't need it anymore.
    ; the loop expects A to point to the bullet 4 bytes ahead of the one we want to check.
    .collisionWithBullets:      
      LDA #PLAYER_BULLET_LAST + BULLET_MEMORY_BYTES
      .collisionWithBulletsLoop:
      
        ; subtract bullet size, and store it in y and yPointerCache
        SEC
        SBC #BULLET_MEMORY_BYTES
        STA yPointerCache
        TAY
        
        ; check the state, we only want to check bullets that either are active or just spawned.
        ; first check if state == 0 (BULLET_S_NOT_EXIST), then check if it's < BULLET_S_SMTH_HIT (3).
        ; that means it's either 1 (BULLET_S_JUST_SPAWNED) or 2 (BULLET_S_NORMAL).
        LDA bullets, y
        BEQ .collisionWithBulletsLoopCheck
        CMP #BULLET_S_SMTH_HIT
        BCS .collisionWithBulletsLoopCheck
        
        ; bullet is active. Load it's hitbox into 'b' vars.
        ; first Y += 1 to point to direction, then branch off that (GENERIC_DIR_LEFT = 0).
        ; we only care about vertical/horizontal
        INY
        LDA bullets, y
        BEQ .bulletGoingHorizontally
        CMP #GENERIC_DIR_RIGHT  
        BEQ .bulletGoingHorizontally
        
        ; based on the direction, set hitbox width and height.
        ; use genericDX for width and genericDY for height as they are not needed anymore.
        .bulletGoingVertically:
          LDA #BULLET_HEIGHT
          STA genericDX
          LDA #BULLET_WIDTH
          STA genericDY
          JMP .bulletSetHitbox
        
        .bulletGoingHorizontally:
          LDA #BULLET_WIDTH
          STA genericDX
          LDA #BULLET_HEIGHT
          STA genericDY
          
        ; set hitbox
        ; first do Y += 1 to point to the x position, set that in bx1, calculate bx2 (cap at screen width)
        ; then do Y += 1 to point to the y position, set that in by1, calculate by2
        .bulletSetHitbox:
          INY
          LDA bullets, y
          STA bx1
          CLC
          ADC genericDX
          BCS .capBX2
          STA bx2
          JMP .setYBox
          
          .capBX2:
            LDA #SCREEN_WIDTH
            STA bx2
          
          .setYBox:
            INY
            LDA bullets, y
            STA by1
            CLC
            ADC genericDY
            STA by2
        
        ; now check for a collision
        .bulletCheckCollision:
          JSR CheckForCollision
          LDA collision
          BEQ .collisionWithBulletsLoopCheck
            
        ; collision detected
        .bulletCollision:
          
          ; first check if remaining life > 0. decrement it if yes, and inc enemyHit
          ; set removeEnemy to 1 if remaining life decremented to 0
          .updateRemainingLife:
            LDA enemies, x
            BEQ .explodeBullet
            INC enemyHit
            DEC enemies, x
            BNE .explodeBullet
            INC removeEnemy
          
          ; now explode the bullet by loading the cached state pointer and setting it to BULLET_S_SMTH_HIT
          .explodeBullet:
            LDY yPointerCache
            LDA #BULLET_S_SMTH_HIT
            STA bullets, y
        
        ; loop check - load yPointerCache, if it's 0 - exit (PLAYER_BULLET_FIRST)
        .collisionWithBulletsLoopCheck:
          LDA yPointerCache
          BEQ EnemyProcessShooting
          JMP .collisionWithBulletsLoop
        
    
  ; When we get here, we expect X to point to remaining life.
  ; X += 1 to point to the current shooting timer
  ; load it, if it's 0 it means the enemy doesn't shoot
  ; otherwise DEC the timer, if it's 0 the enemy should shoot
  EnemyProcessShooting:
    INX
    LDA enemies, x
    BEQ .enemyDoesntShoot
    DEC enemies, x
    BEQ .enemyShoot
    
    ; enemy doesn't shoot - X += 2 to point to the animation timer, then jump to EnemyProcessAnimation
    .enemyDoesntShoot:
      INX
      INX
      JMP EnemyProcessAnimation

    ; enemy should shoot.
    ; first do X += 1 to point to the shooting frequency, load it, do X -= 1
    ; and store it to reset the shooting timer. then do X += 2 to point to the animation timer.33
    .enemyShoot:
      INX
      LDA enemies, x
      DEX
      STA enemies, x
      INX
      INX
    
    ; check if we're even rendering the enemy, don't shoot if not
    .shootingEnemyOnScreen:
      LDA enemyOnScreen
      BEQ EnemyProcessAnimation
    
    ; enemyGunX and enemyGunY are currently set to gun offsets.
    ; add genericX and genericY to them to get the actual position to spawn the bullet.
    ; when calculating enemyGunX, make sure the gun is on screen.    
    .calculateGunX:    
      LDA genericOffScreen
      BEQ .calculateGunXEnemyOnScreen
      
      ; enemy is off screen
      ;  - if gunXOff < 0 (BMI), don't spawn the bullet
      ;  - otherwise, make sure carry is set (i.e. overflow happens and gun is on screen)
      .calculateGunXEnemyOffScreen:
        LDA enemyGunX
        BMI EnemyProcessAnimation
        
      .addMakeSureCarrySet:
        CLC
        ADC genericX
        BCC EnemyProcessAnimation
        STA enemyGunX
        JMP .calculateGunY
      
      ; enemy is on screen
      ;  - if gunXOff < 0 (BMI), make sure carry is set (it's not set if e.g. genericX = 5 and gunXOff = -10 = F6, F6 + 5 = FB = -5)
      ;  - otherwise, make sure carry is not set (i.e. overflow doesn't happen and gun stays on screen)
      .calculateGunXEnemyOnScreen:
        LDA enemyGunX
        BMI .addMakeSureCarrySet
        
        .addMakeSureCarryNotSet:
          CLC
          ADC genericX
          BCS EnemyProcessAnimation
          STA enemyGunX
            
    ; calculating gun y is straightforward - make sure an enemy is never put high enough on the screen to shoot off screen
    .calculateGunY:
      LDA enemyGunY
      CLC
      ADC genericY
      STA enemyGunY
      
    ; spawn enemy bullet using enemyGunX, enemyGunY, enemyOrientation, genericDirection:
    ;   - enemyGunX, enemyGunY - point to spawn the bullet at
    ;   - enemyOrientation - first bit set means shoot horizontally, else shoot vertically (see comment in .calculateDiffs)
    ;   - genericDirection - 0 means shoot right or down, 1 means shoot left or up (depending on orientation)
    SpawnEnemyBullet:
      
      ; first find a free slot, look for BULLET_S_NOT_EXIST == 0
      LDY #ENEMY_BULLET_LAST
      .findFreeSlotLoop:    
        LDA bullets, y
        BEQ .freeSlotFound
        CPY #ENEMY_BULLET_FIRST
        BEQ EnemyProcessAnimation
        DEY
        DEY
        DEY
        DEY
        JMP .findFreeSlotLoop

      ; free slot found, Y points to it
      ; memory layout: state, direction, x, y
      .freeSlotFound:
        
        ; state = just spawned
        .setBulletState:
          LDA #BULLET_S_JUST_SPAWNED
          STA bullets, y
          
        ; get bullet direction based on enemyOrientation and genericDirection (see comment above)
        .setBulletDirection:
          INY
          LDA enemyOrientation
          AND #%00000001
          BEQ .bulletDirectionVertical
          
          .bulletDirectionHorizontal:
            LDA genericDirection
            BEQ .bulletDirectionRight
            
            .bulletDirectionLeft:
              LDA #GENERIC_DIR_LEFT
              JMP .setBulletDirectionValue
          
            .bulletDirectionRight:
              LDA #GENERIC_DIR_RIGHT
              JMP .setBulletDirectionValue
          
          .bulletDirectionVertical:
            LDA genericDirection
            BEQ .bulletDirectionDown
            
            .bulletDirectionUp:
              LDA #GENERIC_DIR_UP
              JMP .setBulletDirectionValue
            
            .bulletDirectionDown:
              LDA #GENERIC_DIR_DOWN
          
          ; A = direction when we get here
          .setBulletDirectionValue:
            STA bullets, y
        
        ; set x position
        .setBulletX:
          INY
          LDA enemyGunX
          STA bullets, y

        ; set y position
        .setBulletY:
          INY
          LDA enemyGunY
          STA bullets, y          
        
  ; when we get here, X points to the animation timer.
  ; next byte is the current animation frame.
  ; decrement the timer, if it equals 0: reset it to enemyAnimationSpeed
  ; and decrement the frame, if it equals 0: reset it to enemyFrameCount
  ; make sure genericFrame is set to the current frame at the end
  ;
  ; but first check if enemy should even be rendered.
  ; this means enemies off screen may not have their animation cycles in sync,
  ; but makes sure we don't have to load consts for enemies off screen.
  ; if we want to process animation for enemies off screen,
  ; the skip in .enemyOffScreen must be updated.
  EnemyProcessAnimation:
    LDA enemyOnScreen
    BEQ UpdateActiveEnemyDone
    DEC enemies, x
    BEQ .updateFrame
    INX
    LDA enemies, x
    STA genericFrame
    JMP EnemyRender
    
    .updateFrame:
      LDA enemyAnimationSpeed
      STA enemies, x
      INX
      DEC enemies, x
      BEQ .resetFrame
      LDA enemies, x
      STA genericFrame
      JMP EnemyRender
      
    .resetFrame:
      LDA enemyFrameCount
      STA enemies, x
      STA genericFrame
  
  ; render the enemy (only if not flashing)
  EnemyRender:
    LDA enemyNotFlashing
    BEQ UpdateActiveEnemyDone
    JSR RenderEnemy
   
  UpdateActiveEnemyDone:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   UpdateExplodingEnemy                                        ;
;                                                               ;
; Description:                                                  ;
;   Updates an exploding enemy pointed to by the X register     :
;   X register points to the state on input                     ;
;   xPointerCache can also be used to go back to the top        ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;   generic vars                                                ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   h                                                           ;
;   i                                                           ;
;   j                                                           ;
;   remove enemy - set to 1 if enemy should be removed          ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************
    
UpdateExplodingEnemy:
  
  ; X += 4 to point to the screen the enemy is on, load it and put it in enemyScren
  .loadScreen:
    INX
    INX
    INX
    INX
    LDA enemies, x
  
  ; X += 6 to point to the X position, load the X position and put it in genericX
  .loadX:
    TXA
    CLC
    ADC #$06
    TAX
    LDA enemies, x
    STA genericX
  
  ; transpose X. First check if enemy is on the current screen or the next
  .transposeX:    
    LDA enemyScreen
    CMP scroll + $01
    BEQ .currentScreen
    
    ; enemy is on the next  screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;   - first calculate A = 255 - scroll + 1. If this overflows,
    ;     it means scroll = 0, i.e. ememy is off screen
    ;   - then calculate A = A + x. Again, overflow means enemy off screen
    ;   - if enemy is off screen, explosion can be removed
    .nextScreen:
      LDA #SCREEN_WIDTH
      SEC
      SBC scroll
      CLC
      ADC #$01
      BCS .enemyOffScreen
      ADC genericX
      BCS .enemyOffScreen
      STA genericX
      JMP .loadY
      
      ; enemy off screen, explosion can be removed
      .enemyOffScreen:
        INC removeEnemy
        RTS
    
    ; enemy is on the current screen. Transpose logic:
    ;   - x' = x - low byte of scroll
    ;   - if x' < 0 (carry cleared after the subtraction), set genericOffScreen to 1
    ;     - we then have to check the width from the const data to see if enemy is trully on screen
    ;     - logic: A = width + generic X
    ;     - if carry not set - off screen
    ;     - else if result < 8 (sprite width) - off screen
    ;     - else - on screen
    .currentScreen:
      LDA genericX
      SEC
      SBC scroll
      STA genericX
      BCS .loadY
      INC genericOffScreen
      CLC
      ADC #EXPLOSION_WIDTH
      BCC .enemyOffScreen
      CMP #SPRITE_DIMENSION
      BCC .enemyOffScreen
    
  ; X += 1 to point to the y position, load it and store in genericY
  .loadY:
    INX
    LDA enemies, x
    STA genericY
      
  ; X += 4 to point to the animation timer, decrement it, check if 0
  .processAnimation:
    INX
    INX
    INX
    INX
    DEC enemies, x
    BEQ .timerIs0
    
    ; timer is not 0, X += 1 to point to the animation frame, set it in genericFrame
    .timerIsNot0:
      INX
      LDA enemies, x
      STA genericFrame
      JMP .renderExplosion
          
    ; timer is 0, reset it to max, then X += 1 to point to the animation frame and dec it
    ; if not 0, load it and set in genericFrame. if 0, it means animation completed.
    .timerIs0:
      LDA #EXPLOSION_ANIM_SPEED
      STA enemies, x
      INX
      LDA enemies, x
      SEC
      SBC #$01
      BEQ .explosionCompleted
      STA enemies, x
      STA genericFrame      
          
  ; all vars are set, render the explosion then exit
  .renderExplosion:
    JSR RenderExplosion    
    RTS
    
  ; explosion completed
  .explosionCompleted:
    INC removeEnemy
    RTS

;****************************************************************
; Name:                                                         ;
;   UpdateEnemies                                               ;
;                                                               ;
; Description:                                                  ;
;   Updates all enemies:                                        ;
;     - move                                                    ;
;     - spawn bullets                                           ;
;     - check for collisions                                    ;
;     - render                                                  ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;   generic vars                                                ;
;   enemy vars                                                  ;
;   render vars                                                 ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   h                                                           ;
;   i                                                           ;
;   j                                                           ;
;   remove enemy                                                ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************

UpdateEnemies:

  ; main loop - loop all enemies going down
  ; load the place pointing to after the last enemy, store it in xPointerCache
  ; the loop expects value in the A register to point to the enemy after the one we want to process
  LDA #AFTER_LAST_ENEMY
  .updateEnemyLoop:         

    ; move A to point to the next enemy we want to process. Cache that value in xPointerCache and store it in X
    SEC
    SBC #ENEMY_SIZE
    STA xPointerCache
    TAX                  

    ; set enemyHit and removeEnemy to 0
    LDA #$00
    STA removeEnemy
    STA enemyHit
    
    ; X now points to the state. Check it:
    ;   0 == ENEMY_STATE_EMPTY
    ;   1 == ENEMY_EXPLODING
    ; else: 2+ == ENEMY_STATE_ACTIVE
    LDA enemies, x       
    BEQ .enemyEmpty
    CMP #ENEMY_STATE_EXPLODING
    BEQ .enemyExploding
    
    ; active enemy - call into a subroutine, jump to the loop condition
    .enemyActive:
      JSR UpdateActiveEnemy
      
      ; check if enemy should be exploded
      .checkRemoveEnemyActive:
        LDA removeEnemy
        BEQ .checkIfEnemyHit
        
        ; explode the enemy.
        
        ; update state:
        .explodeEnemyState:
          LDX xPointerCache
          LDA #ENEMY_STATE_EXPLODING
          STA enemies, x        
      
        ; mark the enemy as destroyed
        ; X += 1 to point to the first byte of id, load that in Y, then load the right byte
        ; X += 1 to point to the second byte of id, ORA, store destroyedEnemies
        .markEnemyAsDestroyed:
          INX
          LDY enemies, x
          LDA destroyedEnemies, y
          INX
          ORA enemies, x
          STA destroyedEnemies, y
          
        ; X += 1 to point at the consts pointer
        ; load the pointer then do += 13 to point to the consts data. store in Y.
        .loadConstsPointer:
          INX
          LDA enemies, x
          CLC
          ADC #$0D
          TAY
          
        ; X += 7 to point to the X position, update x using x off from consts.
        ; X += 1 to point to the Y position, Y += 1, update y using y off from consts
        .updatePosition:
          TXA
          CLC
          ADC #$07
          TAX
          LDA enemies, X
          CLC
          ADC EnemyConsts, y
          STA enemies, X
          INX
          INY
          LDA enemies, X
          CLC
          ADC EnemyConsts, y
          STA enemies, X
          
        ; X += 4 to point to the animation timer, set it to the const expl. speed.
        ; X += 1 to point to the animation frame, set it to the const expl. frame count
        .updateAnimation:
          INX
          INX
          INX
          INX
          LDA #EXPLOSION_ANIM_SPEED
          STA enemies, x
          INX
          LDA #EXPLOSION_ANIM_FRAMES
          STA enemies, x
        
        ; enemy exploded, jump to the loop condition
        JMP .updateEnemyLoopCondition
      
        ; check if enemy was hit and state should be updated to flashing
        .checkIfEnemyHit:
          LDA enemyHit
          BEQ .updateEnemyLoopCondition
          LDX xPointerCache
          LDA #ENEMY_STATE_HIT
          STA enemies, x     
          JMP .updateEnemyLoopCondition
      
    ; enemy exploding - call into a subroutine, let flow to the empty clause
    .enemyExploding:
      JSR UpdateExplodingEnemy
      
      ; check if enemy should be removed from the game
      .checkRemoveEnemyExploding:
        LDA removeEnemy
        BEQ .updateEnemyLoopCondition
        
        ; remove enemy from the game
        .removeEnemy:
          LDX xPointerCache
          LDA #ENEMY_STATE_EMPTY
          STA enemies, x        
          JMP .updateEnemyLoopCondition ; POI - possible optimization - skip the LDA xPointerCache ?
      
    ; enemy empty - do nothing, let flow into the loop condition
    .enemyEmpty:      
    
      ; loop condition - if we've not just processed the last enemy, loop.   
      ; otherwise exit
      ; POI - possible optimization - can this loop be done better?
      .updateEnemyLoopCondition:
        LDA xPointerCache      
        BEQ .updateEnemyExit
        JMP .updateEnemyLoop
  
  .updateEnemyExit:
    RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadEnemiesInitial                                          ;
;                                                               ;
; Description:                                                  ;
;   Loads enemies for screen 0 and 1, sets the enemiesPointer   ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer - set to the start of the enemies data       ;
;                                                               ;
; Output variables:                                             ;
;   enemiesPointer - set to the enemies data for screen 1       ;
;   genericPointer - set to the first byte after enemies data   ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadEnemiesInitial:
  
  .screensToSkip:
    LDA maxScroll + $01                ; see LoadPlatformsAndThreats for explanation of this logic
    CLC
    ADC #$02
    STA b
                                       
  .setEnemiesPointer:                 
    LDA genericPointer                 
    STA enemiesPointer               
    LDA genericPointer + $01           
    STA enemiesPointer + $01           ; enemiesPointer set to enemies for screen 0
  
  .moveEnemiesPointerLoop:
    JSR MoveEnemiesPointerForward      ; move enemiesPointer forward
    DEC b
    BNE .moveEnemiesPointerLoop        ; after this loop, enemiesPointer set to the first byte after enemies data
    
  .setGenericPointer:
    LDA genericPointer
    STA b
    LDA genericPointer + $01
    STA c                              ; cache genericPointer (still pointing to the start of the data) in b c
    LDA enemiesPointer
    STA genericPointer
    LDA enemiesPointer + $01
    STA genericPointer + $01           ; genericPointer now points to the first byte after enemies data
    LDA b
    STA enemiesPointer
    LDA c
    STA enemiesPointer + $01           ; enemiesPointer now points to the first byte of the enemies data
    
  .loadEnemies:
    JSR LoadEnemies                    ; load enemies for screen 0
    JSR MoveEnemiesPointerForward
    JSR LoadEnemies                    ; load enemies for screen 1

  RTS                                  ; enemies loaded, pointer points to screen 1 as expected

;****************************************************************
; Name:                                                         ;
;   LoadEnemiesForward                                          ;
;                                                               ;
; Description:                                                  ;
;   Load enemies for the screen in the front,                   ;
;   also moves the enemies pointer forward                      ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadEnemiesForward:
 
  ; say we're moving from screen 2 to 3 - in that case we want to load enemies for screen 4
  ; at this point, enemiesPointer is pointing to screen 3, so we must move it forward
  ;
  ; but first we need to unload enemies for screen 2 - when this is called, screen is already set to 3,
  ; so we want to unload enemies for "screen - 1"
 
  .unloadEnemies:
    LDA scroll + $01
    SEC
    SBC #$01
    STA b                             ; b = screen - 1
    JSR UnloadEnemies                 ; unload enemies
 
  .loadEnemiesAndUpdatePointer:
    JSR MoveEnemiesPointerForward     ; move pointer forward
    JSR LoadEnemies                   ; load enemies

  RTS  
  
;****************************************************************
; Name:                                                         ;
;   LoadEnemiesBack                                             ;
;                                                               ;
; Description:                                                  ;
;   Load enemies for the screen in the back,                    ;
;   also moves the enemies pointer back                         ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   i                                                           ;
;****************************************************************

LoadEnemiesBack:

  ; say we're moving from screen 3 to 2 - in that case we want to load enemies for screen 2
  ; at this point, enemiesPointer is pointing to screen 4, so we must move it back twice, load,
  ; then move it forward once so it points to screen 3 as expected
  ;
  ; but first we need to unload enemies for screen 4 - when this is called, screen is already updated to 2,
  ; so we want to unload enemies for "screen + 2"

  .unloadEnemies:
    LDA scroll + $01
    CLC
    ADC #$02
    STA b                             ; b = screen + 1
    JSR UnloadEnemies                 ; unload enemies
 
  .loadEnemiesAndUpdatePointer:
    JSR MoveEnemiesPointerBack
    JSR MoveEnemiesPointerBack        ; move pointer back twice
    JSR LoadEnemies                   ; load enemies
    JSR MoveEnemiesPointerForward     ; move pointer forward
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadEnemies                                                 ;
;                                                               ;
; Description:                                                  ;
;   Load enemies from enemiesPointer                            ;
;                                                               ;
; Input variables:                                              ;
;   enemiesPointer - enemies to load                            ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   X                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_level_data_format                       ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************

LoadEnemies:
  
  ; first Y += 1 to skip the pointer to the next screen.
  ; then load the number of enemies, exit if 0, store in b
  .loadEnemiesCount:  
    LDY #$01
    LDA [enemiesPointer], y
    BEQ .loadEnemiesExit
    STA b
   
   ; loop for loading enemies
  .loadEnemiesLoop:
  
    ; Y += 1 to point to the first id byte.
    ; load it, then cache it in c
    ; Y += 1 to point to the second id byte.
    ; load it, then cache it in d
    ; then check if the enemy should be loaded
    .cacheId:
      INY
      LDA [enemiesPointer], y
      STA c
      INY
      LDA [enemiesPointer], y
      STA d
      
    ; check if the enemy has been destroyed.
    ; we can use X here as it's not used until .getSlot.
    ; load the right byte for the enemy, then AND it with the mask.
    ; result == 1 means the enemy has been destroyed - skip the enemy.
    ; we must do Y += 13 though to make sure we point to the right place.
    .checkId:
      LDX c
      LDA destroyedEnemies, x
      AND d
      BEQ .getSlot
      TYA
      CLC
      ADC #$0D
      TAY
      JMP .loadEnemiesLoopCondition
    
    ; load the slot the enemy should be put it, and store it in X = the pointer in memory.
    .getSlot:
      INY
      LDA [enemiesPointer], y
      TAX
    
    ; X points to the state, set it to "active"
    .setState:
      LDA #ENEMY_STATE_ACTIVE
      STA enemies, x
    
    ; X += 1 to point to the first id byte, then set it to the value cached in c
    ; then X += 1 to point to the second id byte, then set it to the value cached in d
    .setId:
      INX
      LDA c
      STA enemies, x
      INX
      LDA d
      STA enemies, x
    
    ; next 12 bytes are the sane in both definitions:
    ; pointer, screen, speed, distance, direction, distance left, flip, x, y, life, shooting freq, shooting timer
    ; c will be the loop pointer (no longer needed), copy the 12 bytes incrementing Y and X in each loop
    LDA #$0C
    STA c
    .copyLoop:
      INY
      LDA [enemiesPointer], y
      INX
      STA enemies, x
      DEC c
      BNE .copyLoop
    
    ; next two bytes are the animation vars, set both to 1 (so they'll loop to the beginning the next frame)
    ; do X += 1 before each set to point to the right place
    .setAnimationVars:
      LDA #$01                    
      INX
      STA enemies, x
      INX
      STA enemies, x
    
    ; loop if needed
    .loadEnemiesLoopCondition:
      DEC b
      BNE .loadEnemiesLoop
          
  .loadEnemiesExit:
    RTS
  
;****************************************************************
; Name:                                                         ;
;   UnloadEnemies                                               ;
;                                                               ;
; Description:                                                  ;
;   Unloads enemies for given screen                            ;
;                                                               ;
; Input variables:                                              ;
;   b - screen to unload the enemies for                        ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************

UnloadEnemies:

  LDX #LAST_ENEMY_SCREEN           ; loop all enemies going down  
  LDA #ENEMIES_COUNT
  STA c                            ; c is the loop counter
  
  .unloadEnemyLoop:
  
    LDA enemies, x                 ; load the screen the enemy is on
    CMP b
    BNE .loopCondition             ; if screen != b, don't do anything
    
    .unloadEnemy:
      DEX
      DEX
      DEX
      DEX                          ; x points to the state
      LDA #ENEMY_STATE_EMPTY
      STA enemies, x               ; unload the enemy
      INX
      INX
      INX
      INX                          ; x points back to the screen
    
    .loopCondition:
      TXA                          
      SEC
      SBC #ENEMY_SIZE
      TAX                          ; decrement the pointer 
      DEC c                        ; decrement the loop counter
      BNE .unloadEnemyLoop         
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveEnemiesPointerForward                                   ;
;                                                               ;
; Description:                                                  ;
;   Moves the enemies pointer forward                           ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;****************************************************************

MoveEnemiesPointerForward:
  LDY #$00
  LDA [enemiesPointer], y
  CLC
  ADC enemiesPointer
  STA enemiesPointer
  LDA enemiesPointer + $01
  ADC #$00
  STA enemiesPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveEnemiesPointerBack                                      ;
;                                                               ;
; Description:                                                  ;
;   Moves the enemies pointer back                              ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   i                                                           ;
; POI - possible optimization - is the 'i' var needed?          ;
;****************************************************************

MoveEnemiesPointerBack:
  LDA enemiesPointer
  SEC
  SBC #$01
  STA enemiesPointer
  LDA enemiesPointer + $01
  SBC #$00
  STA enemiesPointer + $01
  LDY #$00
  LDA [enemiesPointer], y
  STA i
  LDA enemiesPointer
  SEC
  SBC i
  STA enemiesPointer
  LDA enemiesPointer + $01
  SBC #$00
  STA enemiesPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   RenderEnemy                                                 ;
;                                                               ;
; Description:                                                  ;
;   Renders an enemy                                            ;
;                                                               ;
; Input variables:                                              ;
;   Generic vars:                                               ;
;     genericX, genericY, genericOffScreen - position           ;
;     genericFrame - frame to render                            ;
;     genericDirection - flip (0 = no flip, 1 = flip)           ;
;     genericPointer - pointing to the enemy (from enemies.asm) ;
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
;   j                                                           ;
;   k                                                           ;
;****************************************************************

RenderEnemy:

  ; First process the definition and set:
  ;   b   = tiles count
  ;   c   = atts XOR
  ;   d,e = x off pointer
  ;   f,g = y off pointer
  ;   h,i = atts pointer
  ;   j,k = tiles pointer

  .getSpriteCount:
    LDY #$00                    ; Y points to the sprite count  
    LDA [genericPointer], y
    STA b                       ; b = sprite count (N)
    INY                         ; Y points to xOff
  
  .checkFlip:
    LDA genericDirection    
    BEQ .noFlip                 ; RENDER_ENEMY_NO_FLIP == 0
  
  .flip:                        ;  flip, use the last two pointers
    INY
    INY
    INY
    INY                         ; skip the first four bytes
    LDA [genericPointer], y     ; x off low flip
    STA d
    INY
    LDA [genericPointer], y     ; x off high flip
    STA e
    INY
    LDA [genericPointer], y     ; y off low flip
    STA f
    INY
    LDA [genericPointer], y     ; y off high flip
    STA g
    INY                         ; Y points at the flip atts XOR
    LDA [genericPointer], y
    STA c                       ; store the atts XOR in c
    JMP .setAttsPointer
  
  .noFlip:                      ; no flip, use the first two pointers
    LDA [genericPointer], y     ; x off low
    STA d
    INY
    LDA [genericPointer], y     ; x off high
    STA e
    INY
    LDA [genericPointer], y     ; y off low
    STA f
    INY
    LDA [genericPointer], y     ; y off high
    STA g
    INY
    INY
    INY
    INY                         ; skip the next four bytes
    INY                         ; Y points at the flip atts XOR
    LDA #$00
    STA c                       ; set c to 0 (nothing to XOR with atts because no flip)   
    
  .setAttsPointer:
    INY                         ; Y points to the atts
    TYA                         ; move Y to A
    CLC
    ADC genericPointer          ; move the generic pointer
    STA genericPointer          ; lower byte
    STA h                       ; set the same in h
    LDA genericPointer + $01
    ADC #$00                    ; add carry
    STA genericPointer + $01    ; higher byte
    STA i                       ; set the same in i
         
  .movePointerToTiles:
    LDA #$00                    ; A = 0
    LDY genericFrame            ; frames count down, so if animation has 4 frames, it's 4 -> 3 -> 2 -> 1    
    .movePointerLoop:           ; last frame is first in the definition etc.
      CLC                       ; we have to skip the atts though, so if genericFrame = 1 (render last frame), skip N bytes
      ADC b                     ; if genericFrame = 2 (next to last frame), skip N * 2 bytes
      DEY                       ; so basically skip N * genericFrame bytes
      BNE .movePointerLoop
  
  .setTilesPointer:             ; when we get here, A = N * genericFrame
    CLC
    ADC genericPointer          ; move the generic pointer
    ;STA genericPointer         ; lower byte, not needed anymore
    STA j                       ; set the same in j
    LDA genericPointer + $01
    ADC #$00                    ; add carry
    ;STA genericPointer + $01   ; higher byte, not needed anymore
    STA k                       ; set the same in k
    
  .resetRegisters:
    LDY #$00                    ; y will be the sprite counter, start with 0
    
  .renderTileLoop:              ; main rendering loop
  
    .checkXPosition:            ; this part checks if we want to render the tile based on the X position
      LDA [d], y                ; load the x offset
      CLC
      ADC genericX              ; A = X position
      STA renderXPos            ; set renderXPos
      BCS .tileOffScreen        ; if carry is not set it means the tile is on screen. Otherwise it's off screen      
                                
      .tileOnScreen:
        LDA genericOffScreen    ; if we got here it means tile is fully on screen
        BNE .loopCheck          ; only render it if genericOffScreen == 0
        JMP .renderTile
      
      .tileOffScreen:           
        LDA genericOffScreen    ; if we got here it means tile is fully off screen
        BEQ .loopCheck          ; only render if genericOffScreen == 1
      
   .renderTile:                 ; if we got here we want to render the tile
     LDA [f], y                 ; load the y offset
     CLC    
     ADC genericY               ; A = Y position
     STA renderYPos             ; set renderYPos
     LDA [h], y                 ; load the atts
     EOR c                      ; atts XOR
     STA renderAtts             ; set renderAtts
     LDA [j], y                 ; load the tile
     STA renderTile             ; set renderTile
     JSR RenderSprite           ; render the sprite
      
      .loopCheck:
        INY                     ; increment Y. POI - possible optimization - if we are skipping the tile because it's on/off screen,
                                ; if we knew the sprite height, we could skip all of them since they are on a grid. Do this change!
        CPY b                   ; compare Y to tile count. POI - possible optimization - if we counted tiles down, we could do BEQ without the CPY
        BNE .renderTileLoop     ; more tiles to render
         
  RTS
  