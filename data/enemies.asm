
EnemiesStart:

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
;    orientation     : 1 byte (see ORIENTATION_* consts)
;    gun x off       : 1 byte (signed, 0 for non shooting)
;    gun y off       : 1 byte (signed, 0 for non shooting)
;    gun x off flip  : 1 byte (signed, 0 for non shooting)
;    gun y off flip  : 1 byte (signed, 0 for non shooting)
;    animation speed : 1 byte (0 for non animated)
;    # of frames     : 1 bytes
;    rendering info  : 2 bytes
;    expl. offsets   : 2 bytes (x/y)
;
;  ordered by animation id
;
;  tag: depends_on_enemy_consts_format

EnemyConsts:

BeetleConsts:
.width:
  .byte $20
.hitboxInfo:
  .byte $02,$1B,$04,$10
.orientation:
  .byte $01
.gunInfo:
  .byte $1E,$03,$F9,$03
.animationSpeed:
  .byte $08
.numberOfFrames:
  .byte $03
.renderingInfo:
  .byte LOW(BeetleRender), HIGH(BeetleRender)
.explosionOffset:
  .byte $08, $04

BugConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0B,$04,$0A
.orientation:
  .byte $01
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
.orientation:
  .byte $01
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
.orientation:
  .byte $02
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
.orientation:
  .byte $00
.gunInfo:
  .byte $0A,$0F,$0A,$F8
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
.orientation:
  .byte $01
.gunInfo:
  .byte $0F,$01,$F8,$01
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretHRender), HIGH(TurretHRender)
.explosionOffset:
  .byte $00, $00

SphereConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.orientation:
  .byte $01
.gunInfo:
  .byte $0D,$06,$FA,$06
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(SphereRender), HIGH(SphereRender)
.explosionOffset:
  .byte $00, $00

FlyingRobotConsts:
.width:
  .byte $18
.hitboxInfo:
  .byte $01,$16,$02,$0D
.orientation:
  .byte $02
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $14
.numberOfFrames:
  .byte $02
.renderingInfo:
  .byte LOW(FlyingRobotRender), HIGH(FlyingRobotRender)
.explosionOffset:
  .byte $04, $00

WalkingRobotConsts:
.width:
  .byte $18
.hitboxInfo:
  .byte $01,$16,$02,$0D
.orientation:
  .byte $02
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $0A
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(WalkingRobotRender), HIGH(WalkingRobotRender)
.explosionOffset:
  .byte $04, $04

BarrierV6Consts:
.width:
  .byte $08
.hitboxInfo:
  .byte $00,$08,$00,$30
.orientation:
  .byte $02
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(BarrierV6Render), HIGH(BarrierV6Render)
.explosionOffset:
  .byte $FFFFFFFC, $10

BarrierH6Consts:
.width:
  .byte $30
.hitboxInfo:
  .byte $00,$30,$00,$08
.orientation:
  .byte $02
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(BarrierH6Render), HIGH(BarrierH6Render)
.explosionOffset:
  .byte $10, $FFFFFFFC

BlinkerConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0C,$01,$06
.orientation:
  .byte $02
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $05
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(BlinkerRender), HIGH(BlinkerRender)
.explosionOffset:
  .byte $00, $FFFFFFFC

BlobConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0E,$06,$09
.orientation:
  .byte $01
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $06
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(BlobRender), HIGH(BlobRender)
.explosionOffset:
  .byte $00, $00

TankConsts:
.width:
  .byte $20
.hitboxInfo:
  .byte $07,$17,$02,$16
.orientation:
  .byte $01
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $04
.numberOfFrames:
  .byte $02
.renderingInfo:
  .byte LOW(TankRender), HIGH(TankRender)
.explosionOffset:
  .byte $08, $04


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
XOff3x2:
  .byte $00, $00, $08, $08, $10, $10
YOff3x2:
  .byte $00, $08, $00, $08, $00, $08
XOff3x3:
  .byte $00, $00, $00, $08, $08, $08, $10, $10, $10
YOff3x3:
  .byte $00, $08, $10, $00, $08, $10, $00, $08, $10
XOff1x6:
  .byte $00, $00, $00, $00, $00, $00
YOff1x6:
  .byte $00, $08, $10, $18, $20, $28
XOff6x1:
  .byte $00, $08, $10, $18, $20, $28
YOff6x1:
  .byte $00, $00, $00, $00, $00, $00
XOff2x1:
  .byte $00, $08
YOff2x1:
  .byte $00, $00

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
.Frame2_Beetle2:
  .byte $26,$2A,$35,$27,$2B,$36,$28,$2C,$37,$29,$2D,$2E
.Frame1_Beetle1:
  .byte $26,$2A,$32,$27,$2B,$33,$28,$2C,$34,$29,$2D,$2E
.Frame0_Beetle0:
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
.Frame1_Bug1:
  .byte $38,$3C,$39,$3D
.Frame0_Bug0:
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
.Frame0_Eye:
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
.Frame0_Spikes:
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
.Frame0_TurretV:
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
.Frame0_TurretH:
  .byte $47,$49,$48,$49

SphereRender:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $01,$01,$01,$01
.tiles:
.Frame0_Sphere:
  .byte $4A,$4C,$4B,$4D

FlyingRobotRender:
.spriteCount:
  .byte $06
.offsets:
  .byte LOW(XOff3x2), HIGH(XOff3x2), LOW(YOff3x2), HIGH(YOff3x2), LOW(XOff3x2), HIGH(XOff3x2), LOW(YOff3x2), HIGH(YOff3x2)
.flipXor:
  .byte %00000000
.attributes:
  .byte $00,$00,$00,$00,$40,$00
.tiles:
.Frame1_FlyingRobot1:
  .byte $4E,$54,$50,$55,$4E,$56
.Frame0_FlyingRobot0:
  .byte $4E,$51,$4F,$52,$4E,$53

WalkingRobotRender:
.spriteCount:
  .byte $09
.offsets:
  .byte LOW(XOff3x3), HIGH(XOff3x3), LOW(YOff3x3), HIGH(YOff3x3), LOW(XOff3x3), HIGH(XOff3x3), LOW(YOff3x3), HIGH(YOff3x3)
.flipXor:
  .byte %00000000
.attributes:
  .byte $00,$00,$01,$00,$00,$01,$40,$00,$01
.tiles:
.Frame3_WalkingRobot3:
  .byte $4E,$54,$5A,$50,$55,$5B,$4E,$56,$5C
.Frame2_WalkingRobot2:
  .byte $4E,$54,$57,$50,$55,$58,$4E,$56,$59
.Frame1_WalkingRobot1:
  .byte $4E,$51,$5A,$4F,$52,$5B,$4E,$53,$5C
.Frame0_WalkingRobot0:
  .byte $4E,$51,$57,$4F,$52,$58,$4E,$53,$59

BarrierV6Render:
.spriteCount:
  .byte $06
.offsets:
  .byte LOW(XOff1x6), HIGH(XOff1x6), LOW(YOff1x6), HIGH(YOff1x6), LOW(XOff1x6), HIGH(XOff1x6), LOW(YOff1x6), HIGH(YOff1x6)
.flipXor:
  .byte %00000000
.attributes:
  .byte $02,$02,$02,$02,$02,$02
.tiles:
.Frame0_BarrierV6:
  .byte $5D,$5D,$5D,$5D,$5D,$5D

BarrierH6Render:
.spriteCount:
  .byte $06
.offsets:
  .byte LOW(XOff6x1), HIGH(XOff6x1), LOW(YOff6x1), HIGH(YOff6x1), LOW(XOff6x1), HIGH(XOff6x1), LOW(YOff6x1), HIGH(YOff6x1)
.flipXor:
  .byte %00000000
.attributes:
  .byte $02,$02,$02,$02,$02,$02
.tiles:
.Frame0_BarrierH6:
  .byte $5E,$5E,$5E,$5E,$5E,$5E

BlinkerRender:
.spriteCount:
  .byte $02
.offsets:
  .byte LOW(XOff2x1), HIGH(XOff2x1), LOW(YOff2x1), HIGH(YOff2x1), LOW(XOff2x1), HIGH(XOff2x1), LOW(YOff2x1), HIGH(YOff2x1)
.flipXor:
  .byte %00000000
.attributes:
  .byte $00,$00
.tiles:
.Frame3_Blinker3:
  .byte $63,$64
.Frame2_Blinker1:
  .byte $5F,$60
.Frame1_Blinker2:
  .byte $61,$62
.Frame0_Blinker1:
  .byte $5F,$60

BlobRender:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $03,$03,$03,$03
.tiles:
.Frame3_Blob3:
  .byte $6D,$6F,$6E,$70
.Frame2_Blob1:
  .byte $65,$67,$66,$68
.Frame1_Blob2:
  .byte $69,$6B,$6A,$6C
.Frame0_Blob1:
  .byte $65,$67,$66,$68

TankRender:
.spriteCount:
  .byte $0C
.offsets:
  .byte LOW(XOff4x3), HIGH(XOff4x3), LOW(YOff4x3), HIGH(YOff4x3), LOW(XOff4x3H), HIGH(XOff4x3H), LOW(YOff4x3), HIGH(YOff4x3)
.flipXor:
  .byte %01000000
.attributes:
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.tiles:
.Frame1_Tank2:
  .byte CLEAR_SPRITE,CLEAR_SPRITE,$7B,$71,$74,$7C,$72,$75,$7D,$73,$76,$7E
.Frame0_Tank1:
  .byte CLEAR_SPRITE,CLEAR_SPRITE,$77,$71,$74,$78,$72,$75,$79,$73,$76,$7A


EnemiesEnd:
