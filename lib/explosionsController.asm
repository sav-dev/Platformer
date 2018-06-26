;****************************************************************
; ExplosionsController                                          ;
; Responsible for rendering explosions                          ;
;****************************************************************

; POI - possible optimization - at a cost of 2 CHR sprites, this entire file could be removed
; which will save a ton of program bytes. Use the 'render enemy' logic instead. Do this change?

;****************************************************************
; Name:                                                         ;
;   RenderExplosion                                             ;
;                                                               ;
; Description:                                                  ;
;   Renders an explosion                                        ;
;                                                               ;
; Input variables:                                              ;
;   Generic vars                                                ;
;                                                               ;
; Used variables:                                               ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;   h                                                           ;
;   i                                                           ;
;   j                                                           ;
;****************************************************************

RenderExplosion:  

  .setPositionPointers:  
    LDA genericFrame
    CMP #$04                        ; 4th frame is really the 1st frame
    BEQ .firstFrame                 
                                    
  .notFirstFrame:                   
    LDA #LOW(YOff2x2)               ; instead of explosionYOffRest
    STA b                           
    LDA #HIGH(YOff2x2)              ; instead of explosionYOffRest
    STA c                           
    LDA #LOW(XOff2x2)               ; instead of explosionXOffRest
    STA h                           
    LDA #HIGH(XOff2x2)              ; instead of explosionXOffRest
    STA i                           
    JMP .setTilePointer             
                                    
  .firstFrame:                      
    LDA #LOW(explosionYOff1st)      
    STA b                           
    LDA #HIGH(explosionYOff1st)      
    STA c                           
    LDA #LOW(explosionXOff1st)     
    STA h                           
    LDA #HIGH(explosionXOff1st)      
    STA i                           
                                    
  .setTilePointer:                  
    LDA #LOW(explosionTiles)        
    STA d                           
    LDA #HIGH(explosionTiles)       
    STA e                           
    LDX genericFrame                ; X = animation frame             
    DEX                             ; X = animation frame - 1 (so for frame 1 there is no offset etc)
    BEQ .render                     
    LDA #$00                        
    .movePointerLoop:               
      CLC                           
      ADC #EXPLOSION_SPRITES_COUNT   
      DEX                           
      BNE .movePointerLoop          ; after loop A = 4 * (frame - 1)
    CLC                             
    ADC d                           
    STA d                           ; move pointer
    BCC .render                     
    INC e                           ; handle carry
    JMP .render                     
                                    
  .render:                          
                                    
    ; once we get here              
    ;   b+c points to y off table   
    ;   d+e points to tiles table   
    ;   h+i points to x off table   
    ;   atts are constant  
                                    
    LDY #EXPLOSION_SPRITES_COUNT
    LDA #$00
    STA j
    
    ; Y = decreasing counter with sprite to render (decremented first run): 3->2->1->0
    ; j = stop after this sprite is rendered
    
    ; if explosionX <= F0 -> render everything
    ; if explosionX <= F7 -> if offscreen render nothing, otherwise render everything
    ; else                -> if offscreen render 2 & 3 (set j to 2), otherwise render 0 & 1 (set y to 2)
    ;                        render nothing if frame = 4 (i.e. first frame with only one sprite) 
    
    LDA genericX
    CMP #$F1
    BCC .renderTileLoop             ; explosionX < F1 => explosionX <= F0
    CMP #$F8
    BCC .f7Case                     ; explosionX < F8 => explosionX <= F7
    
    .elseCase:
      LDA genericFrame
      CMP #$04
      BEQ .explosionRendered    
      LDA genericOffScreen
      BEQ .elseCaseNotOffScreen
      
      .elseCaseOffScreen:
        LDA #$02
        STA j
        JMP .renderTileLoop
        
      .elseCaseNotOffScreen:
        LDY #$02
        JMP .renderTileLoop
        
    .f7Case:
      LDA genericOffScreen
      BEQ .renderTileLoop
      JMP .explosionRendered   
    
    .renderTileLoop:                
      DEY                           
      LDA [b], y                    
      CLC                           
      ADC genericY                   
      STA renderYPos                
      LDA [d], y                    
      STA renderTile                
      LDA #EXPLOSION_ATTS                   
      STA renderAtts          
      LDA [h], y                    
      CLC                           
      ADC genericX
      STA renderXPos
      JSR RenderSprite
      CPY j
      BNE .renderTileLoop
      
  .explosionRendered:  
    RTS
    
;****************************************************************
; ATTS for explosion are currently constant for each tile       ;
; POI - one sprite in CHR could be saved if we flipped it       ;
;****************************************************************

EXPLOSION_ATTS = $00
        
;****************************************************************
; Lookup tables generated by the tool below                     ;
;****************************************************************
    
explosionXOff1st:
  .byte $05, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE
; Commented out for optimization, use XOff2x2 instead
;explosionXOffRest:
;  .byte $00, $00, $08, $08
explosionYOff1st:
  .byte $04, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE
; Commented out for optimization, use YOff2x2 instead
;explosionYOffRest:
;  .byte $00, $08, $00, $08
explosionTiles:
  .byte $22, $24, $23, $25
  .byte $1E, $20, $1F, $21
  .byte $1A, $1C, $1B, $1D
  .byte $19, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE