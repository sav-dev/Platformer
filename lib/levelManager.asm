LevelManagerStart:

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
;   tilesetOffset                                               ;
;   paletteOffset                                               ;
;   playerX                                                     ;
;   playerY                                                     ;
;   door and keycard vars                                       ;
;   level type                                                  ;
;   win condition vars                                          ;
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
  
  ; load enemies - input is genericPointer, sets elevators and genericPointer (to 1st byte after elevator data)
  JSR LoadElevatorsInitial
  
  ; load door and keycard data - input is genericPointer, sets door and keycard vars and genericPointer (to 1st byte after door/keycard data)
  JSR LoadDoorAndKeycard
  
  ; next 2 bytes are tilesetOffset and paletteOffset
  LDY #$00
  LDA [genericPointer], y
  STA <tilesetOffset
  INY
  LDA [genericPointer], y
  STA <paletteOffset
  LDA <genericPointer
  CLC
  ADC #$02
  STA <genericPointer
  LDA <genericPointer + $01
  ADC #$00
  STA <genericPointer + $01
  
  ; next 2 bytes are players starting position
  LDY #$00
  LDA [genericPointer], y
  STA <playerX 
  INY
  LDA [genericPointer], y
  STA <playerY
  LDA <genericPointer
  CLC
  ADC #$02
  STA <genericPointer
  LDA <genericPointer + $01
  ADC #$00
  STA <genericPointer + $01
  
  ; next 4 bytes are level data
  ;  - level type
  ;  - 3 bytes of level vars
  LDY #$00
  LDA [genericPointer], y
  STA <levelType
  INY
  LDA [genericPointer], y
  STA <levelTypeData1
  INY
  LDA [genericPointer], y
  STA <levelTypeData2 
  INY
  LDA [genericPointer], y
  STA <levelTypeData3
  
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

LevelManagerEnd: