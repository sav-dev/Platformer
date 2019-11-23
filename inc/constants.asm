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
                      
CLEAR_SPRITE          = $FF ; when any of the sprite's values are set to this then the sprite is cleared
CLEAR_TILE            = $04 ; clear background tile. AUTO-GENERATED, MAY CHANGE
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

GRAVITY = $04                   ; how much the gravity pulls down per frame

DIRECTION_LEFT    = $00
DIRECTION_RIGHT   = $01
DIRECTION_UP      = $02
DIRECTION_DOWN    = $03
DIRECTION_NONE    = $04

ORIENTATION_VERT  = $00
ORIENTATION_HOR   = $01
ORIENTATION_NONE  = $02
 
;****************************************************************
; Player related constans                                       ;
;****************************************************************

PLAYER_MAX_HEIGHT        = SPRITE_DIMENSION_X4

; if player has fallen off screen, and then Y >= this, it means player is completely invisible 
; (since there are two invisible rows at the bottom of the screen)
PLAYER_Y_FALLEN_BOTTOM   = PLAYER_MAX_HEIGHT - SPRITE_DIMENSION_X2

; inclusive so it's 16 & 32 really
PLAYER_PLAT_BOX_WIDTH    = SPRITE_DIMENSION_X2 - $01
PLAYER_PLAT_BOX_HEIGHT   = SPRITE_DIMENSION_X4 - $01
PLAYER_PLAT_BOX_HEIGHT_C = SPRITE_DIMENSION_X3 - $01
                         
PLAYER_THR_BOX_X_OFF     = $01
PLAYER_THR_BOX_Y_OFF     = $02
PLAYER_THR_BOX_WIDTH     = $0D
PLAYER_THR_BOX_HEIGHT    = $19
PLAYER_THR_BOX_HEIGHT_C  = $11
                         
PLAYER_EXPL_Y_OFF        = SPRITE_DIMENSION_X3
                         
PLAYER_SPEED_POSITIVE    = $02   ; positive player speed
PLAYER_SPEED_NEGATIVE    = $FE   ; positive player speed = positive speed * (-1)
                         
PLAYER_SCREEN_CENTER     = $78   ; if playerX == this then player is on the center of the screen
            
; todo 0003: add bounds for jetpack levels

PLAYER_X_MIN             = $03   ; not 0 1 2 so gun doesn't move to the right of the screen
PLAYER_X_MAX             = SCREEN_WIDTH - PLAYER_PLAT_BOX_WIDTH
                         
PLAYER_STAND             = $00
PLAYER_JUMP              = $01
PLAYER_RUN               = $02
PLAYER_CROUCH            = $03
                         
PLAYER_NORMAL            = $00   ; normal state
PLAYER_EXPLODING         = $01   ; player is exploding
PLAYER_NOT_VISIBLE       = $02   ; player is not visible
                         
PLAYER_ANIM_FRAMES       = $04   ; frames are counting down so 4 -> 3 -> 2 -> 1
PLAYER_ANIM_SPEED        = $08
                         
PLAYER_NOT_V_COOLDOWN    = $60   ; how much time should pass after player is dead/level has been beaten before the screen fades out
PLAYER_NOT_V_FADED_OUT   = $22   ; how much time should pass after the screen fades out before the game is restarted/next level starts
                         
SPRITES_PLAYER           = SPRITES_ADDRESS
PLAYER_SPRITES_COUNT     = $09   ; for iterating all sprites
                         
PLAYER_CROUCH_OFFSET     = $03   ; offset of sprite 8 when crouching
                         
PLAYER_BULLET_COOLDOWN   = $0F
                         
PLAYER_GUN_OFF_X_R       = $12
PLAYER_GUN_OFF_X_L       = $FD - $08 ; -08 for rotation
PLAYER_GUN_OFF_Y         = $EC - $02 ; -02 for bullet offset within the sprite
PLAYER_GUN_OFF_Y_C       = $F4 - $02 ; same
                         
PLAYER_Y_STATE_EXIT_UP   = $00 ; special values for the playerYState var
PLAYER_Y_STATE_NORMAL    = $01 
PLAYER_Y_STATE_EXIT_DOWN = $02

;****************************************************************
; Explosion related constans                                    ;
;****************************************************************

EXPLOSION_SPRITES_COUNT = $04
EXPLOSION_ANIM_FRAMES   = $04   ; frames are counting down so 4 -> 3 -> 2 -> 1
EXPLOSION_ANIM_SPEED    = $06
EXPLOSION_WIDTH         = SPRITE_DIMENSION * $02

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

ENEMY_BULLET_ATTS       = $02

;****************************************************************
; Scroll                                                        ;
;****************************************************************

SCROLL_SPEED = $01 ; must be set to 1 as we depend on that when actually scrolling the screen.
                   ; technically could be 1, 2 or 4. Could be 8 but then inc/dec logic must be updated (the 'e' var)
                   ; POI - possible optimization - if set to 1, inc/dec logic may be optimized to do INC/DEC instead of ADC/SBC
                   ;      INC is easy as we can check for result being 0 to detect overflow
                   ;      but for DEC there is no simple way - calculate if it's worth updating

;****************************************************************
; Movement                                                      ;
;****************************************************************

SPEED_HALF               = $FF
SPEED_QUARTER            = SPEED_HALF - $01
SMALLEST_SPECIAL_SPEED   = SPEED_QUARTER

;****************************************************************
; Enemies                                                       ;
;****************************************************************

; format in enemiesManager.asm
; depends_on_enemy_in_memory_format
ENEMY_STATE               = $00
ENEMY_ID_1                = $01 + ENEMY_STATE             
ENEMY_ID_2                = $01 + ENEMY_ID_1              
ENEMY_POINTER             = $01 + ENEMY_ID_2              
ENEMY_SCREEN              = $01 + ENEMY_POINTER           
ENEMY_SHOULD_FLIP         = $01 + ENEMY_SCREEN            
ENEMY_SPEED               = $01 + ENEMY_SHOULD_FLIP       
ENEMY_SPECIAL_MOV_TYPE    = $01 + ENEMY_SPEED             
ENEMY_MAX_DISTANCE        = $01 + ENEMY_SPECIAL_MOV_TYPE  
ENEMY_CURRENT_FLIP        = $01 + ENEMY_MAX_DISTANCE      
ENEMY_MOVEMENT_DIRECTION  = $01 + ENEMY_CURRENT_FLIP      
ENEMY_CURRENT_DISTANCE    = $01 + ENEMY_MOVEMENT_DIRECTION
ENEMY_SPECIAL_MOV_VAR     = $01 + ENEMY_CURRENT_DISTANCE  
ENEMY_X                   = $01 + ENEMY_SPECIAL_MOV_VAR   
ENEMY_Y                   = $01 + ENEMY_X                 
ENEMY_LIFE                = $01 + ENEMY_Y                 
ENEMY_SHOOTING_FREQ       = $01 + ENEMY_LIFE              
ENEMY_SHOOTING_TIMER      = $01 + ENEMY_SHOOTING_FREQ     
ENEMY_ANIMATION_TIMER     = $01 + ENEMY_SHOOTING_TIMER    
ENEMY_ANIMATION_FRAME     = $01 + ENEMY_ANIMATION_TIMER   
ENEMY_LAST                = ENEMY_ANIMATION_FRAME

; format in enemiesManager.asm
; depends_on_enemy_in_level_data_format
LVL_ENEMY_ID_1            = $00
LVL_ENEMY_ID_2            = $01 + LVL_ENEMY_ID_1           
LVL_ENEMY_SLOT            = $01 + LVL_ENEMY_ID_2           
LVL_ENEMY_POINTER         = $01 + LVL_ENEMY_SLOT           
LVL_ENEMY_SCREEN          = $01 + LVL_ENEMY_POINTER        
LVL_ENEMY_SHOULD_FLIP     = $01 + LVL_ENEMY_SCREEN         
LVL_ENEMY_SPEED           = $01 + LVL_ENEMY_SHOULD_FLIP    
LVL_ENEMY_SP_MOV_TYPE     = $01 + LVL_ENEMY_SPEED          
LVL_ENEMY_MAX_DISTANCE    = $01 + LVL_ENEMY_SP_MOV_TYPE    
LVL_ENEMY_INIT_FLIP       = $01 + LVL_ENEMY_MAX_DISTANCE   
LVL_ENEMY_INIT_DIRECTION  = $01 + LVL_ENEMY_INIT_FLIP      
LVL_ENEMY_INIT_DISTANCE   = $01 + LVL_ENEMY_INIT_DIRECTION 
LVL_ENEMY_INIT_SP_MOV_VAR = $01 + LVL_ENEMY_INIT_DISTANCE  
LVL_ENEMY_X               = $01 + LVL_ENEMY_INIT_SP_MOV_VAR
LVL_ENEMY_Y               = $01 + LVL_ENEMY_X              
LVL_ENEMY_INIT_LIFE       = $01 + LVL_ENEMY_Y              
LVL_ENEMY_SHOOTING_FREQ   = $01 + LVL_ENEMY_INIT_LIFE      
LVL_ENEMY_SHOOTING_TIMER  = $01 + LVL_ENEMY_SHOOTING_FREQ  
LVL_ENEMY_LAST            = LVL_ENEMY_SHOOTING_TIMER

; format in enemies.asm
; depends_on_enemy_consts_format
CONST_ENEMY_WIDTH         = $00
CONST_ENEMY_HITBOX_X      = $01 + CONST_ENEMY_WIDTH        
CONST_ENEMY_HITBOX_WIDTH  = $01 + CONST_ENEMY_HITBOX_X     
CONST_ENEMY_HITBOX_Y      = $01 + CONST_ENEMY_HITBOX_WIDTH 
CONST_ENEMY_HITBOX_HEIGHT = $01 + CONST_ENEMY_HITBOX_Y     
CONST_ENEMY_ORIENTATION   = $01 + CONST_ENEMY_HITBOX_HEIGHT
CONST_ENEMY_GUN_X_OFF     = $01 + CONST_ENEMY_ORIENTATION
CONST_ENEMY_GUN_Y_OFF     = $01 + CONST_ENEMY_GUN_X_OFF    
CONST_ENEMY_GUN_X_OFF_F   = $01 + CONST_ENEMY_GUN_Y_OFF    
CONST_ENEMY_GUN_Y_OFF_F   = $01 + CONST_ENEMY_GUN_X_OFF_F  
CONST_ENEMY_ANIM_SPEED    = $01 + CONST_ENEMY_GUN_Y_OFF_F  
CONST_ENEMY_FRAMES_COUNT  = $01 + CONST_ENEMY_ANIM_SPEED   
CONST_ENEMY_RENDER_INFO   = $01 + CONST_ENEMY_FRAMES_COUNT 
CONST_ENEMY_EXPL_OFF      = $02 + CONST_ENEMY_RENDER_INFO  
CONST_ENEMY_LAST          = CONST_ENEMY_EXPL_OFF

AFTER_LAST_ENEMY          = ENEMY_SIZE * ENEMIES_COUNT 
LAST_ENEMY                = AFTER_LAST_ENEMY - ENEMY_SIZE
LAST_ENEMY_SCREEN         = LAST_ENEMY + ENEMY_SCREEN

ENEMY_STATE_EMPTY       = $00
ENEMY_STATE_EXPLODING   = $01
ENEMY_STATE_ACTIVE      = $02 ; and everything >=, odd means don't render
ENEMY_STATE_HIT         = $0A

; see comment in EnemiesManager .calculateDiffs
ENEMY_MOVE_HORIZONTAL   = $05
ENEMY_MOVE_VERTICAL     = $06

SPECIAL_MOV_NONE        = $00
SPECIAL_MOV_STOP60      = $01
SPECIAL_MOV_STOP120     = $02
SPECIAL_MOV_CLOCK       = $05
SPECIAL_MOV_COUNT_C     = $06
SPECIAL_MOV_SINUS8      = $0A
SPECIAL_MOV_SINUS16     = $0B

STOP60_DEFAULT          = $3C ; = 60
STOP120_DEFAULT         = $78 ; = 120

;****************************************************************
; Elevators                                                     ;
;****************************************************************

ELEVATOR_SPRITE              = $F9
ELEVATOR_END_SPRITE          = $FA
ELEVATOR_ATTS                = $02

; format in elevatorManager.asm
; depends_on_elevator_in_memory_format
ELEVATOR_EL_SIZE             = $00
ELEVATOR_SCREEN              = $01
ELEVATOR_SPEED               = $02
ELEVATOR_MAX_DISTANCE        = $03
ELEVATOR_CURRENT_DISTANCE    = $04
ELEVATOR_MOVEMENT_DIRECTION  = $05
ELEVATOR_Y                   = $06
ELEVATOR_X                   = $07

; elevator size == 0 means elevator is not loaded
ELEVATOR_EL_SIZE_EMPTY       = $00

AFTER_LAST_ELEVATOR          = ELEVATOR_SIZE * ELEVATORS_COUNT 
LAST_ELEVATOR                = AFTER_LAST_ELEVATOR - ELEVATOR_SIZE
LAST_ELEVATOR_SCREEN         = LAST_ELEVATOR + ELEVATOR_SCREEN

ELEVATOR_HEIGHT              = $06

;****************************************************************
; Exit                                                          ;
;****************************************************************

EXIT_HEIGHT                  = $24 ; 36 - but really 35 because we do a <
EXIT_WIDTH                   = $19 ; 25 - but really 24 because we do a <

;****************************************************************
; Door and keycard                                              ;
;****************************************************************

DOOR_SPRITE            = $F8
DOOR_ATTS              = $02
DOOR_HEIGHT_IN_SPRITES = $06
DOOR_WIDTH             = $02 * SPRITE_DIMENSION - $01  ; -1 because collision check is inclusive
DOOR_HEIGHT            = $06 * SPRITE_DIMENSION - $01  ; -1 because collision check is inclusive

KEYCARD_SPRITE_1       = $F6
KEYCARD_SPRITE_2       = $F7
KEYCARD_ATTS           = $02
KEYCARD_WIDTH          = $02 * SPRITE_DIMENSION - $01  ; -1 because collision check is inclusive
KEYCARD_HEIGHT         = SPRITE_DIMENSION - $01        ; -1 because collision check is inclusive