;****************************************************************
; Variables                                                     ;
; Non-zero page variables                                       ;
;****************************************************************

;****************************************************************
; Sprites                                                       ;
;****************************************************************

  .rsset $0200
sprites           .rs 256   ; sprites

;****************************************************************
; Draw buffer                                                   ;
;****************************************************************
  
  .rsset $0100
drawBuffer        .rs 160   ; draw buffer

;****************************************************************
; Tile dictionary                                               ;
;****************************************************************

  .rsset $0700  
leftTiles         .rs 128   ; first 128 bytes of the tile dictionary

  .rsset $0780
rightTiles        .rs 128   ; last 128 bytes of the tile dictionary

;****************************************************************
; Sound                                                         ;
;****************************************************************

  .rsset $0300
  .include "ggsound\ggsound_ram.inc"

;****************************************************************
; Enemies and elevators                                         ;
;****************************************************************

; if this is moved anywhere else, .clearEnemiesAndElevators in game.asm must be updated

 .rsset $0400
 
; depends_on_enemy_in_memory_format
; size of enemies must be "max enemies loaded" (currently 10) * "enemy size" (currently 20)
; size of destroyedEnemies must be "max enemies in a level" (currently 128) / 8

enemies           .rs 200
destroyedEnemies  .rs 16

ENEMIES_COUNT           = $0A ; = 10
ENEMY_SIZE              = $14 ; = 20
MAX_ENEMIES             = $80 ; = 128

; depends_on_elevator_in_memory_format
; size of elevators must be "max elevators loaded" (currently 6) * "elevator size" (currently 8)

elevators         .rs 48

ELEVATORS_COUNT         = $06 ; = 6
ELEVATOR_SIZE           = $08 ; = 8  

;****************************************************************
; Bullets                                                       ;
;****************************************************************

; size of bullets must be 4 * PLAYER_BULLET_LIMIT + 4 (currently 5) * ENEMY_BULLET_LIMIT (currently 10)
 
bullets           .rs 60

PLAYER_BULLET_LIMIT     = $05 ; = 5
ENEMIES_BULLET_LIMIT    = $0A ; = 10

;****************************************************************
; Door and keycard                                              ;
;****************************************************************

; door and keycard have the same format in memory
; depends_on_door_in_level_data_format
; depends_on_door_in_memory_format
doorExists        .rs 1
doorScreen        .rs 1
doorX             .rs 1
doorY             .rs 1
keycardScreen     .rs 1
keycardX          .rs 1
keycardY          .rs 1  

DOOR_DATA_SIZE = $07

; depends_on_enemy_in_memory_format
; depends_on_elevator_in_memory_format
BYTES_TO_CLEAR_IN_500   = $4B ; total size of arrays - 256

;****************************************************************
; Other variables - free up to $0700                            ;
; Variables declared below will not be cleared on lvl start     ;
;****************************************************************
 
;****************************************************************
; Game state                                                    ;
;****************************************************************

gameState           .rs 1   ; current gamestate
currentLevel        .rs 1   ; current level

;****************************************************************
; Misc.                                                         ;
;****************************************************************

; POI - possible optimization - this can be replaced with a pseudo-reg
paletteOffset       .rs 1   ; offset of the bg palette from the lvl data
levelBeaten         .rs 1   ; whether the level was beaten. only inced once and checked at the end of the level