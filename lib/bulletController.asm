;****************************************************************
; BulletController                                              ;
; Responsible for spawning and updating bullets                 ;
;****************************************************************

; todo - figure out the way these loops work - too many INX/DEX? cache the pointer value?

;****************************************************************
; Name:                                                         ;
;   SpawnPlayerBullet                                           ;
;                                                               ;
; Description:                                                  ;
;   Spawns player's bullet if possible                          ;
;                                                               ;
; Used variables:                                               ;
;   Generic vars                                                ;
;   X                                                           ;
;****************************************************************
  
SpawnPlayerBullet:

  .checkIfCanFire:
    LDA playerBulletCooldown
    BEQ .getYPosition                 ; cooldown == 0, can fire
    DEC playerBulletCooldown
    RTS

  .getYPosition:                      
    LDA playerAnimation                   
    CMP #PLAYER_CROUCH                
    BEQ .playerCrouching              
                                      
    .playerUp:                        
      LDA playerY                     
      CLC                             
      ADC #PLAYER_GUN_OFF_Y
      BCC .gunOffScreen               ; carry cleared means gun is off screen
      STA genericY
      JMP .getXPositionAndAtts        
                                      
    .gunOffScreen:
      RTS
                                      
    .playerCrouching:                 
      LDA playerY                     
      CLC                             
      ADC #PLAYER_GUN_OFF_Y_C
      BCC .gunOffScreen               ; same as above. POI - possible optimization - probably not needed
      STA genericY
                                      
  .getXPositionAndAtts:               
    LDA playerDirection               
    BEQ .shootLeft                    ; DIRECTION_LEFT = 0
    
    .shootRight:                      
      LDA playerX                     
      CLC                             
      ADC #PLAYER_GUN_OFF_X_R         
      STA genericX
      LDA #GENERIC_DIR_RIGHT
      STA genericDirection
      JMP .spawnBullet
                                      
    .shootLeft:                       
      LDA playerX                     
      CLC                             
      ADC #PLAYER_GUN_OFF_X_L         
      STA genericX
      LDA #GENERIC_DIR_LEFT
      STA genericDirection
      
  .spawnBullet:
    LDX #PLAYER_BULLET_LAST

    .findFreeSlotLoop:      
      LDA playerBullets, x
      BEQ .freeSlotFound              ; BULLET_S_NOT_EXIST == 0
      TXA
      BEQ .noFreeSlots
      DEX
      DEX
      DEX
      DEX
      JMP .findFreeSlotLoop
      
    .noFreeSlots:
      RTS                             ; no free slots
                                      
  .freeSlotFound:                     ; when we get here X points to the first byte of the free slot
    LDA #BULLET_S_JUST_SPAWNED
    STA playerBullets, x
    INX
    LDA genericDirection
    STA playerBullets, x
    INX
    LDA genericX
    STA playerBullets, x
    INX
    LDA genericY
    STA playerBullets, x
    LDA #PLAYER_BULLET_COOLDOWN
    STA playerBulletCooldown
    RTS

;****************************************************************
; Name:                                                         ;
;   UpdateBullets                                               ;
;                                                               ;
; Description:                                                  ;
;   Updates all bullets                                         ;
;    - move                                                     ;
;    - platform & threat collision check                        ;
;    - render                                                   ;
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
;****************************************************************
  
