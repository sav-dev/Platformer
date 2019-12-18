BulletsStart:

;****************************************************************
; Bullets                                                       ;
; Holds information about all bullets (auto-generated)          ;
;****************************************************************

;
;  constant properties for bullets
;    sprite id          : 1 byte
;    box width, height  : 2 bytes
;    atts               : 1 byte
;    bullet dx, dy      : 2 bytes
;    box dx, dy         : 2 bytes
;    atts flip          : 1 byte
;    bullet dx, dy flip : 2 bytes
;    box dx, dy flip    : 2 bytes
;
;  ordered by bullet id
;
;  tag: depends_on_bullets_consts_format


BulletConsts:

Turret_Horizontal:
.spriteId:
  .byte $99
.boxSize:
  .byte $05, $03
.atts:
  .byte $00
.speed:
  .byte $04, $00
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $40
.speedFlip:
  .byte $FC, $00
.boxOffsetFlip:
  .byte $02, $00

Turret_Vertical:
.spriteId:
  .byte $9A
.boxSize:
  .byte $03, $05
.atts:
  .byte $00
.speed:
  .byte $00, $04
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $80
.speedFlip:
  .byte $00, $FC
.boxOffsetFlip:
  .byte $00, $02

Turret_Diag_1:
.spriteId:
  .byte $9B
.boxSize:
  .byte $05, $05
.atts:
  .byte $00
.speed:
  .byte $03, $FD
.boxOffset:
  .byte $00, $02
.attsFlip:
  .byte $40
.speedFlip:
  .byte $FD, $FD
.boxOffsetFlip:
  .byte $02, $02

Turret_Diag_2:
.spriteId:
  .byte $9B
.boxSize:
  .byte $05, $05
.atts:
  .byte $80
.speed:
  .byte $03, $03
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $C0
.speedFlip:
  .byte $FD, $03
.boxOffsetFlip:
  .byte $02, $00

Tank:
.spriteId:
  .byte $9C
.boxSize:
  .byte $07, $03
.atts:
  .byte $01
.speed:
  .byte $05, $00
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $41
.speedFlip:
  .byte $FB, $00
.boxOffsetFlip:
  .byte $00, $00

Gunner_Robot:
.spriteId:
  .byte $9D
.boxSize:
  .byte $07, $02
.atts:
  .byte $03
.speed:
  .byte $06, $00
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $43
.speedFlip:
  .byte $FA, $00
.boxOffsetFlip:
  .byte $00, $00

Beetle:
.spriteId:
  .byte $9F
.boxSize:
  .byte $07, $03
.atts:
  .byte $01
.speed:
  .byte $03, $00
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $41
.speedFlip:
  .byte $FD, $00
.boxOffsetFlip:
  .byte $00, $00

Sphere:
.spriteId:
  .byte $A0
.boxSize:
  .byte $07, $03
.atts:
  .byte $02
.speed:
  .byte $04, $00
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $42
.speedFlip:
  .byte $FC, $00
.boxOffsetFlip:
  .byte $00, $00

Player:
.spriteId:
  .byte $9E
.boxSize:
  .byte $07, $03
.atts:
  .byte $00
.speed:
  .byte $06, $00
.boxOffset:
  .byte $00, $00
.attsFlip:
  .byte $40
.speedFlip:
  .byte $FA, $00
.boxOffsetFlip:
  .byte $00, $00

BulletsEnd:
