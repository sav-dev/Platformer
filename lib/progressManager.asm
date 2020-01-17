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
  LDA <currentLevel
  ASL A
  ASL A
  TAX
  LDY levels, x ; load bank
  JSR SelectBank ; switch bank
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
    LDA #GAMESTATE_STORY
    STA <gameState
    JMP LoadStory 
  
  .game:
    LDA #GAMESTATE_GAME
    STA <gameState
    JMP LoadGame
    
ProgressManagerEnd: