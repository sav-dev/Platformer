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
; ...

;****************************************************************
; Enemies and elevators                                         ;
;****************************************************************

; if this is moved anywhere else, .clearEnemiesAndElevators in game.asm must be updated

 .rsset $0400
 
; depends_on_enemy_in_memory_format
; size of enemies must be "max enemies loaded" (currently 10) * "enemy size" (currently 17)
; size of destroyedEnemies must be "max enemies in a level" (currently 128) / 8

enemies           .rs 170
destroyedEnemies  .rs 16

ENEMIES_COUNT           = $0A ; = 10
ENEMY_SIZE              = $11 ; = 17  
MAX_ENEMIES             = $80 ; = 128

; depends_on_elevator_in_memory_format
; size of elevators must be "max elevators loaded" (currently 6) * "elevator size" (currently 8)

elevators         .rs 48

ELEVATORS_COUNT         = $06 ; = 6
ELEVATOR_SIZE           = $08 ; = 8  

TOTAL_EN_EL_DATA_SIZE   = (ENEMY_SIZE * ENEMIES_COUNT) + (MAX_ENEMIES / $08) + (ELEVATORS_COUNT * ELEVATOR_SIZE)

; 28 bytes free here

;****************************************************************
; Bullets                                                       ;
;****************************************************************

 .rsset $0500

; size of bullets must be 4 * PLAYER_BULLET_LIMIT + 4 (currently 5) * ENEMY_BULLET_LIMIT (currently 10)
 
bullets           .rs 60

PLAYER_BULLET_LIMIT     = $05 ; = 5
ENEMIES_BULLET_LIMIT    = $0A ; = 10

;****************************************************************
; Other variables                                               ;
;****************************************************************

 .rsset $0560
 
;****************************************************************
; Game state                                                    ;
;****************************************************************

gameState           .rs 1   ; current gamestate
currentLevel        .rs 1   ; current level

;****************************************************************
; Level exit                                                    ;
;****************************************************************

levelExitScreen     .rs 1
levelExitX          .rs 1 
levelExitY1         .rs 1
levelExitY2         .rs 1
levelBeaten         .rs 1