ProgressManagerStart:

;****************************************************************
; ProgressManager                                               ;                           
; Responsible for progressing the game                          ;
;****************************************************************

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   ProgressGame                                                ;    
;                                                               ;
; Description:                                                  ;
;   Progress game based on current level                        ;
;****************************************************************

ProgressGame:

  ; loading bank 0 because levels are in bank 0.
  ; todo 0011: if we move them to bank 15 this is not needed
  .changeBank:
    LDY #$00
    JSR SelectBank
  
  ; this sets X = 3 * currentLevel  
  .setLevelPointer:
    LDA #$00
    LDX <currentLevel
    BEQ .loadLevelData
    .incrementLoop:
      CLC
      ADC #LEVEL_DEF_SIZE
      DEX
      BNE .incrementLoop
      TAX
    
  ; load the target bank to x, load the level pointer
  ; todo 0011: if we move them to bank 15 this is not needed, can load the bank immediately
  .loadLevelData:
    LDY levels, x ; load bank, keep it in Y for now
    INX  
    LDA levels, x ; pointer low
    STA <levelPointer
    INX
    LDA levels, x ; pointer high
    STA <levelPointer + $01    
  
  ; we can do the bank switch now
  .switchBank:
    JSR SelectBank
  
  ; the 1st byte is always song to play. load that now
  .loadSongToPlay:
    LDY #$00
    LDA [levelPointer], y
    STA <songToPlay
    
  ; the 2nd byte is the progress type. load that now and cache in X
  .progressType:
    INY
    LDA [levelPointer], y
    TAX
    
  ; now move the level pointer to skip the first two bytes
  .moveLevelPointer:
    LDA <levelPointer
    CLC
    ADC #$02
    STA <levelPointer
    LDA <levelPointer + $01
    ADC #$00
    STA <levelPointer + $01
    
  ; finally, call the right routine based on X
  .checkProgressType:
    TXA
    BEQ .game ; PROGRESS_GAME = 0
  
  .story:    
    LDA #GAMESTATE_STORY
    STA <gameState
    JMP LoadStory 
    
  .game:
    LDA #GAMESTATE_GAME
    STA <gameState
    JMP LoadGame
    
ProgressManagerEnd: