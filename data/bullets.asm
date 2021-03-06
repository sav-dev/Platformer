BulletsStart:

;****************************************************************
; Bullets                                                       ;
; Holds information about all bullets (auto-generated)          ;
;****************************************************************

;
;  constant properties for bullets
;    bullet dx, dy      : 2 bytes
;    box dx, dy         : 2 bytes
;    atts               : 1 byte
;    bullet dx, dy flip : 2 bytes
;    box dx, dy flip    : 2 bytes
;    atts flip          : 1 byte
;    sprite id          : 1 byte
;    box width, height  : 2 bytes
;
;  ordered by bullet id
;
;  tag: depends_on_bullets_consts_format


BulletConsts:

Turret_Horizontal:
.speed:
  .byte $04, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $00
.speedFlip:
  .byte $FC, $00
.boxOffsetFlip:
  .byte $02, $00
.attsFlip:
  .byte $40
.spriteId:
  .byte $E4
.boxSize:
  .byte $05, $03
.sound:
  .byte sfx_index_sfx_shot_turret

Turret_Vertical:
.speed:
  .byte $00, $04
.boxOffset:
  .byte $00, $00
.atts:
  .byte $00
.speedFlip:
  .byte $00, $FC
.boxOffsetFlip:
  .byte $00, $02
.attsFlip:
  .byte $80
.spriteId:
  .byte $E5
.boxSize:
  .byte $03, $05
.sound:
  .byte sfx_index_sfx_shot_turret

Turret_Diag_1:
.speed:
  .byte $03, $FD
.boxOffset:
  .byte $00, $02
.atts:
  .byte $00
.speedFlip:
  .byte $FD, $FD
.boxOffsetFlip:
  .byte $02, $02
.attsFlip:
  .byte $40
.spriteId:
  .byte $E6
.boxSize:
  .byte $05, $05
.sound:
  .byte sfx_index_sfx_shot_turret

Turret_Diag_2:
.speed:
  .byte $03, $03
.boxOffset:
  .byte $00, $00
.atts:
  .byte $80
.speedFlip:
  .byte $FD, $03
.boxOffsetFlip:
  .byte $02, $00
.attsFlip:
  .byte $C0
.spriteId:
  .byte $E6
.boxSize:
  .byte $05, $05
.sound:
  .byte sfx_index_sfx_shot_turret

Tank:
.speed:
  .byte $05, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $01
.speedFlip:
  .byte $FB, $00
.boxOffsetFlip:
  .byte $00, $00
.attsFlip:
  .byte $41
.spriteId:
  .byte $E7
.boxSize:
  .byte $07, $03
.sound:
  .byte sfx_index_sfx_shot_tank

Gunner_Robot:
.speed:
  .byte $06, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $03
.speedFlip:
  .byte $FA, $00
.boxOffsetFlip:
  .byte $00, $00
.attsFlip:
  .byte $43
.spriteId:
  .byte $E8
.boxSize:
  .byte $07, $02
.sound:
  .byte sfx_index_sfx_shot_gunrob

Beetle:
.speed:
  .byte $03, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $01
.speedFlip:
  .byte $FD, $00
.boxOffsetFlip:
  .byte $00, $00
.attsFlip:
  .byte $41
.spriteId:
  .byte $EA
.boxSize:
  .byte $07, $03
.sound:
  .byte sfx_index_sfx_shot_tank

Sphere:
.speed:
  .byte $04, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $02
.speedFlip:
  .byte $FC, $00
.boxOffsetFlip:
  .byte $00, $00
.attsFlip:
  .byte $42
.spriteId:
  .byte $EB
.boxSize:
  .byte $07, $03
.sound:
  .byte sfx_index_sfx_shot_turret

Boss_Right_Hand:
.speed:
  .byte $03, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $02
.speedFlip:
  .byte $FD, $00
.boxOffsetFlip:
  .byte $02, $00
.attsFlip:
  .byte $42
.spriteId:
  .byte $EC
.boxSize:
  .byte $05, $05
.sound:
  .byte sfx_index_sfx_shot_boss

Boss_Left_Hand:
.speed:
  .byte $03, $00
.boxOffset:
  .byte $00, $00
.atts:
  .byte $02
.speedFlip:
  .byte $FD, $00
.boxOffsetFlip:
  .byte $02, $00
.attsFlip:
  .byte $42
.spriteId:
  .byte $EC
.boxSize:
  .byte $05, $05
.sound:
  .byte sfx_index_sfx_shot_boss

; Player consts
; note: box DX/DY = 0 for both flip and non-flip
;       speed DY = 0 for both flip and non-flip
PLAYER_BULLET_SPRITE = $E9
PLAYER_BULLET_BOX_WIDTH = $07
PLAYER_BULLET_BOX_HEIGHT = $03
PLAYER_BULLET_SPEED_X = $06
PLAYER_BULLET_SPEED_X_FLIP = $FA
PLAYER_BULLET_ATTS = $00
PLAYER_BULLET_ATTS_FLIP = $40
; For some reason this is causing issues, ref the sound directly
;PLAYER_BULLET_SOUND = sfx_index_sfx_shot_player

BOSS_RIGHT_HAND_BULLET = $70
BOSS_LEFT_HAND_BULLET = $7E

BulletsEnd:
