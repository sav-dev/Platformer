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

  ; check the test hook value. if non-0, always just load the test hook level.
  .checkTestHook:
    LDA <testHookSet
    BEQ .setLevelPointer
    
    .processTestHook:
      LDY #TEST_HOOK_BANK
      JSR SelectBank
      LDA #TEST_HOOK_ADDR_L
      STA <levelPointer
      LDA #TEST_HOOK_ADDR_H
      STA <levelPointer + $01
      JMP .loadSongToPlay

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
        
  ; switch bank, load the level pointer
  .loadLevelData:
    LDY levels, x ; load bank, keep it in Y for now
    JSR SelectBank
    INX  
    LDA levels, x ; pointer low
    STA <levelPointer
    INX
    LDA levels, x ; pointer high
    STA <levelPointer + $01   
    
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