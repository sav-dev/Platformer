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

 .rsset $0400
 
; size of enemies must be "max enemies loaded" (currently 10) * "enemy size" (currently 16)
; size of destroyedEnemies must be "max enemies in a level" (currently 80) / 8

enemies           .rs 160
destroyedEnemies  .rs 10

; size of elevators must be "max elevators loaded" (currently 6) * "elevator size" (currently 8)

elevators         .rs 48

; 38 bytes free here

;****************************************************************
; Bullets                                                       ;
;****************************************************************

 .rsset $0500

; size of bullets must be 4 * PLAYER_BULLET_LIMIT + 4 (currently 5) * ENEMY_BULLET_LIMIT (currently 10)
 
bullets           .rs 60

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
levelExitY          .rs 1 