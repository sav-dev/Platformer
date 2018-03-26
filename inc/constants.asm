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

SPRITE_POINTER_JUMP = $2C ; has to % 4 but not 8

SCREEN_WIDTH        = $FF ; screen width in pixels
SCREEN_HEIGHT       = $F0 ; screen height in pixels
                    
SPRITE_DIMENSION    = $08 ; width/height of one sprite
SPRITE_DIMENSION_X2 = SPRITE_DIMENSION * $02
SPRITE_DIMENSION_X3 = SPRITE_DIMENSION * $03
SPRITE_DIMENSION_X4 = SPRITE_DIMENSION * $04
               
CLEAR_SPRITE        = $FE ; when any of the sprite's values are set to this then the sprite is cleared
CLEAR_TILE          = $FE ; clear background tile
CLEAR_ATTS          = $00 ; clear background atts
                                        
Y_OFF               = $00 ; offset of the Y position in the sprite data
TILE_OFF            = $01 ; offset of the tile byte in the sprite data
ATTS_OFF            = $02 ; offset of the att. byte in the sprite data
X_OFF               = $03 ; offset of the X position in the sprite data
SPRITE_SIZE         = $04 ; size of one sprite

MAX_SPRITE_COUNT    = $40 ; 64 sprites

;****************************************************************
; Game state                                                    ;
;****************************************************************

GAMESTATE_GAME = $00
GAMESTATE_NONE = $FF

;****************************************************************
; Physics related constans                                      ;
;****************************************************************

GRAVITY = $03                 ; how much the gravity pulls down per frame

DIRECTION_LEFT  = $00         ; constants, do not change
DIRECTION_RIGHT = $01
DIRECTION_UP    = $00
DIRECTION_DOWN  = $01
DIRECTION_NONE  = $02
                               
;****************************************************************
; Player related constans                                       ;
;****************************************************************

PLAYER_PLAT_BOX_WIDTH   = SPRITE_DIMENSION_X2 - $01
PLAYER_PLAT_BOX_HEIGHT  = SPRITE_DIMENSION_X4 - $01

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
                        
PLAYER_ANIM_FRAMES      = $04   ; frames are counting down so 4 -> 3 -> 2 -> 1
PLAYER_ANIM_SPEED       = $08
                        
SPRITES_PLAYER          = SPRITES_ADDRESS
PLAYER_SPRITES_COUNT    = $09   ; for iterating all sprites
                        
PLAYER_CROUCH_OFFSET    = $03   ; offset of sprite 8 when crouching
                        
PLAYER_BULLET_SPRITE    = $FD
PLAYER_BULLET_PALETTE   = $00
PLAYER_BULLET_WIDTH     = $07   ; really 8 but checks are inclusive
PLAYER_BULLET_HEIGHT    = $04   ; really 5 but checks are inclusive
PLAYER_BULLET_SPEED     = $06
PLAYER_BULLET_LIMIT     = $05   ; could be less?
PLAYER_BULLET_COOLDOWN  = $18
                        
PLAYER_GUN_OFF_X_R      = $12
PLAYER_GUN_OFF_X_L      = $FD - $08 ; -08 for rotation
PLAYER_GUN_OFF_Y        = $EC - $03 ; -03 for bullet offset within the sprite
PLAYER_GUN_OFF_Y_C      = $F4 - $03 ; same

;****************************************************************
; Scroll                                                        ;
;****************************************************************

SCROLL_SPEED = PLAYER_SPEED_POSITIVE ; scroll speed synchronized with player speed, must be 1, 2 or 4
                                     ; could be 8 but then inc/dec logic must be updated (the 'e' var)
                                     ; POI - possible optimization - if set to 1, inc/dec logic may be optimized