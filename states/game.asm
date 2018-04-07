;****************************************************************
; State: game                                                   ;
;****************************************************************

;****************************************************************
; Constants:                                                    ;
;****************************************************************
                         
;****************************************************************
; Name:                                                         ;
;   GameFrame                                                   ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "game" state         ;
;****************************************************************

GameFrame:

  .clearSprites:
    JSR ClearSprites

  .resetNmiFlags:
    LDA #$00
    STA needDrawLocal
    STA needPpuRegLocal
     
  .updatePlayer:
    JSR UpdatePlayer
   
  .updatePlayerBullets:
    JSR UpdatePlayerBullets
   
  .setNmiFlags:
    .dma:
      INC needDma                   ; always do DMA     
  
    .checkIfDrawNeeded:
      LDA needDrawLocal
      BEQ .checkIfDrawNeededDone
      INC needDraw
    .checkIfDrawNeededDone:
    
    .checkIfPpuRegNeeded:
      LDA needPpuRegLocal
      BEQ .checkIfPpuRegNeededDone
      INC needPpuReg 
    .checkIfPpuRegNeededDone:
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   LoadGame                                                    ;
;                                                               ;
; Description:                                                  ;
;   Loads the "game" state                                      ;
;                                                               ;
; Input variables:                                              ;
;   currentLevel                                                ;
;****************************************************************

LoadGame:

  .disablePPUAndSleep:  
    JSR DisablePPU
    JSR ClearSprites
    INC needDma
    JSR WaitForFrame              ; wait for values to be written
  .disablePPUAndSleepDone:

  .setVramAddressingTo1:
    LDA #%10010000                ; enable NMI, sprites from PT 0, bg from PT 1. Use NT 0, 1 VRAM increment (for palettes)
    STA soft2000
    INC needPpuReg
    JSR WaitForFrame              ; wait for values to be written
  .setVramAddressingTo1Done:
  
  .loadPalettes:
    LDA #LOW(pal_bg_0)
    STA genericPointer
    LDA #HIGH(pal_bg_0)
    STA genericPointer + $01
    JSR LoadBgPalette  
    LDA #LOW(pal_spr_0)
    STA genericPointer
    LDA #HIGH(pal_spr_0)
    STA genericPointer + $01
    JSR LoadSpritesPalette
    INC needDraw  
    JSR WaitForFrame              ; wait for values to be written
  .loadPalettesDone:
 
  .setVramAddressingTo32:
    LDA #%10010100                ; enable NMI, sprites from PT 0, bg from PT 1. Use NT 0, 32 VRAM increment (for background)
    STA soft2000
    INC needPpuReg
    JSR WaitForFrame              ; wait for values to be written
  .setVramAddressingTo32Done:
 
  .loadLevel:
    LDA currentLevel
    ASL A
    TAX                           ; X = currentLevel * 2
    LDA levels, x                 ; low byte of level address
    STA levelPointer              ; set the pointer
    INX
    LDA levels, x                 ; high byte of level address
    STA levelPointer + $01        ; set the pointer
    JSR LoadLevel                 ; load level
  .loadLevelDone:
 
  .loadPlayer:                    ; playerX and playerY should be set by LoadLevel  
    JSR LoadPlayer
  .loadPlayerDone:
 
  .initVars:
    LDA #GAMESTATE_GAME
    STA gameState
    LDA #$00
    STA nametable                 ; show nametable 0 first
    STA scroll                    ; scroll starts at 0
    STA scroll + $01
  .initVarsDone:
 
  .enablePPU:                                    
    LDA #%00011110                ; enable sprites and background
    STA soft2001                  
    INC needPpuReg
  .enablePPUDone:
  
  JMP WaitForFrame 