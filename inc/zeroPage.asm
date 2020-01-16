;****************************************************************
; List of zero page variables                                   ;
; If bytes are needed, many of these could be removed           ;
; and instead we could use a different variable                 ;
;****************************************************************

  .rsset $0000
  
;****************************************************************
; Pseudo-registers                                              ;
;****************************************************************

b                       .rs 1
c                       .rs 1
d                       .rs 1
e                       .rs 1
f                       .rs 1
g                       .rs 1
h                       .rs 1
i                       .rs 1
j                       .rs 1
k                       .rs 1
l                       .rs 1
m                       .rs 1
n                       .rs 1
o                       .rs 1
p                       .rs 1
q                       .rs 1

;****************************************************************
; Pointers                                                      ;
;****************************************************************

genericPointer          .rs 2  ; general-use pointer
levelPointer            .rs 2  ; used for loading levels, then points to the right-most fully rendered column
levelBackPointer        .rs 2  ; points to the left-most fully rendered column
attsPointer             .rs 2  ; points to the right-most rendered atts column
attsBackPointer         .rs 2  ; points to the left-most rendered atts column
platformsPointer        .rs 2  ; points to the platform data for current screen
threatsPointer          .rs 2  ; points to the threat data for current screen
enemiesPointer          .rs 2  ; points to the enemies data for *next* screen (since we load one screen ahead)
elevatorsPointer        .rs 2  ; points to the elevators data for *next* screen (since we load one screen ahead)
enemyConstsPointer      .rs 2  ; used to iterate over enemy consts

xPointerCache           .rs 1  ; for caching the initial value of the x register
xPointerCache2          .rs 1  ; in case we need to cache it twice
yPointerCache           .rs 1  ; for caching the initial value of the y register

;****************************************************************
; Memory related variables                                      ;
;****************************************************************

currentBank             .rs 1  ; currently selected bank
previousBank            .rs 1  ; previously selected bank

;****************************************************************
; Buffering related variables                                   ;
;****************************************************************

bufferOffset            .rs 1  ; points to the first free buffer byte

;****************************************************************
; NMI/main thread synchronization                               ;
;****************************************************************

soft2000                .rs 1  ; buffering $2000 writes
soft2001                .rs 1  ; buffering $2001 writes
needDma                 .rs 1  ; nonzero if NMI should perform sprite DMA
needDraw                .rs 1  ; nonzero if NMI needs to do drawing from the buffer
needPpuReg              .rs 1  ; nonzero if NMI should update $2000/$2001/$2005
sleeping                .rs 1  ; nonzero if main thread is waiting for VBlank
needDrawLocal           .rs 1  ; local copy of need draw
needPpuRegLocal         .rs 1  ; local copy of need PPU reg

;****************************************************************
; Scrolling                                                     ;
;****************************************************************

nametable               .rs 1  ; main nametable, 0 or 1
scroll                  .rs 2  ; current scroll value, LOW is the actual scroll, HIGH contains number of screens scrolled
maxScroll               .rs 2  ; max scroll for current level
frameScroll             .rs 1  ; by how much the screen have scrolled in a frame

;****************************************************************
; Controllers                                                   ;
;****************************************************************

controllerDown          .rs 1  ; buttons that are pressed down
controllerPrevious      .rs 1  ; buttons that were pressed down frame before that
controllerPressed       .rs 1  ; buttons that have been pressed since the last frame

;****************************************************************
; Player data                                                   ;
;****************************************************************

playerX                 .rs 1  ; player position (on screen: bottom left). also: cursor position
playerY                 .rs 1

playerPlatformBoxX1     .rs 1  ; can be removed for a slight performance decrease (4 bytes freed though)
playerPlatformBoxX2     .rs 1
playerPlatformBoxY1     .rs 1
playerPlatformBoxY2     .rs 1

playerThreatBoxX1       .rs 1  ; can be removed for a slight performance decrease (4 bytes freed though)
playerThreatBoxX2       .rs 1
playerThreatBoxY1       .rs 1
playerThreatBoxY2       .rs 1

playerBulletCooldown    .rs 1  ; when player can shoot again

playerState             .rs 1  ; player state (normal/falling/exploding)
playerAnimation         .rs 1  ; player animation (crouch/stand/run/jump)
playerDirection         .rs 1  ; player direction
playerCounter           .rs 1  ; player counter (timer), used mostly for animation but also for countdown after player dies etc. also: cursor selection
playerAnimationFrame    .rs 1  ; player animation frame
playerJump              .rs 1  ; 0 means not jumping, otherwise contains the jump counter

playerYState            .rs 1  ; special var describing if player exited the screen on the top or bottom

;****************************************************************
; Generic vars                                                  ;
;****************************************************************

frameCount              .rs 1  ; frame counter

genericX                .rs 1  ; generic position
genericY                .rs 1 
genericFrame            .rs 1  ; generic frame count
genericDirection        .rs 1  ; generic direction
genericOffScreen        .rs 1  ; 1 means object is off screen (so x = $FE means render on the left side of the screen)

genericDX               .rs 1  ; how much to move
genericDY               .rs 1

genericWidth            .rs 1
genericHeight           .rs 1

genericDOther           .rs 1  ; how much to move in the 'other' plane. POITAG - save zero page - remove this and use a pseudo-register
genericVisible          .rs 1  ; whether the object exists on this or the next screen. POITAG - save zero page - remove this and use a pseudo-register

genericHorDirLeft       .rs 1  ; >0 means object should be moved left, 0 means should be moved right. POITAG - save zero page - remove this and use a pseudo-register
genericHorDirUp         .rs 1  ; >0 means object should be moved up, 0 means should be moved down. POITAG - save zero page - remove this and use a pseudo-register

;****************************************************************
; Enemy processing                                              ;
;****************************************************************

; POITAG - possible optimization - to save zero page bytes, the vars below could be replaced with the use of pseudo-registers
enemyScreen             .rs 1  ; screen the enemy is on

enemyDirection          .rs 1  ; enemy direction
enemySpecialMovType     .rs 1  ; enemy special movement type
enemySpeed              .rs 1  ; enemy speed
enemyMaxDistance        .rs 1  ; max distance

enemyAnimationSpeed     .rs 1  ; enemy animation speed
enemyFrameCount         .rs 1  ; enemy frame count

enemyOrientation        .rs 1  ; enemy orientation

enemyBulletPointer      .rs 1  ; enemy bullet pointer
enemyGunX               .rs 1  ; enemy gun x position
enemyGunY               .rs 1  ; enemy gun y position

enemyOnScreen           .rs 1  ; set to 1 if enemy should be rendered
enemyCollisions         .rs 1  ; set to 1 if a collision check is needed
enemyNotFlashing        .rs 1  ; set to 1 if enemy is *NOT* flashing

enemyShouldFlip         .rs 1  ; set to 1 if enemy should flip

enemyDontAnimStatic     .rs 1  ; if set to 0 we won't animate the enemy if static

enemyHit                .rs 1  ; whether the enemy was hit
removeEnemy             .rs 1  ; whether enemy should be exploded / removed from the game

;****************************************************************
; Elevators                                                     ;
;****************************************************************

playerOnElevator        .rs 1  ; whether player is standing on an elevator, >0 means yes
playerElevatorId        .rs 1  ; points to the elevator player is standing on

elevatorSize            .rs 1  ; size of an elevator

;****************************************************************
; Collision checks                                              ;
;****************************************************************

ax1                     .rs 1  ; 1st hitbox
ax2                     .rs 1  
ay1                     .rs 1  
ay2                     .rs 1  
bx1                     .rs 1  ; 2nd hitbox
bx2                     .rs 1      
by1                     .rs 1      
by2                     .rs 1      
collision               .rs 1
collisionCache          .rs 1  ; POITAG - possible optimization - to save zero page bytes, user a pseudo-register instead

;****************************************************************
; Sprite rendering                                              ;
;****************************************************************

spritePointer           .rs 1
renderXPos              .rs 1
renderYPos              .rs 1
renderTile              .rs 1
renderAtts              .rs 1

;****************************************************************
; Level info                                                    ;
;****************************************************************

; POITAG - possible optimization - some of these aren't checked that often. to save zero page bytes, move them out
levelType           .rs 1
levelTypeData1      .rs 1 ; normal: exit screen ; jetpack: scroll speed   ; boss: whether screen scrolled
levelTypeData2      .rs 1 ; normal: exit X      ; jetpack: N/U            ; boss: victory condition
levelTypeData3      .rs 1 ; normal: exit Y      ; jetpack: N/U            ; N/U
levelHelperVar      .rs 1 ; a helper var
levelHelperVar2     .rs 1 ; a 2nd helper var

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

;****************************************************************
; Other stuff                                                   ;
; POITAG - possible optimization - these don't have to be in ZP ;
;****************************************************************

gameState           .rs 1 ; current gamestate
currentLevel        .rs 1 ; current level
paletteOffset       .rs 1 ; offset of the bg palette from the lvl data
tilesetOffset       .rs 1 ; tileset offset in the lookup table from the lvl data
levelBeaten         .rs 1 ; whether the level was beaten. only inced once and checked at the end of the level
isPaused            .rs 1 ; whether the game is paused

;****************************************************************
; ggsound                                                       ;
;****************************************************************

  .include "ggsound\ggsound_zp.inc" ; uses between 61 or 72 bytes based on what's enabled 
  ; sound .rs 72
  ; afterSound .rs 1