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

  .incrementFrameCounter:
    INC frameCount
    
  .updatePlayer:
    JSR UpdatePlayer                ; move player, check for collisions with platforms and threats, render
   
  ; how to do moving platforms? easy way:
  ;
  ;   in UpdatePlayer, check for collision with moving platforms.
  ;   if collision is when going down, mark the platform as "player stands on this".
  ;   don't render the player in UpdatePlayer, instead cache the animation.
  ;   
  ;   in UpdateMovingPlatforms, move each platform, then check for collisions again  
  ;   if going up, again mark the platform as "player stands on this". change animation to standing
  ;   no animation update is needed in any other case.
  ;   move player along with "player stands on this" platform
  ;
  ;   finally, render the player as player's position is fixed by now
  
  ;.updateMovingPlatforms:
  ;  JSR UpdateMovingPlatforms
   
  .spawnPlayerBullets:
    JSR SpawnPlayerBullets          ; spawn a player bullet if needed
  
  .updatePlayerBullets:
    JSR UpdatePlayerBullets         ; move all player bullets, check for collisions with platforms and threats, render
   
  .updateEnemies:
    JSR UpdateEnemies               ; move all enemies, spawn enemy bullets, check for collisions with player and player bullets, render
  
  .updateEnemyBullets:
    JSR UpdateEnemyBullets          ; move all enemy bullets, check for collisions with platforms and threats, check for collision with player, render
    
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
 
  .clearMemory:                   ; clear all loaded enemies, elevators and bullets data
  
    .clearBullets:                ; clear bullets
      LDX #TOTAL_BULLET_VAR_SIZE    
      .clearBulletLoop:
        DEX
        LDA #$00
        STA bullets, x
        TXA
        BNE .clearBulletLoop
    .clearBulletsDone:
    
    .clearEnemiesAndElevators:    ; clear all enemies and elevators data
      LDX #TOTAL_EN_EL_DATA_SIZE    
      .clearEnemyElevatorDataLoop:
        DEX
        LDA #$00
        STA $0400, x
        TXA
        BNE .clearEnemyElevatorDataLoop
    .clearEnemiesAndElevatorsDone:
    
  .clearMemoryDone:
 
  .loadLevel:                     ; load level
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