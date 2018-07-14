;****************************************************************
; List of zero page variables                                   ;
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

xPointerCache           .rs 1  ; for caching the initial value of the x register
yPointerCache           .rs 1  ; for caching the initial value of the y register

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

;****************************************************************
; Controllers                                                   ;
;****************************************************************

controllerDown          .rs 1  ; buttons that are pressed down
controllerPrevious      .rs 1  ; buttons that were pressed down frame before that
controllerPressed       .rs 1  ; buttons that have been pressed since the last frame

;****************************************************************
; Player data                                                   ;
;****************************************************************

playerX                 .rs 1  ; player position (on screen: bottom left)
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
playerAnimation         .rs 1  ; player state
playerDirection         .rs 1  ; player direction
playerCounter           .rs 1  ; player counter (timer), used mostly for animation
playerAnimationFrame    .rs 1  ; player animation frame
playerJump              .rs 1  ; 0 means not jumping, otherwise contains the jump counter

;****************************************************************
; Generic vars                                                  ;
;****************************************************************

frameCount              .rs 1  ; frame counter

genericX                .rs 1  ; generic position
genericY                .rs 1 
genericFrame            .rs 1  ; generic frame count
genericDirection        .rs 1  ; generic direction
genericOffScreen        .rs 1  ; 1 means object is off screen (so x = $FE means render on the left side of the screen)

genericDX               .rs 1  ; how much to move, used for player and enemies
genericDY               .rs 1

;****************************************************************
; Enemy processing                                              ;
;****************************************************************

; POI - possible optimization - to save zero page bytes, the vars below could be replaced with the use of pseudo-registers
enemyScreen             .rs 1  ; screen the enemy is on

enemyOrientation        .rs 1  ; enemy orientation

enemySpeed              .rs 1  ; enemy speed
enemyMaxDistance        .rs 1  ; max distance

enemyAnimationSpeed     .rs 1  ; enemy animation speed
enemyFrameCount         .rs 1  ; enemy frame count

enemyGunX               .rs 1  ; enemy gun x position
enemyGunY               .rs 1  ; enemy gun y position

enemyRender             .rs 1  ; set to 1 if enemy should be rendered
enemyCollisions         .rs 1  ; set to 1 if a collision check is needed

removeEnemy             .rs 1  ; whether enemy should be exploded / removed from the game

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

;****************************************************************
; Sprite rendering                                              ;
;****************************************************************

spritePointer           .rs 1
renderXPos              .rs 1
renderYPos              .rs 1
renderTile              .rs 1
renderAtts              .rs 1