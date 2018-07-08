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
  JSR LoadLevelBackground      ; load level background, uses levelPointer, sets max scroll and genericPointer (to 1st byte after background data)
  JSR LoadPlatformsAndThreats  ; load platforms and threats, sets platformsPointer, threatsPointer and genericPointer (to 1st byte after platforms/threats data)
  JSR LoadEnemiesInitial       ; load enemies, sets enemiesPointer and genericPointer (to 1st byte after enemy data)
  
  ; todo - add more stuff, like enemies, starting x/y
  ; for now player position is hardcoded
  LDA #$30
  STA playerX
  LDA #$CF
  STA playerY
  
RTS