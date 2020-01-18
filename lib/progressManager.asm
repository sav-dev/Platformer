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

  .loadLevelPointer:
    LDY #$00
    JSR SelectBank ; loading bank 0 because levels are in bank 0. todo 0011: if we move them to bank 15 this is not needed
    LDA <currentLevel
    ASL A
    ASL A
    TAX
    LDY levels, x ; load bank, keep it in Y for now
    INX  
    LDA levels, x ; pointer low
    STA <levelPointer
    INX
    LDA levels, x ; pointer high
    STA <levelPointer + $01
    INX
    LDA levels, x ; level type
    BEQ .game ; LEVEL_TYPE_GAME = 0
  
  .story:
    JSR SelectBank ; everything loaded from levels, switch the bank now. todo 0011: if we move levels to bank 15 this can be moved up
    LDA #GAMESTATE_STORY
    STA <gameState
    JMP LoadStory 
    
  .game:
    JSR SelectBank ; everything loaded from levels, switch the bank now. todo 0011: if we move levels to bank 15 this can be moved up
    LDA #GAMESTATE_GAME
    STA <gameState
    JMP LoadGame
    
ProgressManagerEnd: