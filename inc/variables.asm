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
; Bullets                                                       ;
;****************************************************************

 .rsset $0400

playerBullets     .rs 20    ; 4 x PLAYER_BULLET_LIMIT; see constants.asm for format
enemyBullets      .rs 20    ; 4 x ENEMY_BULLET_LIMIT; see constants.asm for format

 .rsset $0400

allBullets        .rs 40    ; redefined for all bullets
 
;****************************************************************
; Other variables - 728 bytes available                         ;
;****************************************************************

 .rsset $0428
 
;****************************************************************
; Game state                                                    ;
;****************************************************************

gameState           .rs 1   ; current gamestate
currentLevel        .rs 1   ; current level