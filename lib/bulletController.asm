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
;****************************************************************
  
SpawnPlayerBullet:

  .checkCount:
    LDA availablePlayerBullets
    BNE .setPointerAndCounter
    RTS                               ; no slots available

  .setPointerAndCounter:
    LDA #LOW(playerBullets)
    STA genericPointer
    LDA #HIGH(playerBullets)
    STA genericPointer + $01
    LDA #PLAYER_BULLET_LIMIT
    STA genericCounter
    
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
      JMP SpawnBullet
                                      
    .shootLeft:                       
      LDA playerX                     
      CLC                             
      ADC #PLAYER_GUN_OFF_X_L         
      STA genericX
      LDA #GENERIC_DIR_LEFT
      STA genericDirection
      JMP SpawnBullet
  
;****************************************************************
; Name:                                                         ;
;   SpawnBullet                                                 ;
;                                                               ;
; Description:                                                  ;
;   Spawns a bullet                                             ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer                                              ;
;   genericCounter                                              ;
;   genericX                                                    ;
;   genericY                                                    ;
;   genericDirection                                            ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;****************************************************************
  
SpawnBullet:

  .findFreeBulletSlot:
    DEC genericCounter
    ASL genericCounter
    ASL genericCounter
    LDY genericCounter                ; Y = (genericCounter - 1) x 4, i.e. points to the last bullet state field
    
    .findLoop:      
      LDA [genericPointer], y
      BEQ .freeSlotFound              ; BULLET_S_NOT_EXIST == 0
      TYA
      BEQ .noFreeSlots
      DEY
      DEY
      DEY
      DEY
      JMP .findLoop
      
    .noFreeSlots:
      RTS                                ; no free slots
                                      
  .freeSlotFound:                      ; when we get here [genericPointer], y points to the first byte of the free slot
    LDA #BULLET_S_JUST_SPAWNED
    STA [genericPointer], y
    INY                                ; this follows the bullet format declared in constants
    LDA genericX
    STA [genericPointer], y
    INY
    LDA genericY
    STA [genericPointer], y
    INY
    LDA genericDirection
    STA [genericPointer], y
    DEC availablePlayerBullets
    RTS

;****************************************************************
; Name:                                                         ;
;   UpdatePlayerBullets                                         ;
;                                                               ;
; Description:                                                  ;
;   Updates player bullets                                      ;
;                                                               ;
; Used variables:                                               ;
;   {todo}                                                      ;
;****************************************************************
  
UpdatePlayerBullets:
  LDA #LOW(playerBullets)
  STA genericPointer
  LDA #HIGH(playerBullets)
  STA genericPointer + $01
  LDA #PLAYER_BULLET_LIMIT
  STA genericCounter
  JMP UpdatBullets

;****************************************************************
; Name:                                                         ;
;   UpdatBullets                                                ;
;                                                               ;
; Description:                                                  ;
;   Updates bullets                                             ;
;                                                               ;
; Used variables:                                               ;
;   {todo}                                                      ;
;****************************************************************
  
UpdateBullets:
  RTS
  
;  .moveBullets:
;    LDY #PLAYER_BULLET_LIMIT
;    .moveBulletLoop:      
;      DEY
;      TYA
;      ASL A
;      ASL A     
;      TAX
;                  
;      INX                             ; x points to tile
;      LDA playerBullets, x            ; load bullet tile
;      CMP #CLEAR_SPRITE               
;      BEQ .moveBulletLoopCheck        ; bullet not populated
;                                      
;      DEX                             ; x points to the Y position
;      LDA playerBullets, x            ; load the Y position
;      STA by1                         ; set by1
;      CLC                             
;      ADC #PLAYER_BULLET_HEIGHT       
;      STA by2                         ; set by2
;                                      
;      INX                             
;      INX                             ; x points to atts
;      LDA playerBullets, x            ; load bullet atts      
;      ; AND #%01000000                ; no need for AND as bullets use pallete 0
;      BEQ .bulletFlyingRight          ; not rotated means bullet flying right
;                                      
;      .bulletFlyingLeft:              
;        INX                           ; x points to X position
;        LDA playerBullets, x          ; load bullet X position
;        SEC                           
;        SBC #PLAYER_BULLET_SPEED      
;        BCC .clearBullet              ; clear bullet if goes off screen
;        STA playerBullets, x          ; set new X position
;        JMP .checkCollisions          
;                                      
;      .bulletFlyingRight:             
;        INX                           ; x points to X position
;        LDA playerBullets, x          ; load bullet X position
;        CLC                           
;        ADC #PLAYER_BULLET_SPEED      
;        BCS .clearBullet              ; clear bullet if goes off screen
;        STA playerBullets, x          ; set new X position
;                                      
;      .checkCollisions:               
;        STA bx1                       ; set bx1 (A still contains the new X posistion)
;        CLC
;        ADC #PLAYER_BULLET_WIDTH
;        BCS .clearBullet              ; bullet already partially off screen
;        STA bx2                       ; set bx2
;        STY e                         ; cache Y in e since CheckForAllCollisions updates it        
;        JSR CheckForAllCollisions
;        LDY e                         ; restore Y
;        LDA collision                 ; check if collision detected
;        BEQ .moveBulletLoopCheck      
;        
;      .clearBullet:      
;        DEX                           ; CheckForAllCollisions doesn't affect X so it's OK
;        DEX                           ; x points to tile
;        LDA #CLEAR_SPRITE             
;        STA playerBullets, x          ; clear bullet
;      
;      .moveBulletLoopCheck:
;        TYA
;        BNE .moveBulletLoop    
;  
;  .updateCooldown:
;    LDA playerBulletCooldown
;    BEQ .checkInput
;    DEC playerBulletCooldown
;    RTS
;  
;  .checkInput:
;    LDA controllerPressed
;    AND #CONTROLLER_B
;    BNE .checkIfPlayerOnScreen
;    RTS

      
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