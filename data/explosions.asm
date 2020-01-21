ExplosionsStart:

;****************************************************************
; Explosions                                                    ;
; Holds information about explosions (auto-generated)           ;
;****************************************************************

explosionXOff1st:
  .byte $05, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE
; Commented out for optimization, use XOff2x2 instead
;explosionXOffRest:
;  .byte $00, $00, $08, $08
explosionYOff1st:
  .byte $04, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE
; Commented out for optimization, use YOff2x2 instead
;explosionYOffRest:
;  .byte $00, $08, $00, $08

Explosions:
Explosion0:
.attributes:
  .byte $00
.pointer:
  .byte LOW(Explosion0Tiles), HIGH(Explosion0Tiles)
.sound:
  .byte sfx_index_sfx_explode
Explosion1:
.attributes:
  .byte $03
.pointer:
  .byte LOW(Explosion1Tiles), HIGH(Explosion1Tiles)
.sound:
  .byte sfx_index_sfx_zap
Explosion2:
.attributes:
  .byte $02
.pointer:
  .byte LOW(Explosion1Tiles), HIGH(Explosion1Tiles)
.sound:
  .byte sfx_index_sfx_zap

ExplosionTiles:
Explosion0Tiles:
  .byte $23, $25, $24, $26
  .byte $1F, $21, $20, $22
  .byte $1B, $1D, $1C, $1E
  .byte $1A, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE
Explosion1Tiles:
  .byte $30, $32, $31, $33
  .byte $2C, $2E, $2D, $2F
  .byte $28, $2A, $29, $2B
  .byte $27, CLEAR_SPRITE, CLEAR_SPRITE, CLEAR_SPRITE

ExplosionsEnd:
