ExplosionsControllerStart:

;****************************************************************
; ExplosionsController                                          ;
; Responsible for rendering explosions                          ;
;****************************************************************

; POITAG - possible optimization - at a cost of 2 CHR sprites, this entire file could be removed
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
;   X                                                           ;
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
    LDA <genericFrame
    CMP #$04                        ; 4th frame is really the 1st frame
    BEQ .firstFrame                 
                                    
  .notFirstFrame:                   
    LDA #LOW(YOff2x2)               ; instead of explosionYOffRest
    STA <b                          
    LDA #HIGH(YOff2x2)              ; instead of explosionYOffRest
    STA <c                          
    LDA #LOW(XOff2x2)               ; instead of explosionXOffRest
    STA <h                          
    LDA #HIGH(XOff2x2)              ; instead of explosionXOffRest
    STA <i                          
    JMP .setAtts
                                    
  .firstFrame:                      
    LDA #LOW(explosionYOff1st)      
    STA <b                          
    LDA #HIGH(explosionYOff1st)      
    STA <c                          
    LDA #LOW(explosionXOff1st)     
    STA <h                          
    LDA #HIGH(explosionXOff1st)      
    STA <i                          
                                    
  .setAtts:
    LDX <genericPointer
    LDA Explosions, x
    STA <renderAtts
    
  .setTilesPointer:
    INX
    LDA Explosions, x 
    STA <d                          
    INX
    LDA Explosions, x
    STA <e                          
    LDX <genericFrame               ; X = animation frame             
    DEX                             ; X = animation frame - 1 (so for frame 1 there is no offset etc)
    BEQ .render                     
    LDA #$00                        
    .movePointerLoop:               
      CLC                           
      ADC #EXPLOSION_SPRITES_COUNT   
      DEX                           
      BNE .movePointerLoop          ; after loop A = 4 * (frame - 1)
    CLC                             
    ADC <d                          
    STA <d                          ; move pointer
    BCC .render                     
    INC <e                          ; handle carry
    JMP .render                     
                                    
  .render:                          
                                    
    ; once we get here              
    ;   b+c points to y off table   
    ;   d+e points to tiles table   
    ;   h+i points to x off table   
    ;   atts are already set  
                                    
    LDY #EXPLOSION_SPRITES_COUNT
    LDA #$00
    STA <j
    
    ; Y = decreasing counter with sprite to render (decremented first run): 3->2->1->0
    ; j = stop after this sprite is rendered
    
    ; if explosionX <= F0 -> render everything
    ; if explosionX <= F7 -> if offscreen render nothing, otherwise render everything
    ; else                -> if offscreen render 2 & 3 (set j to 2), otherwise render 0 & 1 (set y to 2)
    ;                        render nothing if frame = 4 (i.e. first frame with only one sprite) 
    
    LDA <genericX
    CMP #$F1
    BCC .renderTileLoop             ; explosionX < F1 => explosionX <= F0
    CMP #$F8
    BCC .f7Case                     ; explosionX < F8 => explosionX <= F7
    
    .elseCase:
      LDA <genericFrame
      CMP #$04
      BEQ .explosionRendered    
      LDA <genericOffScreen
      BEQ .elseCaseNotOffScreen
      
      .elseCaseOffScreen:
        LDA #$02
        STA <j
        JMP .renderTileLoop
        
      .elseCaseNotOffScreen:
        LDY #$02
        JMP .renderTileLoop
        
    .f7Case:
      LDA <genericOffScreen
      BEQ .renderTileLoop
      JMP .explosionRendered   
    
    .renderTileLoop:                
      DEY
      LDA [d], y
      BEQ .checkCondition ; CLEAR_SPRITE = 0
      STA <renderTile
      LDA [b], y
      CLC
      ADC <genericY
      STA <renderYPos
      LDA [h], y
      CLC
      ADC <genericX
      STA <renderXPos
      JSR RenderSprite
      
      .checkCondition:
        CPY <j
        BNE .renderTileLoop
      
  .explosionRendered:  
    RTS

;****************************************************************
; EOF                                                           ;
;****************************************************************

ExplosionsControllerEnd: