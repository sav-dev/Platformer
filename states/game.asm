StateGameStart:

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
    STA <needDrawLocal
    STA <needPpuRegLocal

  .incrementFrameCounter:
    INC <frameCount
    
  .processFrame:
    
    .updatePlayer:                    ; move player, check for collisions with platforms and elevators  
      JSR UpdatePlayer                ; checks input, updates player dX and dY
      
    .updateElevators:                 ; move all elevators, move player if standing on or hit by an elevator
      JSR UpdateElevators             ; moves elevator, updates player dX and dY if needed
      
    .rederPlayer:                     ; at this point, player has been moved, screen has been scrolled
      JSR RenderPlayer                ; we can render the player
    
    .renderElevators:                 ; we can now render the elevators
      JSR RenderElevators             ; 
    
    .checkThreatsCollisions:          ; check for player collisions with threats, also checks if player is falling off the screen
      JSR CheckThreats                ;
    
    .spawnPlayerBullets:              ; spawn a player bullet if needed 
      JSR SpawnPlayerBullets          ;
    
    .updatePlayerBullets:             ; move all player bullets, check for collisions with platforms and threats, render
      JSR UpdatePlayerBullets         ;
     
    .updateEnemies:                   ; move all enemies, spawn enemy bullets, check for collisions with player and player bullets, render
      JSR UpdateEnemies               ;
    
    .updateEnemyBullets:              ; move all enemy bullets, check for collisions with platforms and threats, check for collision with player, render
      JSR UpdateEnemyBullets          ;

    .processDoorAndKeycard:           ; render door and keycard, check if player found the keycard
      JSR ProcessDoorAndKeycard       ;
 
    .checkVictoryConditions:          ; check for victory conditions
      JSR CheckVictoryConditions      ; 
      
  .setNmiFlags:
    .dma:
      INC <needDma                  ; always do DMA     
  
    .checkIfDrawNeeded:
      LDA <needDrawLocal
      BEQ .checkIfDrawNeededDone
      INC <needDraw
    .checkIfDrawNeededDone:
    
    .checkIfPpuRegNeeded:
      LDA <needPpuRegLocal
      BEQ .checkIfPpuRegNeededDone
      INC <needPpuReg
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
    INC <needDma
    JSR WaitForFrame              ; wait for values to be written
  .disablePPUAndSleepDone:

  .clearMemory:                   ; clear all loaded enemies, elevators and bullets data
  
    .clearArrays:                 ; clear data between levels
      
      LDA #$00
      LDX #$00
      
      .clear400Loop:        
        STA $0400, x
        STA $0500, x
        STA $0600, x
        INX
        BNE .clear400Loop
                  
    .clearArraysDone:
    
    .clearLevelBeaten:            ; clear the level beat flag
      LDA #$00
      STA <levelBeaten
    .clearLevelBeatenDone:
    
  .clearMemoryDone:
  
  ; todo 0000 - this needs to be updated; only load sprites chr once; select bank
  .loadChr:
    JSR SetVramAddressingTo1
    LDA #LOW(SprChr)
    STA <genericPointer
    LDA #HIGH(SprChr)
    STA <genericPointer + $01
    JSR LoadSprChr
    LDA #LOW(BgChr)
    STA <genericPointer
    LDA #HIGH(BgChr)
    STA <genericPointer + $01
    JSR LoadBgChr
  .loadChrDone:
  
  .loadLevel:                     ; load level
    JSR SetVramAddressingTo32
    LDA <currentLevel
    ASL A
    TAX                           ; X = currentLevel * 2
    LDA levels, x                 ; low byte of level address
    STA <levelPointer             ; set the pointer
    INX
    LDA levels, x                 ; high byte of level address
    STA <levelPointer + $01       ; set the pointer
    JSR LoadLevel                 ; load level
  .loadLevelDone:
  
  .loadPalettes:
    JSR SetVramAddressingTo1
    JSR LoadBgPalette  
    JSR LoadSpritesPalette
    INC <needDraw 
    JSR WaitForFrame              ; wait for values to be written
    JSR SetVramAddressingTo32
  .loadPalettesDone:
  
  .loadPlayer:                    ; playerX and playerY should be set by LoadLevel  
    JSR LoadPlayer
  .loadPlayerDone:
 
  .initVars:
    LDA #GAMESTATE_GAME
    STA <gameState
    LDA #$00
    STA <nametable                ; show nametable 0 first
    STA <scroll                   ; scroll starts at 0
    STA <scroll + $01
  .initVarsDone:
 
  .enablePPU:                                    
    JSR EnablePPU
  .enablePPUDone:  

  ; todo 0006 - is this the right place to call this
  .initializeSound:
    JSR InitializeSound
    JSR PlaySong
  .initializeSoundDone:
  
  JMP WaitForFrame 
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateGameEnd: