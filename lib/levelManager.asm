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

  ; load level background - input is levelPointer, sets max scroll and genericPointer (to 1st byte after background data)
  JSR LoadLevelBackground    

  ; load platforms and threats - input is genericPointer, sets platformsPointer, threatsPointer and genericPointer (to 1st byte after platforms/threats data)  
  JSR LoadPlatformsAndThreats
  
  ; load enemies - input is genericPointer, sets enemiesPointer and genericPointer (to 1st byte after enemy data)
  JSR LoadEnemiesInitial
  
  ; everything has been loaded, only thing left is player starting position and exit position. format:
  ;  - starting position x (genericPointer points here)
  ;  - starting position y
  ;  - exit screen
  ;  - exit x
  ;  - exit y
  LDY #$00
  LDA [genericPointer], y
  STA playerX
  
  INY
  LDA [genericPointer], y
  STA playerY
  
  ; {todo load and store exit screen/x/y, probably not need to put it in zero page if we check it on dpad up}
  
  INY
  LDA [genericPointer], y
  ; STA levelExitScreen
  
  INY
  LDA [genericPointer], y
  ; STA levelExitX
  
  INY
  LDA [genericPointer], y
  ; STA levelExitY   
  
RTS