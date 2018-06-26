;****************************************************************
; EnemiesManager                                                ;
; Responsible for rendering and updating enemies                ;
;****************************************************************

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
    BEQ .noFlip                 ; ENEMY_NO_FLIP == 0
  
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
                                
      .tileOnScreen:            ; tile on screen, first check if it's not partially on screen
        CLC
        ADC #SPRITE_DIMENSION
        BCS .loopCheck          ; carry set means tile is partialy on screen, never render those
        LDA genericOffScreen    ; if we got here it means tile is fully on screen
        BCS .loopCheck          ; only render it if genericOffScreen == 0
        JMP .renderTile
      
      .tileOffScreen:           
        LDA genericOffScreen    ; if we got here it means tile is fully off screen
        BCC .loopCheck          ; only render if genericOffScreen == 1
      
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
  