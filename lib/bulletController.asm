;****************************************************************
; BulletController                                              ;
; Responsible for spawning and updating bullets                 ;
;****************************************************************

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

  ; POI - possible optimization - keep a count of free bullets, return immediately if at 0

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
      BNE .checkDirection                
      JMP .clearBullet                ; something hit last frame, clear the bullet now
      
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
        LDA allBullets, x 
        CLC
        ADC #BULLET_SPEED             ; move bullet left
        BCC .moveRight                ; carry clear if bx1 + bullet speed <= screen width: bullet on screen
        JMP .clearBulletMovePointer2
      
        .moveRight:
          STA allBullets, x           ; update the bullet position
          STA bx1                     ; preset bx1
          STA renderXPos              ; preset render x
          LDA #BULLET_ATTS_RIGHT
          STA renderAtts              ; preset render atts
          JMP .goingHorizontally
        
      .goingLeft:
        INX                           ; X points to x position
        LDA allBullets, x 
        SEC 
        SBC #BULLET_SPEED             ; move bullet left        
        BCS .moveLeft                 ; carry set if bx1 - bullet speed >= 0: bullet on screen
        JMP .clearBulletMovePointer2
      
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
        BCS .boxCapX2
        STA bx2
        JMP .checkCollisions
        
      .goingDown:
        INX                           ; X points to x position
        LDA allBullets, x 
        STA bx1                       ; preset bx1
        STA renderXPos                ; preset render x
        INX                           ; X points to y position
        LDA allBullets, x
        CLC 
        ADC #BULLET_SPEED             ; move bullet down
        CMP #SCREEN_HEIGHT        
        BCC .moveDown                 ; carry clear if by1 + bullet speed < screen height: bullet on screen
        JMP .clearBulletMovePointer3
        
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
        LDA allBullets, x
        SEC 
        SBC #BULLET_SPEED             ; move bullet up
        BCS .moveUp                   ; carry set if by1 - bullet speed >= 0: bullet on screen
        JMP .clearBulletMovePointer3
      
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
        BCS .boxCapX2
        STA bx2
        JMP .checkCollisions         
            
      .boxCapX2:                      ; common for all directions
        LDA #SCREEN_WIDTH
        STA bx2
            
    .checkCollisions:                 ; when we get here the bullet has been moved in memory, box is set, rendering vars are preset
      ;JSR CheckForAllCollisions
      ;LDA collision
      BNE .renderBullet
      
    .collision:      
      
    .renderBullet:
      JSR RenderSprite
      DEX
      DEX
      DEX                             ; X points back to the state
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
;   CheckForAllCollisions                                       ;
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
  
CheckForAllCollisions:

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
;   b - 0 means we're incementing scroll (move left)            ;
;       1 means we're decementing scroll (move right)           ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;****************************************************************  

ScrollBullets:

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