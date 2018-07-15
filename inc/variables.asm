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
; Enemies                                                       ;
;****************************************************************

 .rsset $0400              

enemies           .rs 200   ; POI - can be lowered, must be = max enemies x enemy size; see enemiesManager.asm for format

;****************************************************************
; Bullets                                                       ;
;****************************************************************

 .rsset $0500

bullets           .rs 60    ; 4 x PLAYER_BULLET_LIMIT + 4 x ENEMY_BULLET_LIMIT; see constants.asm for format

;****************************************************************
; Other variables                                               ;
;****************************************************************

 .rsset $0560
 
;****************************************************************
; Game state                                                    ;
;****************************************************************

gameState           .rs 1   ; current gamestate
currentLevel        .rs 1   ; current level