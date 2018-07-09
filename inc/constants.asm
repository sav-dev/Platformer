;****************************************************************
; Memory layout related constans                                ;
;****************************************************************

; $0000-$000F    16 bytes   Local variables and function arguments  
; $0010-$00FF   240 bytes   Global variables accessed most often, including certain pointer tables  
; $0100-$019F   160 bytes   Data to be copied to nametable during next vertical blank (see The frame and NMIs)  
; $01A0-$01FF    96 bytes   Stack  
; $0200-$02FF   256 bytes   Data to be copied to OAM during next vertical blank  
; $0300-$03FF   256 bytes   Variables used by sound player, and possibly other variables  
; $0400-$06FF   768 bytes   Arrays and less-often-accessed global variables 
; $0700-$07FF   256 bytes   Level information

SPRITES_LOW_BYTE  = $00   ; low byte of the sprites page
SPRITES_HIGH_BYTE = $02   ; high sprite of the sprites page
SPRITES_ADDRESS   = $0200 ; above combined

;****************************************************************
; Controllers                                                   ;
;****************************************************************

CONTROLLER_A     = %10000000 ; controller bitmasks
CONTROLLER_B     = %01000000
CONTROLLER_SEL   = %00100000
CONTROLLER_START = %00010000
CONTROLLER_UP    = %00001000
CONTROLLER_DOWN  = %00000100
CONTROLLER_LEFT  = %00000010
CONTROLLER_RIGHT = %00000001

;****************************************************************
; Graphics related constans                                     ;
;****************************************************************

SPRITE_POINTER_JUMP   = $2C ; has to % 4 but not 8
                      
SCREEN_WIDTH          = $FF ; screen width in pixels
SCREEN_HEIGHT         = $F0 ; screen height in pixels
                      
SPRITE_DIMENSION      = $08 ; width/height of one sprite
SPRITE_DIMENSION_X2   = SPRITE_DIMENSION * $02
SPRITE_DIMENSION_X3   = SPRITE_DIMENSION * $03
SPRITE_DIMENSION_X4   = SPRITE_DIMENSION * $04

LAST_SPRITE_X         = $F8 ; position of the last sprite that doesn't overflow
                      
CLEAR_SPRITE          = $FE ; when any of the sprite's values are set to this then the sprite is cleared
CLEAR_TILE            = $FE ; clear background tile
CLEAR_ATTS            = $00 ; clear background atts
                                          
Y_OFF                 = $00 ; offset of the Y position in the sprite data
TILE_OFF              = $01 ; offset of the tile byte in the sprite data
ATTS_OFF              = $02 ; offset of the att. byte in the sprite data
X_OFF                 = $03 ; offset of the X position in the sprite data
SPRITE_SIZE           = $04 ; size of one sprite
                      
MAX_SPRITE_COUNT      = $40 ; 64 sprites
                      
RENDER_ENEMY_NO_FLIP  = $00 ; lowest bit set means V, second to lowest bit set means H
RENDER_ENEMY_FLIP     = $01 ; 0000 0001


;****************************************************************
; Game state                                                    ;
;****************************************************************

GAMESTATE_GAME = $00
GAMESTATE_NONE = $FF

;****************************************************************
; Physics related constans                                      ;
;****************************************************************

GRAVITY = $03                   ; how much the gravity pulls down per frame

DIRECTION_LEFT    = $00         ; constants, do not change
DIRECTION_RIGHT   = $01
DIRECTION_UP      = $00
DIRECTION_DOWN    = $01
DIRECTION_NONE    = $02
                  
GENERIC_DIR_LEFT  = $00
GENERIC_DIR_RIGHT = $01
GENERIC_DIR_UP    = $02
GENERIC_DIR_DOWN  = $03
GENERIC_DIR_NONE  = $04                 
                 
;****************************************************************
; Player related constans                                       ;
;****************************************************************

; inclusive so it's 16 & 32 really
PLAYER_PLAT_BOX_WIDTH   = SPRITE_DIMENSION_X2 - $01
PLAYER_PLAT_BOX_HEIGHT  = SPRITE_DIMENSION_X4 - $01

PLAYER_THR_BOX_X_OFF    = $01
PLAYER_THR_BOX_Y_OFF    = $02
PLAYER_THR_BOX_WIDTH    = $0D
PLAYER_THR_BOX_HEIGHT   = $19
PLAYER_THR_BOX_HEIGHT_C = $11

PLAYER_EXPL_Y_OFF       = SPRITE_DIMENSION_X3

PLAYER_SPEED_POSITIVE   = $02   ; positive player speed
PLAYER_SPEED_NEGATIVE   = $FE   ; positive player speed = positive speed * (-1)
                        
PLAYER_SCREEN_CENTER    = $78   ; if playerX == this then player is on the center of the screen
                        
PLAYER_X_MIN            = $10
PLAYER_X_MAX            = SCREEN_WIDTH - $1F
PLAYER_Y_MIN            = $11   ; must be updated if player is to go off screen more (show/hide sprites in MovePlayerVertically?)
PLAYER_Y_MAX            = SCREEN_HEIGHT - $01
                        
PLAYER_STAND            = $00
PLAYER_JUMP             = $01
PLAYER_RUN              = $02
PLAYER_CROUCH           = $03

PLAYER_NORMAL           = $00   ; normal state
PLAYER_FALLING          = $01   ; player falling off screen
PLAYER_EXPLODING        = $02   ; player is exploding
PLAYER_NOT_VISIBLE      = $03   ; player has died and is timing out
                        
PLAYER_ANIM_FRAMES      = $04   ; frames are counting down so 4 -> 3 -> 2 -> 1
PLAYER_ANIM_SPEED       = $08
                        
PLAYER_DEAD_COOLDOWN    = $60   ; how much time should pass after player is dead before the screen fades out
PLAYER_DEAD_FADED_OUT   = $22   ; how much time should pass after the screen fades out before the game is restarted
                    
SPRITES_PLAYER          = SPRITES_ADDRESS
PLAYER_SPRITES_COUNT    = $09   ; for iterating all sprites
                        
PLAYER_CROUCH_OFFSET    = $03   ; offset of sprite 8 when crouching
                        
PLAYER_BULLET_COOLDOWN  = $08   ; todo - is this even required
                        
PLAYER_GUN_OFF_X_R      = $12
PLAYER_GUN_OFF_X_L      = $FD - $08 ; -08 for rotation
PLAYER_GUN_OFF_Y        = $EC - $02 ; -02 for bullet offset within the sprite
PLAYER_GUN_OFF_Y_C      = $F4 - $02 ; same

;****************************************************************
; Explosion related constans                                    ;
;****************************************************************

EXPLOSION_SPRITES_COUNT = $04
EXPLOSION_ANIM_FRAMES   = $04   ; frames are counting down so 4 -> 3 -> 2 -> 1
EXPLOSION_ANIM_SPEED    = $06

;****************************************************************
; Bullets related constans                                      ;
;****************************************************************

BULLET_MEMORY_BYTES     = $04   ; bullet memory layout
BULLET_MEMORY_STATE     = $00
BULLET_MEMORY_DIRECTION = $01
BULLET_MEMORY_X_OFF     = $02
BULLET_MEMORY_Y_OFF     = $03

BULLET_E_DURATION       = $05   ; duration of bullet explosion

BULLET_S_NOT_EXIST      = $00   ; bullet states
BULLET_S_JUST_SPAWNED   = $01
BULLET_S_NORMAL         = $02
BULLET_S_SMTH_HIT       = $03
BULLET_S_TO_CLEAR       = BULLET_S_SMTH_HIT + BULLET_E_DURATION

BULLET_SPRITE_H         = $FD   ; tiles
BULLET_SPRITE_V         = $FC
BULLET_SPRITE_E         = $FB

BULLET_ATTS_LEFT        = $40   ; atts
BULLET_ATTS_RIGHT       = $00
BULLET_ATTS_UP          = $80
BULLET_ATTS_DOWN        = $00
BULLET_ATTS_E           = $00

BULLET_E_WIDTH          = SPRITE_DIMENSION
BULLET_E_HEIGHT         = SPRITE_DIMENSION

BULLET_WIDTH            = $07   ; bullet hitbox, (x,y) are top left corner, inclusive so -1
BULLET_HEIGHT           = $04   ; these are for horizontal bullet (5x8), it's 8x5 for vertical
        
BULLET_SPEED            = $04

; max. number of bullets for player and enemies
PLAYER_BULLET_LIMIT     = $05
ENEMIES_BULLET_LIMIT    = $0A

; size in memory for player bullets, enemy bullets, and the two combined.
; player bullets come before enemy bullets in the combined var.
PLAYER_BULLET_VAR_SIZE  = PLAYER_BULLET_LIMIT * BULLET_MEMORY_BYTES
ENEMIES_BULLET_VAR_SIZE = ENEMIES_BULLET_LIMIT * BULLET_MEMORY_BYTES
TOTAL_BULLET_VAR_SIZE   = PLAYER_BULLET_VAR_SIZE + ENEMIES_BULLET_VAR_SIZE

; pointer to the last and first player bullet in the combined var (and also the player var)
PLAYER_BULLET_LAST      = PLAYER_BULLET_VAR_SIZE - BULLET_MEMORY_BYTES
PLAYER_BULLET_FIRST     = $00

; pointer to the last and first enemy bullet in the combined var
ENEMY_BULLET_LAST       = TOTAL_BULLET_VAR_SIZE - BULLET_MEMORY_BYTES
ENEMY_BULLET_FIRST      = TOTAL_BULLET_VAR_SIZE - ENEMIES_BULLET_VAR_SIZE

; last bullet in the combined var is the last bullet in the enemy var
TOTAL_BULLET_LAST       = ENEMY_BULLET_LAST

;****************************************************************
; Scroll                                                        ;
;****************************************************************

SCROLL_SPEED = PLAYER_SPEED_POSITIVE ; scroll speed synchronized with player speed, must be 1, 2 or 4
                                     ; could be 8 but then inc/dec logic must be updated (the 'e' var)
                                     ; POI - possible optimization - if set to 1, inc/dec logic may be optimized
                                     
;****************************************************************
; Enemies                                                       ;
;****************************************************************

ENEMY_SIZE                = $10        ; 16 bytes per enemy  
ENEMIES_COUNT             = $0C        ; 12 enemies max

; format in enemiesManager.asm
; depends_on_enemy_in_memory_format
ENEMY_STATE               = $00
ENEMY_ID                  = $01
ENEMY_POINTER             = $02
ENEMY_SCREEN              = $03
ENEMY_SPEED               = $04
ENEMY_MAX_DISTANCE        = $05
ENEMY_MOVEMENT_DIRECTION  = $06
ENEMY_CURRENT_DISTANCE    = $07
ENEMY_FLIP                = $08
ENEMY_X                   = $09
ENEMY_Y                   = $0A
ENEMY_LIFE                = $0B
ENEMY_SHOOTING_FREQ       = $0C
ENEMY_SHOOTING_TIMER      = $0D
ENEMY_ANIMATION_TIMER     = $0E
ENEMY_ANIMATION_FRAME     = $0F

AFTER_LAST_ENEMY          = ENEMY_SIZE * ENEMIES_COUNT 
LAST_ENEMY                = AFTER_LAST_ENEMY - ENEMY_SIZE
LAST_ENEMY_SCREEN         = LAST_ENEMY + ENEMY_SCREEN

ENEMY_STATE_EMPTY       = $00
ENEMY_STATE_ACTIVE      = $01
ENEMY_STATE_EXPLODING   = $02

ENEMY_MOVE_NONE         = $00
ENEMY_MOVE_HORIZONTAL   = $01
ENEMY_MOVE_VERTICAL     = $02