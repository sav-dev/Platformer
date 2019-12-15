
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
  .byte $06
.numberOfFrames:
  .byte $04
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
  .byte $01,$15,$02,$0D
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
  .byte $01,$15,$02,$0D
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
  .byte $00,$07,$00,$2F
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
  .byte $00,$2F,$00,$07
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
  .byte $02,$0B,$01,$06
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

GreenBlobConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$06,$09
.orientation:
  .byte $01
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $05
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(GreenBlobRender), HIGH(GreenBlobRender)
.explosionOffset:
  .byte $00, $00

PinkBlobConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$06,$09
.orientation:
  .byte $01
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $05
.numberOfFrames:
  .byte $04
.renderingInfo:
  .byte LOW(PinkBlobRender), HIGH(PinkBlobRender)
.explosionOffset:
  .byte $00, $00

TankConsts:
.width:
  .byte $20
.hitboxInfo:
  .byte $05,$16,$01,$16
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

AcidConsts:
.width:
  .byte $10
.hitboxInfo:
  .byte $01,$0D,$08,$07
.orientation:
  .byte $02
.gunInfo:
  .byte $00,$00,$00,$00
.animationSpeed:
  .byte $07
.numberOfFrames:
  .byte $0C
.renderingInfo:
  .byte LOW(AcidRender), HIGH(AcidRender)
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
.Frame3_Beetle1:
  .byte $27,$2B,$33,$28,$2C,$34,$29,$2D,$35,$2A,$2E,$2F
.Frame2_Beetle2:
  .byte $27,$2B,$36,$28,$2C,$37,$29,$2D,$38,$2A,$2E,$2F
.Frame1_Beetle1:
  .byte $27,$2B,$33,$28,$2C,$34,$29,$2D,$35,$2A,$2E,$2F
.Frame0_Beetle0:
  .byte $27,$2B,$30,$28,$2C,$31,$29,$2D,$32,$2A,$2E,$2F

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
  .byte $39,$3D,$3A,$3E
.Frame0_Bug0:
  .byte $39,$3B,$3A,$3C

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
  .byte $3F,$3F,$40,$40

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
  .byte $41,$43,$42,$44

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
  .byte $45,$45,$46,$47

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
  .byte $48,$4A,$49,$4A

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
  .byte $4B,$4D,$4C,$4E

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
  .byte $4F,$55,$51,$56,$4F,$57
.Frame0_FlyingRobot0:
  .byte $4F,$52,$50,$53,$4F,$54

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
  .byte $4F,$55,$5B,$51,$56,$5C,$4F,$57,$5D
.Frame2_WalkingRobot2:
  .byte $4F,$55,$58,$51,$56,$59,$4F,$57,$5A
.Frame1_WalkingRobot1:
  .byte $4F,$52,$5B,$50,$53,$5C,$4F,$54,$5D
.Frame0_WalkingRobot0:
  .byte $4F,$52,$58,$50,$53,$59,$4F,$54,$5A

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
  .byte $5E,$5E,$5E,$5E,$5E,$5E

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
  .byte $5F,$5F,$5F,$5F,$5F,$5F

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
  .byte $64,$65
.Frame2_Blinker1:
  .byte $60,$61
.Frame1_Blinker2:
  .byte $62,$63
.Frame0_Blinker1:
  .byte $60,$61

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
  .byte $6E,$70,$6F,$71
.Frame2_Blob1:
  .byte $66,$68,$67,$69
.Frame1_Blob2:
  .byte $6A,$6C,$6B,$6D
.Frame0_Blob1:
  .byte $66,$68,$67,$69

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
  .byte $6E,$70,$6F,$71
.Frame2_Blob1:
  .byte $66,$68,$67,$69
.Frame1_Blob2:
  .byte $6A,$6C,$6B,$6D
.Frame0_Blob1:
  .byte $66,$68,$67,$69

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
  .byte $72,$75,$7C,$73,$76,$7D,$74,$77,$7E,CLEAR_SPRITE,CLEAR_SPRITE,$7F
.Frame0_Tank1:
  .byte $72,$75,$78,$73,$76,$79,$74,$77,$7A,CLEAR_SPRITE,CLEAR_SPRITE,$7B

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
  .byte CLEAR_SPRITE,$86,$8B,$87
.Frame10_Acid7:
  .byte CLEAR_SPRITE,$84,$8A,$85
.Frame9_Acid6:
  .byte CLEAR_SPRITE,$82,$89,$83
.Frame8_Acid5:
  .byte CLEAR_SPRITE,$80,CLEAR_SPRITE,$88
.Frame7_Acid4:
  .byte CLEAR_SPRITE,$86,CLEAR_SPRITE,$87
.Frame6_Acid3:
  .byte CLEAR_SPRITE,$84,CLEAR_SPRITE,$85
.Frame5_Acid2:
  .byte CLEAR_SPRITE,$82,CLEAR_SPRITE,$83
.Frame4_Acid1:
  .byte CLEAR_SPRITE,$80,CLEAR_SPRITE,$81
.Frame3_Acid4:
  .byte CLEAR_SPRITE,$86,CLEAR_SPRITE,$87
.Frame2_Acid3:
  .byte CLEAR_SPRITE,$84,CLEAR_SPRITE,$85
.Frame1_Acid2:
  .byte CLEAR_SPRITE,$82,CLEAR_SPRITE,$83
.Frame0_Acid1:
  .byte CLEAR_SPRITE,$80,CLEAR_SPRITE,$81


EnemiesEnd:
