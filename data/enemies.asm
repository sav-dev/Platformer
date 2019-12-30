EnemiesStart:

;****************************************************************
; Enemies                                                       ;
; Holds information about all enemies (auto-generated)          ;
; POITAG - possible optimization - bytes savings - lots of      ;
; duplication here, especially with cloned palette-swap enemies ;
;****************************************************************

;
;  constant properties for enemies
;    width           : 1 byte
;    hitbox x off    : 1 byte
;    hitbox width    : 1 byte (inclusive)
;    hitbox y off    : 1 byte
;    hitbox height   : 1 byte (inclusive)
;    orientation     : 1 byte (see ORIENTATION_* consts)
;    bullet pointer  : 1 byte
;    gun x off       : 1 byte (signed, 0 for non shooting)
;    gun y off       : 1 byte (signed, 0 for non shooting)
;    gun x off flip  : 1 byte (signed, 0 for non shooting)
;    gun y off flip  : 1 byte (signed, 0 for non shooting)
;    animation speed : 1 byte (0 for non animated)
;    # of frames     : 1 bytes
;    rendering info  : 2 bytes (pointer)
;    expl. pointer   : 1 byte
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
.bulletPointer:
  .byte $4E
.gunInfo:
  .byte $1F,$04,$F9,$04
.animationSpeed:
  .byte $06
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(BeetleRender), HIGH(BeetleRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $08, $04

BugConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0B,$04,$0A
.orientation:
  .byte $01
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $06
.numberOfFrames:
  .byte $02
.renderingInfo:
  .byte LOW(BugRender), HIGH(BugRender)
.explosionPointer:
  .byte $03
.explosionOffset:
  .byte $00, $00

EyeConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $03,$09,$02,$0B
.orientation:
  .byte $01
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(EyeRender), HIGH(EyeRender)
.explosionPointer:
  .byte $06
.explosionOffset:
  .byte $00, $00

SpikesConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0A,$02,$0A
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(SpikesRender), HIGH(SpikesRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $00

TurretVConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.orientation:
  .byte $00
.bulletPointer:
  .byte $0D
.gunInfo:
  .byte $0A,$10,$0A,$F8
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretVRender), HIGH(TurretVRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $00

TurretHConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.orientation:
  .byte $01
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $10,$02,$F8,$02
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretHRender), HIGH(TurretHRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $00

SphereConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.orientation:
  .byte $01
.bulletPointer:
  .byte $5B
.gunInfo:
  .byte $0D,$06,$FB,$06
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(SphereRender), HIGH(SphereRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $00

FlyingRobotConsts:
.width:
  .byte $18
.hitboxInfo:
  .byte $01,$15,$02,$0D
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $14
.numberOfFrames:
  .byte $02
.renderingInfo:
  .byte LOW(FlyingRobotRender), HIGH(FlyingRobotRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $04, $00

WalkingRobotConsts:
.width:
  .byte $18
.hitboxInfo:
  .byte $01,$15,$02,$0D
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $0A
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(WalkingRobotRender), HIGH(WalkingRobotRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $04, $04

BarrierV6Consts:
.width:
  .byte $08
.hitboxInfo:
  .byte $00,$07,$00,$2F
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(BarrierV6Render), HIGH(BarrierV6Render)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $FFFFFFFC, $10

BarrierH6Consts:
.width:
  .byte $30
.hitboxInfo:
  .byte $00,$2F,$00,$07
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(BarrierH6Render), HIGH(BarrierH6Render)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $10, $FFFFFFFC

BlinkerConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $02,$0B,$01,$06
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $05
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(BlinkerRender), HIGH(BlinkerRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $FFFFFFFC

GreenBlobConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$06,$09
.orientation:
  .byte $01
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $05
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(GreenBlobRender), HIGH(GreenBlobRender)
.explosionPointer:
  .byte $03
.explosionOffset:
  .byte $00, $00

PinkBlobConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$06,$09
.orientation:
  .byte $01
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $05
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(PinkBlobRender), HIGH(PinkBlobRender)
.explosionPointer:
  .byte $06
.explosionOffset:
  .byte $00, $00

TankConsts:
.width:
  .byte $20
.hitboxInfo:
  .byte $05,$16,$01,$16
.orientation:
  .byte $01
.bulletPointer:
  .byte $34
.gunInfo:
  .byte $17,$02,$01,$02
.animationSpeed:
  .byte $04
.numberOfFrames:
  .byte $02
.renderingInfo:
  .byte LOW(TankRender), HIGH(TankRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $08, $04

AcidConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$08,$07
.orientation:
  .byte $02
.bulletPointer:
  .byte $00
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $07
.numberOfFrames:
  .byte $0C
.renderingInfo:
  .byte LOW(AcidRender), HIGH(AcidRender)
.explosionPointer:
  .byte $06
.explosionOffset:
  .byte $00, $00

TurretD1Consts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.orientation:
  .byte $01
.bulletPointer:
  .byte $1A
.gunInfo:
  .byte $0E,$F9,$FA,$F9
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretD1Render), HIGH(TurretD1Render)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $00

TurretD2Consts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$01,$0D
.orientation:
  .byte $01
.bulletPointer:
  .byte $27
.gunInfo:
  .byte $0E,$0F,$FA,$0F
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(TurretD2Render), HIGH(TurretD2Render)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $00, $00

GunnerRobotConsts:
.width:
  .byte $18
.hitboxInfo:
  .byte $05,$0D,$01,$1E
.orientation:
  .byte $01
.bulletPointer:
  .byte $41
.gunInfo:
  .byte $18,$0B,$F8,$0B
.animationSpeed:
  .byte $00
.numberOfFrames:
  .byte $01
.renderingInfo:
  .byte LOW(GunnerRobotRender), HIGH(GunnerRobotRender)
.explosionPointer:
  .byte $00
.explosionOffset:
  .byte $04, $08


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
XOff3x4:
  .byte $00, $00, $00, $00, $08, $08, $08, $08, $10, $10, $10, $10
YOff3x4:
  .byte $00, $08, $10, $18, $00, $08, $10, $18, $00, $08, $10, $18
XOff3x4H:
  .byte $10, $10, $10, $10, $08, $08, $08, $08, $00, $00, $00, $00

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
.Frame3_Beetle1:
  .byte $34,$38,$40,$35,$39,$41,$36,$3A,$42,$37,$3B,$3C
.Frame2_Beetle2:
  .byte $34,$38,$43,$35,$39,$44,$36,$3A,$45,$37,$3B,$3C
.Frame1_Beetle1:
  .byte $34,$38,$40,$35,$39,$41,$36,$3A,$42,$37,$3B,$3C
.Frame0_Beetle0:
  .byte $34,$38,$3D,$35,$39,$3E,$36,$3A,$3F,$37,$3B,$3C

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
  .byte $46,$4A,$47,$4B
.Frame0_Bug0:
  .byte $46,$48,$47,$49

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
  .byte $4C,$4C,$4D,$4D

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
  .byte $4E,$50,$4F,$51

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
  .byte $52,$52,$53,$54

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
  .byte $55,$57,$56,$57

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
  .byte $58,$5A,$59,$5B

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
  .byte $5C,$62,$5E,$63,$5C,$64
.Frame0_FlyingRobot0:
  .byte $5C,$5F,$5D,$60,$5C,$61

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
  .byte $5C,$62,$68,$5E,$63,$69,$5C,$64,$6A
.Frame2_WalkingRobot2:
  .byte $5C,$62,$65,$5E,$63,$66,$5C,$64,$67
.Frame1_WalkingRobot1:
  .byte $5C,$5F,$68,$5D,$60,$69,$5C,$61,$6A
.Frame0_WalkingRobot0:
  .byte $5C,$5F,$65,$5D,$60,$66,$5C,$61,$67

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
  .byte $6B,$6B,$6B,$6B,$6B,$6B

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
  .byte $6C,$6C,$6C,$6C,$6C,$6C

BlinkerRender:
.spriteCount:
  .byte $02
.offsets:
  .byte LOW(XOff2x1), HIGH(XOff2x1), LOW(YOff2x1), HIGH(YOff2x1), LOW(XOff2x1), HIGH(XOff2x1), LOW(YOff2x1), HIGH(YOff2x1)
.flipXor:
  .byte %00000000
.attributes:
  .byte $00,$40
.tiles:
.Frame3_Blinker3:
  .byte $6F,$6F
.Frame2_Blinker1:
  .byte $6D,$6D
.Frame1_Blinker2:
  .byte $6E,$6E
.Frame0_Blinker1:
  .byte $6D,$6D

GreenBlobRender:
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
  .byte $78,$7A,$79,$7B
.Frame2_Blob1:
  .byte $70,$72,$71,$73
.Frame1_Blob2:
  .byte $74,$76,$75,$77
.Frame0_Blob1:
  .byte $70,$72,$71,$73

PinkBlobRender:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $02,$02,$02,$02
.tiles:
.Frame3_Blob3:
  .byte $78,$7A,$79,$7B
.Frame2_Blob1:
  .byte $70,$72,$71,$73
.Frame1_Blob2:
  .byte $74,$76,$75,$77
.Frame0_Blob1:
  .byte $70,$72,$71,$73

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
  .byte $7C,$7F,$86,$7D,$80,$87,$7E,$81,$88,CLEAR_SPRITE,CLEAR_SPRITE,$89
.Frame0_Tank1:
  .byte $7C,$7F,$82,$7D,$80,$83,$7E,$81,$84,CLEAR_SPRITE,CLEAR_SPRITE,$85

AcidRender:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %00000000
.attributes:
  .byte $01,$02,$01,$02
.tiles:
.Frame11_Acid8:
  .byte CLEAR_SPRITE,$90,$95,$91
.Frame10_Acid7:
  .byte CLEAR_SPRITE,$8E,$94,$8F
.Frame9_Acid6:
  .byte CLEAR_SPRITE,$8C,$93,$8D
.Frame8_Acid5:
  .byte CLEAR_SPRITE,$8A,CLEAR_SPRITE,$92
.Frame7_Acid4:
  .byte CLEAR_SPRITE,$90,CLEAR_SPRITE,$91
.Frame6_Acid3:
  .byte CLEAR_SPRITE,$8E,CLEAR_SPRITE,$8F
.Frame5_Acid2:
  .byte CLEAR_SPRITE,$8C,CLEAR_SPRITE,$8D
.Frame4_Acid1:
  .byte CLEAR_SPRITE,$8A,CLEAR_SPRITE,$8B
.Frame3_Acid4:
  .byte CLEAR_SPRITE,$90,CLEAR_SPRITE,$91
.Frame2_Acid3:
  .byte CLEAR_SPRITE,$8E,CLEAR_SPRITE,$8F
.Frame1_Acid2:
  .byte CLEAR_SPRITE,$8C,CLEAR_SPRITE,$8D
.Frame0_Acid1:
  .byte CLEAR_SPRITE,$8A,CLEAR_SPRITE,$8B

TurretD1Render:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $01,$01,$01,$01
.tiles:
.Frame0_TurretD1:
  .byte $96,$98,$97,$99

TurretD2Render:
.spriteCount:
  .byte $04
.offsets:
  .byte LOW(XOff2x2), HIGH(XOff2x2), LOW(YOff2x2), HIGH(YOff2x2), LOW(XOff2x2H), HIGH(XOff2x2H), LOW(YOff2x2), HIGH(YOff2x2)
.flipXor:
  .byte %01000000
.attributes:
  .byte $81,$81,$81,$81
.tiles:
.Frame0_TurretD2:
  .byte $98,$96,$99,$97

GunnerRobotRender:
.spriteCount:
  .byte $0C
.offsets:
  .byte LOW(XOff3x4), HIGH(XOff3x4), LOW(YOff3x4), HIGH(YOff3x4), LOW(XOff3x4H), HIGH(XOff3x4H), LOW(YOff3x4), HIGH(YOff3x4)
.flipXor:
  .byte %01000000
.attributes:
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.tiles:
.Frame0_GunnerRobot:
  .byte $9A,$9C,$9F,$A1,$9B,$9D,$A0,$A2,CLEAR_SPRITE,$9E,CLEAR_SPRITE,CLEAR_SPRITE


EnemiesEnd:
