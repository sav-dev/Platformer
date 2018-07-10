;****************************************************************
; Enemies                                                       ;
; Holds information about all enemies (auto-generated)          ;
;****************************************************************

;
;  constant properties for enemies
;    width           : 1 byte
;    hitbox x off    : 1 byte
;    hitbox width    : 1 byte (inclusive)
;    hitbox y off    : 1 byte
;    hitbox height   : 1 byte (inclusive)
;    gun x off       : 1 byte (0 for non shooting)
;    gun y off       : 1 byte (0 for non shooting)
;    gun x off flip  : 1 byte (0 for non shooting)
;    gun y off flip  : 1 byte (0 for non shooting)
;    animation speed : 1 byte (0 for non animated)
;    # of frames     : 1 bytes
;    rendering info  : 2 bytes
;    expl. offsets   : 2 bytes (x/y)
;
;  ordered by animation id
;

EnemyConsts:

BeetleConsts:
.width:
  .byte $20
.hitboxInfo:
  .byte $02,$1B,$04,$10
.gunInfo:
  .byte $1E,$05,$01,$05
.animationSpeed:
  .byte $08
.numberOfFrames:
  .byte $03
.renderingInfo:
  .byte LOW(BeetleRender), HIGH(BeetleRender)
.explosionOffset:
  .byte $08, $08

BugConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0B,$04,$0A
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $06
.numberOfFrames:
  .byte $02
.renderingInfo:
  .byte LOW(BugRender), HIGH(BugRender)
.explosionOffset:
  .byte $00, $00

EyeConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $03,$09,$02,$0B
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(EyeRender), HIGH(EyeRender)
.explosionOffset:
  .byte $00, $00

SpikesConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0A,$02,$0A
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(SpikesRender), HIGH(SpikesRender)
.explosionOffset:
  .byte $00, $00

TurretVConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.gunInfo:
  .byte $0C,$0F,$0C,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretVRender), HIGH(TurretVRender)
.explosionOffset:
  .byte $00, $00

TurretHConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.gunInfo:
  .byte $0F,$03,$00,$03
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretHRender), HIGH(TurretHRender)
.explosionOffset:
  .byte $00, $00


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

BeetleRender:
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

BugRender:
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

EyeRender:
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

SpikesRender:
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

TurretVRender:
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

TurretHRender:
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


