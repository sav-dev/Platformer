;****************************************************************
; Enemies                                                       ;
; Holds information about all enemies (auto-generated)          ;
;****************************************************************

;
;  all offsets for possible grids
;    XOffNxM = x offsets for NxM grid
;    XOffNxMH = x offsets for NxM grid (H flip)
;    YOffNxM = y offsets for NxM grid
;    YOffNxMV = y offsets for NxM grid (V flip)
;

XOff4x3:
  .byte $00, $00, $00, $08, $08, $08, $10, $10, $10, $18, $18, $18
YOff4x3:
  .byte $00, $08, $10, $00, $08, $10, $00, $08, $10, $00, $08, $10
XOff4x3H:
  .byte $18, $18, $18, $10, $10, $10, $08, $08, $08, $00, $00, $00
XOff2x2:
  .byte $00, $00, $08, $08
YOff2x2:
  .byte $00, $08, $00, $08
XOff2x2H:
  .byte $08, $08, $00, $00
YOff2x2V:
  .byte $08, $00, $08, $00

;
;  all information needed to draw an enemy
;  Format:
;    1 byte = sprite count (N)
;    8 bytes = pointers to offsets in order: xOff, yOff, xOffFlip, yOffFlip
;    1 byte = value to XOR with atts if flip
;    N bytes = atts
;    N bytes = frame M - 1
;    N bytes = frame M - 2
;    ...
;    N bytes = frame 1
;    N bytes = frame 0
;

Beetle:
.spriteCount:
  .byte $0C
.offsets:
  .byte LOW(XOff4x3), HIGH(XOff4x3), LOW(YOff4x3), HIGH(YOff4x3), LOW(XOff4x3H), HIGH(XOff4x3H), LOW(YOff4x3), HIGH(YOff4x3)
.flipXor:
  .byte %01000000
.attributes:
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.tiles:
.Beetle2:
  .byte $26,$2A,$35,$27,$2B,$36,$28,$2C,$37,$29,$2D,$2E
.Beetle1:
  .byte $26,$2A,$32,$27,$2B,$33,$28,$2C,$34,$29,$2D,$2E
.Beetle0:
  .byte $26,$2A,$2F,$27,$2B,$30,$28,$2C,$31,$29,$2D,$2E

Bug:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $00,$00,$00,$00
.tiles:
.Bug1:
  .byte $38,$3C,$39,$3D
.Bug0:
  .byte $38,$3A,$39,$3B

Eye:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $02,$82,$02,$82
.tiles:
.Eye:
  .byte $3E,$3E,$3F,$3F

Spikes:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %00000000
.attributes:
  .byte $02,$02,$02,$02
.tiles:
.Spikes:
  .byte $40,$42,$41,$43

TurretV:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2V), HIGH(YOff2x2V)
.flipXor:
  .byte %10000000
.attributes:
  .byte $01,$81,$01,$01
.tiles:
.TurretV:
  .byte $44,$44,$45,$46

TurretH:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $01,$01,$01,$41
.tiles:
.TurretH:
  .byte $47,$49,$48,$49