UpdateBullets:

  LDX #TOTAL_BULLET_LAST
  
  .updateLoop:      
    LDA allBullets, x
    BNE .bulletExists                 ; BULLET_S_NOT_EXIST == 0    
    JMP .updateLoopCheck              ; bullet doesn't exist, check the next one
    
    .bulletExists:
      CMP #BULLET_S_SMTH_HIT
      BCC .checkDirection             ; carry clear if state < BULLET_S_SMTH_HIT meaning either normal or just spawned
      
    .bulletExploding:                 ; bullet is exploding
      CLC
      ADC #$01                        ; increment the state by 1
      CMP #BULLET_S_TO_CLEAR          ; check if bullet should be cleared
      BNE .updateExplosion      
      JMP .clearBullet                ; clear the bullet
      
    .updateExplosion:                 ; we should still render the explosion
      STA allBullets, x               ; update state
      AND #%00000011                  ; A = 00, 01, 10 or 11 based on current state
      ROR A
      ROR A
      ROR A                           ; A = 00000000, 01000000, 10000000, 11000000 meaning different rotations
      STA renderAtts                  ; no need to ORA #BULLET_ATTS_E since BULLET_ATTS_E = 0
      INX
      INX                             ; X points to the x position
      LDA allBullets, x
      STA renderXPos                  ; set x position
      INX                             ; X points to they position
      LDA allBullets, x
      STA renderYPos                  ; set y position
      DEX
      DEX
      DEX                             ; X points to state again
      LDA #BULLET_SPRITE_E
      STA renderTile      
      JMP .renderBullet               ; jump to the right place to set tile and atts
      
    .checkDirection:
      STA genericFrame                ; cache the state in the genericFrame variable
      INX                             ; X points to direction        
      LDA allBullets, x 
      STA genericDirection            ; cache the direction in the genericDirection variable   
        
    .moveAndPreset:
      BEQ .goingLeft                  ; GENERIC_DIR_LEFT = 0
      CMP #GENERIC_DIR_RIGHT  
      BEQ .goingRight  
      CMP #GENERIC_DIR_DOWN 
      BEQ .goingDown
      JMP .goingUp
                
      .goingRight:
        INX                           ; X points to x position
        LDA genericFrame
        CMP #BULLET_S_JUST_SPAWNED
        BEQ .dontMoveRight            ; don't move the bullet if just spawned
        LDA allBullets, x
        CLC
        ADC #BULLET_SPEED             ; move bullet left
        BCC .moveRight                ; carry clear if bx1 + bullet speed <= screen width: bullet on screen
        JMP .clearBulletMovePointer2
      
        .dontMoveRight:
          LDA allBullets, x
      
        .moveRight:
          STA allBullets, x           ; update the bullet position
          STA bx1                     ; preset bx1
          STA renderXPos              ; preset render x
          LDA #BULLET_ATTS_RIGHT
          STA renderAtts              ; preset render atts
          JMP .goingHorizontally
        
      .goingLeft:
        INX                           ; X points to x position
        LDA genericFrame
        CMP #BULLET_S_JUST_SPAWNED
        BEQ .dontMoveLeft             ; don't move the bullet if just spawned
        LDA allBullets, x 
        SEC 
        SBC #BULLET_SPEED             ; move bullet left        
        BCS .moveLeft                 ; carry set if bx1 - bullet speed >= 0: bullet on screen
        JMP .clearBulletMovePointer2
      
        .dontMoveLeft:
          LDA allBullets, x 
          
        .moveLeft:
          STA allBullets, x           ; update the bullet position
          STA bx1                     ; preset bx1
          STA renderXPos              ; preset render x
          LDA #BULLET_ATTS_LEFT
          STA renderAtts              ; preset render atts
        
      .goingHorizontally:             ; common for left and right
        LDA #BULLET_SPRITE_H
        STA renderTile                ; preset render tile
        INX                           ; X points to y position
        LDA allBullets, x
        STA by1                       ; preset by1
        STA renderYPos                ; preset render y
        CLC
        ADC #BULLET_HEIGHT            ; height because going horizontally
        STA by2                       ; preset by2
        LDA bx1
        CLC
        ADC #BULLET_WIDTH             ; width because going horizontally
        BCS .boxHCapX2
        STA bx2
        JMP .checkCollisions
        
        .boxHCapX2:
          LDA #SCREEN_WIDTH
          STA bx2
          JMP .checkCollisions
          
      .goingDown:
        INX                           ; X points to x position
        LDA allBullets, x 
        STA bx1                       ; preset bx1
        STA renderXPos                ; preset render x
        INX                           ; X points to y position
        LDA genericFrame
        CMP #BULLET_S_JUST_SPAWNED
        BEQ .dontMoveDown             ; don't move the bullet if just spawned
        LDA allBullets, x
        CLC 
        ADC #BULLET_SPEED             ; move bullet down
        CMP #SCREEN_HEIGHT        
        BCC .moveDown                 ; carry clear if by1 + bullet speed < screen height: bullet on screen
        JMP .clearBulletMovePointer3
        
        .dontMoveDown:
          LDA allBullets, x
        
        .moveDown:
          STA allBullets, x           ; update the bullet position
          STA by1                     ; preset by1
          STA renderYPos              ; preset render y
          LDA #BULLET_ATTS_DOWN 
          STA renderAtts              ; preset render atts
          JMP .goingVertically
        
      .goingUp:
        INX                           ; X points to x position
        LDA allBullets, x 
        STA bx1                       ; preset bx1
        STA renderXPos                ; preset render x
        INX                           ; X points to y position
        LDA genericFrame
        CMP #BULLET_S_JUST_SPAWNED
        BEQ .dontMoveUp               ; don't move the bullet if just spawned
        LDA allBullets, x
        SEC 
        SBC #BULLET_SPEED             ; move bullet up
        BCS .moveUp                   ; carry set if by1 - bullet speed >= 0: bullet on screen
        JMP .clearBulletMovePointer3
      
        .dontMoveUp:
          LDA allBullets, x
      
        .moveUp:
          STA allBullets, x           ; update the bullet position
          STA by1                     ; preset by1
          STA renderYPos              ; preset render y
          LDA #BULLET_ATTS_UP 
          STA renderAtts              ; preset render atts
        
      .goingVertically:               ; common for up and down
        LDA #BULLET_SPRITE_V  
        STA renderTile                ; preset render tile
        LDA by1
        CLC
        ADC #BULLET_WIDTH             ; width because going vertically
        STA by2                       ; preset by2
        LDA bx1
        CLC
        ADC #BULLET_HEIGHT            ; height because going vertically
        BCS .boxVCapX2
        STA bx2
        JMP .checkCollisions         
            
        .boxVCapX2:
          LDA #SCREEN_WIDTH
          STA bx2
            
    .checkCollisions:                 ; when we get here the bullet has been moved in memory, box is set, rendering vars are preset      
      JSR CheckForCollisionsPlatAndTh
      LDA collision
      BEQ .noCollision
      
      ; todo: check for collision with player (for enemy bullets) and enemies (for player bullets)
      
    .collision:
      LDA genericFrame
      CMP #BULLET_S_JUST_SPAWNED
      BNE .collisionCheckDirection
      JMP .clearBulletMovePointer3    ; if the bullet was just spawned and there's a collision, just clear it
    
    .collisionCheckDirection:         ; to update the position we'll use the fact that 'a' boxes position of whatever we hit
      LDA genericDirection
      BEQ .collisionLeft              ; GENERIC_DIR_LEFT = 0
      CMP #GENERIC_DIR_RIGHT  
      BEQ .collisionRight
      CMP #GENERIC_DIR_DOWN 
      BEQ .collisionDown
      
      .collisionUp:                   ; collision going up, meaning bullet y should be set to ay2 + 1
        INC ay2
        LDA ay2
        STA allBullets, x             ; X points to y currently
        STA renderYPos
        JMP .collisionUpdateState3
      
      .collisionDown:                 ; collision going down, meaning bullet y should be set to ay1 - tile size
        LDA ay1
        SEC
        SBC #BULLET_E_HEIGHT
        STA allBullets, x             ; X points to y currently
        STA renderYPos
        JMP .collisionUpdateState3
            
      .collisionLeft:                 ; collision going left, meaning bullet y should be set to ax2 + 1
        DEX                           ; X points to x position
        INC ax2
        LDA ax2
        STA allBullets, x
        STA renderXPos
        JMP .collisionUpdateState2
      
      .collisionRight:                ; collision going right, meaning bullet y should be set to ax1 - tile size
        DEX                           ; X points to x position
        LDA ax1
        SEC
        SBC #BULLET_E_WIDTH
        STA allBullets, x
        STA renderXPos
        JMP .collisionUpdateState2
        
    .collisionUpdateState3:
      DEX
    
    .collisionUpdateState2:
      DEX
      DEX
        
    .collisionUpdateState:
      LDA #BULLET_S_SMTH_HIT
      STA allBullets, x
      LDA #BULLET_SPRITE_E
      STA renderTile
      LDA #BULLET_ATTS_E
      STA renderAtts
      JMP .renderBullet
      
    .noCollision:
      DEX
      DEX
      DEX                             ; X points back to the state
      LDA #BULLET_S_NORMAL
      STA allBullets, x               ; set state to normal in case it's currently just spawned      
      
    .renderBullet:
      STX b                           ; RenderSprite updates X so cache it in b
      DEC renderYPos                  ; todo - temporarily decrement this, figure out what to do about the sprite -1
      JSR RenderSprite
      LDX b                           ; read X back from b
      JMP .updateLoopCheck
      
    .clearBulletMovePointer3:         ; this expects X to point to y position
      DEX
      
    .clearBulletMovePointer2:         ; this expects X to point to the x position
      DEX
      DEX
     
    .clearBullet:                     ; this expects X to point to the state
      LDA #BULLET_S_NOT_EXIST 
      STA allBullets, x 
        
    .updateLoopCheck:                 ; this expects X to point to the state
      TXA
      BEQ .updateDone
      DEX
      DEX
      DEX
      DEX
      JMP .updateLoop
  
  .updateDone:
    RTS

;****************************************************************
; Name:                                                         ;
;   CheckForCollisionsPlatAndTh                                 ;
;                                                               ;
; Description:                                                  ;
;   Checks for both platforms and threats collisions on both    ;
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
  
CheckForCollisionsPlatAndTh:

  .checkFirstPlatformScreen:
    LDA #$00
    STA c
    LDA platformsPointer
    STA genericPointer
    LDA platformsPointer + $01
    STA genericPointer + $01
    JSR CheckForPlatformOneScreen
    LDA collision
    BNE .collisionCheckDone

  .checkFirstThreatScreen:
    LDA threatsPointer
    STA genericPointer
    LDA threatsPointer + $01
    STA genericPointer + $01
    JSR CheckForPlatformOneScreen
    LDA collision
    BNE .collisionCheckDone
  
  .checkSecondPlatformScreen:
    INC c
    JSR MovePlatformsPointerForward
    LDA platformsPointer
    STA genericPointer
    LDA platformsPointer + $01
    STA genericPointer + $01
    JSR CheckForPlatformOneScreen
    JSR MovePlatformsPointerBack
    LDA collision
    BNE .collisionCheckDone
  
  .checkSecondThreatScreen:
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
;   ScrollBullets                                               ;
;                                                               ;
; Description:                                                  ;
;   Moves all bullets as part of the scroll                     ;
;                                                               ;
; Input values:                                                 ;
;   b - 0 means we're incrementing scroll (move left)           ;
;       1 means we're decrementing scroll (move right)          ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;****************************************************************  

ScrollBullets:

  LDX #TOTAL_BULLET_LAST
  
  .updateLoop:      
    LDA allBullets, x
    BEQ .updateLoopCheck              ; BULLET_S_NOT_EXIST == 0
    
    INX
    INX                               ; X points to the x posistion
    
    LDA b
    BEQ .moveLeft
    
    .moveRight:
      LDA allBullets, x
      CLC
      ADC #SCROLL_SPEED
      BCS .offScreen
      STA allBullets, x
      JMP .updateLoopCheckDec2
    
    .moveLeft:       
      LDA allBullets, x
      SEC
      SBC #SCROLL_SPEED
      BCC .offScreen
      STA allBullets, x
      JMP .updateLoopCheckDec2
    
    .offScreen:                       ; bullet off screen, clear
      DEX
      DEX                             ; X points to state
      LDA #BULLET_S_NOT_EXIST 
      STA allBullets, x 
      JMP .updateLoopCheck
    
    .updateLoopCheckDec2:             ; this expects X to point to the x position
      DEX
      DEX
    
    .updateLoopCheck:                 ; this expects X to point to the state
      TXA
      BEQ .updateDone
      DEX
      DEX
      DEX
      DEX
      JMP .updateLoop
  
  .updateDone:
    RTS      