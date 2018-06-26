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
    
  .setAttsPointer:              ; store the current value of generic pointer
    INY                         ; Y points to the atts pointer
    LDA genericPointer
    STA h
    LDA genericPointer + $01
    STA i
         
  .movePointerToTiles:
    TYA                         ; move Y to A
    LDX genericFrame            ; frames count down, so if animation has 4 frames, it's 4 -> 3 -> 2 -> 1    
    .movePointerLoop:           ; last frame is first in the definition etc.
      CLC                       ; we have to skip the atts though, so if genericFrame = 1 (render last frame), skip N bytes
      ADC b                     ; if genericFrame = 2 (next to last frame), skip N * 2 bytes
      DEX                       ; so basically skip N * genericFrame bytes
      BNE .movePointerLoop      ; we can update genericFrame directly, it won't be needed anymore
    TAY                         ; move A back to Y (Y' = Y + N * genericFrame)
    
  .setTilesPointer:
    LDA genericPointer
    STA j
    LDA genericPointer + $01
    STA k
      
  ; all pointers set, now draw
  
  RTS
  