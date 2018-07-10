;****************************************************************
; EnemiesManager                                                ;
; Responsible for rendering and updating enemies                ;
;****************************************************************

;
; - enemies in level data the following format:
;   - pointer to next screen (from here): (n x 14) + 3 (1 byte)
;   - number of enemies (1 byte)
;   - n times the enemy data (14 bytes)
;        - id (1 byte)
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
;        - shooting frequency (1 byte)
;        - shooting frequency initial (1 byte)
;   - pointer to the previous screen (from here): (n x 14) + 2 (1 byte)
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
;    - shooting frequency (1 byte)
;    - shooting timer (1 byte)
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
;   enemyScreen                                                 ;
;   enemySpeed                                                  ;
;   enemyMaxDistance                                            ;
;   genericDirection                                            ;
;   genericX                                                    ;
;   genericY                                                    ;
;   genericDX                                                   ;
;   genericDY                                                   ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************
 
UpdateActiveEnemy:

  ; at this point, X points to the state.
  ; cache the const data pointer in Y and the screen the enemy is on in enemyScreen
  ; first do X += 2 to skip state and id. we'll point to the const data.
  ; then do X += 1 to point to the screen.
  ; then to X += 1 to point to the next byte after the screen (speed).
  .cachePointerAndScreen:
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
    ; first do a X += 1 to point at movement direction, and load it.
    ; if it's 0 (ENEMY_MOVE_NONE), skip this section.
    ; otherwise, based on the direction and flip (cached in genericDirection), set DX and DY
    .calculateDiffs:
      INX
      LDA enemies, x
      BEQ .applyMovement
      CMP #ENEMY_MOVE_HORIZONTAL
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
    
    ; assume the enemy should be rendered.
    ; also, while we're here, assume collision check is needed and enemy may shoot
    LDA #$01
    STA enemyRender
    STA enemyCollisions
    STA enemyShooting
    
    ; transpose X. First check if enemy is on the current screen or the next
    LDA enemyScreen
    CMP scroll + $01
    BEQ .currentScreen
    
    ; enemy is on the next  screen. Transpose logic:
    ;   - x' = x - low byte of scroll + 256
    ;   - first calculate A = 255 - scroll + 1. If this overflows,
    ;     it means scroll = 0, i.e. ememy is off screen
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
      
      .enemyOffScreen:
        DEC enemyRender
        JMP EnemyProcessShooting
    
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
      ;   - add hitbox X offset, cache the result in ax2 temporarily
      ;   - if carry not set - cap at 0
      ;   - Y += 1 to point at hitbox width
      ;   - load ax2, add hitbox width
      ;   - if carry not set - don't check collisions
      .hitboxXOffScreen:
        LDA genericX
        CLC
        ADC EnemyConsts, y
        STA ax2
        BCC .capX1
        STA ax1
        JMP .hitboxXOffScreenX2
        
        .capX1:
          LDA #$00
          STA ax1
      
        .hitboxXOffScreenX2:
          INY
          LDA ax2
          CLC
          ADC EnemyConsts, y
          BCC .noCollisions     ; BUG - what if ax1 >= 0
          STA ax2
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
      
    ; calculate the position of the gun.
    ; we expect Y to point to the hitbox height when we get here
    ;   {todo add description}
    ;   {todo implement, for now skip everything}
    .gunPosition:
      INY
      INY
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
    
  ; ...
  EnemyCheckCollisions:
    
  ; ...
  EnemyProcessShooting:
  
  ; ...
  EnemyProcessAnimation:
  
  ; ...
  EnemyRender:
    LDA enemyRender
    BEQ .updateActiveEnemyDone
    LDA #$01
    STA genericFrame
    JSR RenderEnemy
   
  .updateActiveEnemyDone:
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
;   {todo}                                                      ;
;                                                               ;
; Remarks:                                                      ;
;   depends_on_enemy_in_memory_format                           ;
;****************************************************************
    
UpdateExplodingEnemy:
  ; todo
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
;   {todo}                                                      ;
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
  
    ; X now points to the state. Check it:
    ;   0 == ENEMY_STATE_EMPTY
    ;   2 == ENEMY_EXPLODING
    ; else: 1 == ENEMY_STATE_ACTIVE
    LDA enemies, x       
    BEQ .enemyEmpty
    CMP #ENEMY_STATE_EXPLODING
    BEQ .enemyExploding
    
    ; active enemy - call into a subroutine, jump to the loop condition
    .enemyActive:
      JSR UpdateActiveEnemy
      JMP .updateEnemyLoopCondition
      
    ; enemy exploding - call into a subroutine, let flow to the empty clause
    .enemyExploding:
      JSR UpdateExplodingEnemy
      
    ; enemy empty - do nothing, let flow into the loop condition
    .enemyEmpty:      
    
    ; loop condition - if we've not just processed the last enemy, loop.   
    ; otherwise exit
    .updateEnemyLoopCondition:
      LDA xPointerCache
      BNE .updateEnemyLoop
      RTS
    
;****************************************************************
; Name:                                                         ;
;   LoadEnemiesInitial                                          ;
;                                                               ;
; Description:                                                  ;
;   Load enemies for screen 0 and 1, sets the enemiesPointer    ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer - set to the start of the enemies data       ;
;                                                               ;
; Output variables:                                             ;
;   enemiesPointer - set to the enemies data for screen 1 (!)   ;
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
  
  .loadEnemiesCount:
  
    LDY #$01                    ; skip the pointer, Y points to the number of enemies
    LDA [enemiesPointer], y     ; load the number of enemies
    BEQ .loadEnemiesExit        ; no enemies to load
    STA b                       ; store the number of enemies in b    
   
  .loadEnemiesLoop:
  
    INY
    LDA [enemiesPointer], y     ; load the id
    ; todo: check if the enemy has been destroyed    
    STA c                       ; cache it in c for now
    
    INY
    LDA [enemiesPointer], y     ; load the slot to put enemy in
    TAX                         ; put in in X - X points to state        
    
    LDA #ENEMY_STATE_ACTIVE
    STA enemies, x              ; set the state
    
    INX                         ; x points to the id
    LDA c                       ; load the id back from c
    STA enemies, x              ; store
    
    LDA #$0C                    ; next 12 bytes are the same in both definitions:
    STA d                       ; pointer, screen, speed, distance, direction, distance left, flip, x, y, life, shooting freq, shooting timer
    .copyLoop:                  ; d will be the loop pointer
      INY
      LDA [enemiesPointer], y   ; load enemy data
      INX
      STA enemies, x            ; store in memory data
      DEC d
      BNE .copyLoop   
    
    LDA #$01                    ; next two bytes are the animation vars, set both to 1 (so they'll loop to the beginning the next frame)
    INX
    STA enemies, x
    INX
    STA enemies, x
    
    DEC b
    BNE .loadEnemiesLoop        ; loop if needed
          
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
      DEX                          ; x points to the state
      LDA #ENEMY_STATE_EMPTY
      STA enemies, x               ; unload the enemy
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
    ;ADC #$00                   ; add carry, not needed anymore
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
                                
      .tileOnScreen:            ; tile on screen, first check if it's not partially on screen
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
  