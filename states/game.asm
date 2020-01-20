StateGameStart:

;****************************************************************
; State: game                                                   ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   GameFrame                                                   ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "game" state         ;
;****************************************************************

GameFrame:

  .resetNmiFlags:
    LDA #$00
    STA <needDrawLocal
    STA <needPpuRegLocal
    
  .processStart:
    LDA <controllerPressed
    AND #CONTROLLER_START
    BEQ .checkPause
    
  .changePause:
    JSR FlipGreyscale
    JSR SfxPause
    LDA <isPaused         
    EOR #%00000001
    STA <isPaused        
    CMP #$00
    BEQ .resumeSong
    
    .pauseSong:
      JSR PauseSong
      JMP .checkPause
      
    .resumeSong:
      JSR ResumeSong
    
  .checkPause:
    LDA <isPaused
    BEQ .clearSprites
    JMP .setNmiFlags
    
  .clearSprites:
    JSR ClearSprites
    
  .presetVars:
    LDA #$00
    STA <frameScroll                  ; preset to 0 (A = 0 still)
    
  .processFrame:
    
    .updatePlayer:                    ; move player, check for collisions with platforms and elevators  
      JSR UpdatePlayer                ; checks input, updates player dX and dY
      LDA <progressGame               ; if we should progress the game, just exit
      BEQ .updateElevators            ; no need to do any of the other stuff
      JMP .setNmiFlags                ; 
      
    .updateElevators:                 ; move all elevators, move player if standing on or hit by an elevator
      JSR UpdateElevators             ; moves elevator, updates player dX and dY if needed
      
    .rederPlayer:                     ; at this point, player has been moved, screen has been scrolled
      JSR RenderPlayer                ; we can render the player
    
    .renderElevators:                 ; we can now render the elevators
      JSR RenderElevators             ; 
    
    .checkThreatsCollisions:          ; check for player collisions with threats, also checks if player is falling off the screen
      JSR CheckThreats                ;
      
    .scrollBullets:                   ; all the scrolling has been completed. We can now scroll the bullets
      JSR ScrollBullets               ;
    
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
;   ExplFrame                                                   ;
;                                                               ;
; Description:                                                  ;
;   Called every frame when game is in the "expl" state         ;
;****************************************************************

ExplFrame:

  ; wait for a bit before be start exploding everything
  ; use levelType3 to keep track, it's initialized with 0 for boss lvl type
  .checkTimer:
    LDA <levelTypeData3
    BEQ .firstFrame
    CMP #WAIT_AFTER_BOSS_DEATH
    BEQ .processExplosions
    JMP .updateTimer
  
  .firstFrame:
  
    JSR PauseSong
  
    ; level type data 1 will serve as explosion counter, together with levelHelperVar2
    LDA #$00
    STA <levelTypeData1
    STA <levelHelperVar2
    
    ; level type data 2 will cache the animation frame the hands of the boss were in so we can keep it consistent
    LDX #BOSS_H_FRAME
    LDA enemies, x
    STA <levelTypeData2
    
    ; level helper var will cache the y position of the head of the boss so we can keep it consistent
    ; the y is shifted by the expl offset though. fix that
    LDX #BOSS_HEAD_Y
    LDA enemies, x
    LDX #CONST_ENEMY_EXPL_OFF + $01 ; expl off y
    SEC
    SBC BossheadConsts, x
    STA <levelHelperVar
    
    ; clear the enemies data
    LDA #$00
    LDX #ENEMIES_TOTAL_SIZE
    LDY #$00
    .clearEnemiesLoop:
      STA enemies, y
      INY
      DEX
      BNE .clearEnemiesLoop
  
  .updateTimer:
    INC <levelTypeData3
    RTS  
  
  .processExplosions:
    
    .clearSprites:
      JSR ClearSprites
    
    .renderElevator:
      JSR RenderElevators
    
    .renderPlayer:
      JSR RenderPlayer
      
    .checkState:
      LDA <levelHelperVar2
      CMP #EXPL_ITERATIONS
      BNE .spawnExplosions
      
      ; all explosions processed.
      INC <levelTypeData1
      LDA <levelTypeData1
      CMP #WAIT_AFTER_EXPL
      BEQ .levelDone
      JMP .renderBoss
      
      .levelDone:
        INC <currentLevel ; last level will be a story one, no need to check for overflow
        JSR WaitForFrame
        JSR FadeOut
        LDX #PLAYER_NOT_V_FADED_OUT
        JSR SleepForXFrames        
        INC <progressGame
        JMP .setNmiFlags
      
    .spawnExplosions:
      LDA <frameCount
      AND #%00000111      ; spawn an explosion every 8 frames
      CMP #%00000111
      BEQ .findFreeSlot
      JMP .renderBoss
            
      .findFreeSlot:
        LDX #AFTER_LAST_ENEMY
        .findEnemySlotLoop:
          TXA
          SEC
          SBC #ENEMY_SIZE
          TAX
          LDA enemies, x
          BEQ .freeSlotFound ; ENEMY_STATE_EMPTY = 0
          JMP .findEnemySlotLoop
        
      ; X points to the free slot
      ; POITAG - possible issue - this is hacky and depends on a bunch of stuff
      .freeSlotFound:
        LDA <levelTypeData1
        ASL A
        TAY ; Y points to the new expl position
        LDA #ENEMY_STATE_EXPLODING
        STA enemies, x ; set state
        
        INX
        INX
        INX ; X points to low consts pointer
        LDA #$00
        STA enemies, x ; 1st explosion
        
        INX
        INX ; X points to the enemy screen
        LDA #$01
        STA enemies, x ; 1st screen
        
        TXA
        CLC
        ADC #(ENEMY_X - ENEMY_SCREEN)
        TAX ; X points to the X position   
        LDA ExplosionPositions, y
        STA enemies, x ; set x position
        
        INX ; X points to the Y position
        INY
        LDA ExplosionPositions, y
        STA enemies, x ; set y position
        
        TXA
        CLC
        ADC #(ENEMY_ANIMATION_TIMER - ENEMY_Y)
        TAX ; X points to the animation timer
        LDA #EXPLOSION_ANIM_SPEED
        STA enemies, x ; set timer
        
        INX ; X points to the frame counter
        LDA #EXPLOSION_ANIM_FRAMES
        STA enemies, x ; set frame counter        
       
      ; todo 0006: play the expl sound
       
      .updateCounters:
        INC <levelTypeData1
        LDA <levelTypeData1
        CMP #EXPLOSION_COUNT
        BNE .renderBoss
        
        LDA #$00
        STA <levelTypeData1
        INC <levelHelperVar2
      
    .renderBoss:
      LDA #$00
      STA <genericOffScreen
      LDA <levelTypeData2
      STA <genericFrame
      LDA #$01
      STA <genericDirection ; flip
      LDA #BOSS_RH_X
      STA <genericX
      LDA #BOSS_RH_Y
      STA <genericY
      LDA #LOW(BossrighthandRender)
      STA <genericPointer
      LDA #HIGH(BossrighthandRender)
      STA <genericPointer + $01
      JSR RenderEnemy
      LDA #BOSS_LH_X
      STA <genericX
      LDA #BOSS_LH_Y
      STA <genericY
      LDA #LOW(BosslefthandRender)
      STA <genericPointer
      LDA #HIGH(BosslefthandRender)
      STA <genericPointer + $01
      JSR RenderEnemy
      
      LDA <levelHelperVar2
      CMP #EXPL_ITERATIONS
      BEQ .updateEnemies ; don't render the head after all the explosions
      LDA #$01
      STA <genericFrame
      LDA #BOSS_HEAD_X
      STA <genericX
      LDA <levelHelperVar
      STA <genericY
      LDA #LOW(BossheadRender)
      STA <genericPointer
      LDA #HIGH(BossheadRender)
      STA <genericPointer + $01
      JSR RenderEnemy
      
    .updateEnemies:
      JSR UpdateEnemies ; this will just update the explosions since we've cleared enemy data

    .setNmiFlags:
      INC <needDma ; only do DMA. we never scroll or draw background  
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
  
  .clearMemory:                   ; clear all loaded enemies, elevators and bullets data
    LDA #$00
    LDX #$00      
    .clear400Loop:        
      STA $0400, x
      STA $0500, x
      STA $0600, x
      INX
      BNE .clear400Loop                      
    
  .loadLevel:                     ; load level
    JSR SetVramAddressingTo32    
    JSR LoadLevel                 ; load level
  
  .loadBgChr:
    JSR SetVramAddressingTo1
    LDY #CHR_BANK
    JSR SwitchBank    
    LDX <tilesetOffset
    LDA Tilesets, x
    STA <genericPointer
    INX
    LDA Tilesets, x
    STA <genericPointer + $01
    JSR LoadBgChr                    
    JSR RestoreBank
    
  .loadPalette:
    JSR LoadBgPalette             ; paletteOffset set by LoadLevel, Vram addressing still 1 from above
    INC <needDraw 
    JSR WaitForFrame              ; wait for values to be written
    
  .restoreVramAddressing:
    JSR SetVramAddressingTo32
  
  .initVars:
    LDA #$00
    STA <nametable                ; show nametable 0 first
    STA <scroll                   ; scroll starts at 0
    STA <scroll + $01
    STA <isPaused
    STA <levelBeaten  
  
  .loadPlayer:                    ; playerX and playerY should be set by LoadLevel  
    JSR LoadPlayer
 
  .enablePPU:                                    
    JSR EnablePPU

  .initializeSound:
    LDX #song_index_song ; todo 0007: song id should be coming from the level data
    JSR PlaySong
  
  JMP WaitForFrame 

;****************************************************************
; ExplosionPositions                                            ;
; Positions for boss explosions                                 ;
;****************************************************************
  
ExplosionPositions:
  .byte $C0, $50
  .byte $B0, $70
  .byte $D0, $30
  .byte $E0, $70
  .byte $90, $20
  .byte $E0, $50
  .byte $D0, $90
  .byte $B0, $30
  .byte $C0, $70
  .byte $A0, $50
  .byte $C0, $10
  .byte $E0, $70
  
EXPLOSION_COUNT = $0C
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

StateGameEnd: