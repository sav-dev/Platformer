;****************************************************************
; LevelManager                                                  ;
; Responsible for loading levels                                ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   LoadLevel                                                   ;
;                                                               ;
; Description:                                                  ;
;   Loads all level data, including drawing the first screen.   ;
;   Must be called with PPU disabled.                           ;
;                                                               ;
; Input variables:                                              ;
;   levelPointer                                                ;
;                                                               ;
; Output variables:                                             ;
;   maxScroll                                                   ;
;   levelPointer                                                ;
;   levelBackPointer                                            ;
;   attsPointer                                                 ;
;   attsBackPointer                                             ;
;   platformsPointer                                            ;
;   threatsPointer                                              ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   j                                                           ;
;   genericPointer                                              ;
;****************************************************************

LoadLevel:

  ; todo: add bg palette

  ; load level background - input is levelPointer, sets max scroll and genericPointer (to 1st byte after background data)
  JSR LoadLevelBackground    

  ; load platforms and threats - input is genericPointer, sets platformsPointer, threatsPointer and genericPointer (to 1st byte after platforms/threats data)  
  JSR LoadPlatformsAndThreats
  
  ; load enemies - input is genericPointer, sets enemiesPointer and genericPointer (to 1st byte after enemy data)
  JSR LoadEnemiesInitial
  
  ; load enemies - input is genericPointer, sets elevators and genericPointer (to 1st byte after enemy data)
  JSR LoadElevatorsInitial
  
  ; todo: add level type, different victory conditions
  
  ; everything has been loaded, only thing left is player starting position and exit position. format:
  ;  - starting position x (genericPointer points here)
  ;  - starting position y
  ;  - exit screen
  ;  - exit x
  ;  - exit y1 and y2 (calculate)
  LDY #$00
  LDA [genericPointer], y
  STA playerX
  
  INY
  LDA [genericPointer], y
  STA playerY
  
  INY
  LDA [genericPointer], y
  STA levelExitScreen
  
  INY
  LDA [genericPointer], y
  STA levelExitX
  
  INY
  LDA [genericPointer], y
  STA levelExitY1
  CLC
  ADC #EXIT_HEIGHT
  STA levelExitY2
  
RTS