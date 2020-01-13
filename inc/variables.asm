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
  ; sound uses between 150 and 189 bytes based on what's enabled. That means there's at least 67 bytes available here.
  
;****************************************************************
; Enemies and elevators                                         ;
;****************************************************************

 .rsset $0400
 
; depends_on_enemy_in_memory_format
; size of enemies must be "max enemies loaded" (currently 10) * "enemy size" (currently 24)
; size of destroyedEnemies must be "max enemies in a level" (currently 128) / 8

enemies           .rs 240
destroyedEnemies  .rs 16

ENEMIES_COUNT           = $0A ; = 10
ENEMY_SIZE              = $18 ; = 24
MAX_ENEMIES             = $80 ; = 128
ENEMIES_TOTAL_SIZE      = ENEMY_SIZE * ENEMIES_COUNT 

; depends_on_elevator_in_memory_format
; size of elevators must be "max elevators loaded" (currently 6) * "elevator size" (currently 8)

elevators         .rs 48

ELEVATORS_COUNT         = $06 ; = 6
ELEVATOR_SIZE           = $08 ; = 8  

;****************************************************************
; Bullets                                                       ;
;****************************************************************

; size of bullets must be BULLET_MEMORY_BYTES * TOTAL_BULLET_LIMIT
 
bullets           .rs 165

PLAYER_BULLET_LIMIT     = $05 ; = 5
ENEMIES_BULLET_LIMIT    = $0A ; = 10
TOTAL_BULLET_LIMIT      = PLAYER_BULLET_LIMIT + ENEMIES_BULLET_LIMIT
BULLET_MEMORY_BYTES     = $0B ; = 11

; size in memory for player bullets, enemy bullets, and the two combined.
; player bullets come before enemy bullets in the combined var.
PLAYER_BULLET_VAR_SIZE   = PLAYER_BULLET_LIMIT * BULLET_MEMORY_BYTES
ENEMIES_BULLET_VAR_SIZE  = ENEMIES_BULLET_LIMIT * BULLET_MEMORY_BYTES
TOTAL_BULLET_VAR_SIZE    = PLAYER_BULLET_VAR_SIZE + ENEMIES_BULLET_VAR_SIZE

