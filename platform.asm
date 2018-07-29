;****************************************************************
; iNES headers                                                  ;
;****************************************************************

  .inesprg 2  ; 2x 16KB = 32KB PRG code (banks 0-3)
  .ineschr 1  ; 1x  8KB CHR data (bank 4)
  .inesmap 0  ; mapper 0 = NROM, no bank swapping
  .inesmir 1  ; vertical mirroring for horizontal scrolling
  
;****************************************************************
; Variables                                                     ;
;****************************************************************
    
  .include "inc\zeroPage.asm"
  .include "inc\variables.asm"
  
;****************************************************************
; Global constants                                              ;
;****************************************************************

  .include "inc\constants.asm"
  
;****************************************************************
; RESET handler                                                 ;
;****************************************************************

  .bank 2
  .org $C000 

Bank2Start:
  
RESET:
  SEI               ; disable IRQs
  CLD               ; disable decimal mode
  LDX #$40          
  STX $4017         ; disable APU frame IRQ
  LDX #$FF          
  TXS               ; Set up stack
  INX               ; now X = 0
  STX $2000         ; disable NMI
  STX $2001         ; disable rendering
  STX $4010         ; disable DMC IRQs
                    
vblankwait1:        ; First wait for vblank to make sure PPU is ready
  BIT $2002         
  BPL vblankwait1   
                    
clrmem:             ; clear all RAM (8x256 bytes = 2kB)   
  LDA #$00          
  STA $0000, x      
  STA $0100, x      
  STA $0300, x      
  STA $0400, x      
  STA $0500, x      
  STA $0600, x      
  STA $0700, x      
  INX
  BNE clrmem        
     
vblankwait2:        ; Second wait for vblank, PPU is ready after this
  BIT $2002              
  BPL vblankwait2
  
;****************************************************************
; Initialization logic                                          ;
;****************************************************************

initGame:
  LDA #GAMESTATE_NONE
  STA gameState
  LDA #$00
  STA currentLevel  
  
initPPU:
  LDA #$00                 
  STA needDma
  STA needDraw
  STA needPpuReg

  STA bufferOffset
  
  JSR ClearPalettes        ; clear all palettes so there's no initial color flashing
  JSR ClearSprites         ; clear all sprites
  JSR ClearBackgrounds     ; clear all backgrounds
                           
  LDA #%00000110           ; init PPU - disable sprites and background
  STA soft2001             
  STA $2001                
  LDA #%10010000           ; enable NMI, sprites from PT 0, bg from PT 1
  STA soft2000             
  STA $2000                
  BIT $2002                
  LDA #$00                 ; no horizontal scroll (yet)
  STA $2005                
  LDA #$00                 ; no vertical scroll
  STA $2005                
                
  INC needDma
  INC needDraw
  JSR WaitForFrame         ; wait for one frame for everything to get loaded
  
;****************************************************************
; Game loop                                                     ;
;****************************************************************

GameLoop:
  
  .readController:
    JSR ReadController      ; always read controller input first    
  .readControllerDone:      
                                                        
  .checkGameState:          
    LDA gameState
    CMP #GAMESTATE_GAME
    BEQ .gameStateGame
    JMP .gameStateNone      ; nothing was matched => game state is "none"  
  .checkGameStateDone:      

  .gameStateGame:
    JSR GameFrame
    JMP GameLoopDone
  .gameStateGameDone:
  
  .gameStateNone:
    LDA #$00
    STA currentLevel        ; set current level to 0
    JSR LoadGame
    JMP GameLoopDone        
  .gameStateNoneDone:       
                            
GameLoopDone:

  JSR WaitForFrame          ; always wait for a frame at the end of the loop iteration
  JMP GameLoop
  
;****************************************************************
; NMI handler                                                   ;
;****************************************************************

NMI:
  PHA                       ; back up registers
  TXA                       
  PHA                       
  TYA                       
  PHA                       
               
  Dma:
  LDA needDma               
  BEQ NoDma               
    LDA #SPRITES_LOW_BYTE   ; do sprite DMA
    STA $2003               ; conditional via the 'needDma' flag
    LDA #SPRITES_HIGH_BYTE  
    STA $4014
    LDA #$00
    JMP DmaDone
  NoDma:                    ; since we always do DMA in the game logic, if we hit this it means we're lagging
    NOP                     ; useful for debugging. todo - remove this
  DmaDone:                  
                            
  LDA needDraw              ; do other PPU drawing
  BEQ DrawDone              ; conditional via the 'needDraw' flag
    BIT $2002               ; clear VBl flag, reset $2005/$2006 toggle
    JSR DoDrawing           ; draw the stuff from the drawing buffer
    JMP DoPpuReg            ; after drawing PPU reg is required
  DrawDone:
                            
  LDA needPpuReg            ; PPU register updates
  BEQ PpuRegDone            ; conditional via the 'needPpuReg' flag
  DoPpuReg:
    LDA soft2001            ; copy buffered $2000/$2001
    STA $2001               
    LDA soft2000            
    STA $2000               
                            
    BIT $2002               ; set the scroll
    LDA scroll              ; set horizontal scroll
    STA $2005                
    LDA #$00                ; no vertical scroll
    STA $2005               
  PpuRegDone:
                     
  LDA #$00                  ; clear the sleeping flag so that WaitForFrame will exit, also clear all conditional flags
  STA needDma
  STA needDraw
  STA needPpuReg
  STA sleeping              
                            
  PLA                       ; restore regs and exit
  TAY                       
  PLA
  TAX
  PLA
  RTI

  RTI
  
;****************************************************************
; Global subroutines                                            ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   WaitForFrame                                                ;
;                                                               ;
; Description:                                                  ;
;   Wait for NMI to happen, then exit                           ;
;****************************************************************

WaitForFrame
  INC sleeping
  .loop:
    LDA sleeping
    BNE .loop
  RTS

;****************************************************************
; Name:                                                         ;
;   ClearSprites                                                ;
;                                                               ;
; Description:                                                  ;
;   Clears all 64 sprites by setting all values to $FE          ;
;****************************************************************

ClearSprites:
  LDA #CLEAR_SPRITE
  LDX #$FF

  .loop:
    STA sprites, x
    DEX
    BNE .loop
    
  STA sprites, x
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SleepForXFrames                                             ;
;                                                               ;
; Input variables:                                              ;
;   X - number of frames to sleep                               ;
;                                                               ;
; Description:                                                  ;
;   Wait for NMI to happen X times, then exit                   ;
;****************************************************************

SleepForXFrames:
  .loop:
    JSR WaitForFrame
    DEX
    BNE .loop
    
  RTS

;****************************************************************
; Name:                                                         ;
;   DoDrawing                                                   ;
;                                                               ;
; Description:                                                  ;
;   Copies buffered draw data to the PPU.                       ;
;   Input data has the following format:                        ;
;     Byte 0  = length                                          ;
;     Byte 1  = high byte of the PPU address                    ;
;     Byte 2  = low byte of the PPU address                     ;
;     Byte 3  = reserved                                        ;
;     Byte 4+ = {length} bytes                                  ;
;                                                               ;
;   Repeat until length == 0 is found.                          ;
;   Data starts at BUFFER_HIGH_BYTE;BUFFER_LOW_BYTE             ;
;                                                               ;
;   Expects VRAM address increment to be set correctly!         ;
;****************************************************************

DoDrawing:

  LDX #$00                    ; load 0 to the X register
  LDA $2002                   ; read PPU status to reset the high/low latch        
  
  .drawLoop:                    
    
    CPX bufferOffset          ; bufferOffset points at the first available byte
    BEQ DoDrawingDone         ; if we got there it means drawing is done
  
    LDY drawBuffer, x         ; load the length of the data to the Y register
    BEQ DoDrawingDone         ; length equal 0 means that the drawing is done  
    
    INX                       ; X = 1
    LDA drawBuffer, x         ; load the high byte of the target address
    STA $2006                 ; write the high byte to PPU
    
    INX                       ; X = 2
    LDA drawBuffer, x         ; load the low byte of the target address
    STA $2006                 ; write the low byte to PPU
    
    INX                       ; X = 3
        
    .setLoop:
      INX                     ; increment X
      LDA drawBuffer, x       ; load a byte of the data
      STA $2007               ; write it to PPU
      DEY                     ; decrement Y
      BNE .setLoop            ; if Y != 0 jump to .setLoop
                              ; POI - possible issue - make sure this branch doesn't cross pages
      
    INX                       ; increment X so it points to the next segment      
    JMP .drawLoop             ; jump back to draw

DoDrawingDone:
  
  LDA #$00
  STA bufferOffset            ; reset buffer offset to 0

  RTS

;****************************************************************
; Name:                                                         ;
;   FadeOut                                                     ;
;                                                               ;
; Description:                                                  ;
;   Fades out to black                                          ;
;****************************************************************

FadeOut:

  LDA #%00111110           ; intensify reds
  STA soft2001             
  INC needPpuReg           
  LDX #$04
  JSR SleepForXFrames
  
  LDA #%01111110           ; intensify greens and reds
  STA soft2001             
  INC needPpuReg           
  LDX #$04
  JSR SleepForXFrames

  LDA #%00000100           ; disable PPU
  STA soft2001
  INC needPpuReg
  LDX #$04
  JSR SleepForXFrames
  
  RTS

;****************************************************************
; Name:                                                         ;
;   DisablePPU                                                  ;
;                                                               ;
; Description:                                                  ;
;   Disable sprites and backgrounds                             ;
;****************************************************************
  
DisablePPU:  
  LDA #%00000110                ; disable sprites and background
  STA soft2001                  
  INC needPpuReg                
  JSR WaitForFrame              
  RTS
  
;****************************************************************
; Name:                                                         ;
;   RenderSprite                                                ;
;                                                               ;
; Description:                                                  ;
;   Renders a sprite based on input parameters                  ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;****************************************************************

RenderSprite:  
  LDX spritePointer
  DEC renderYPos                ; sprites are rendered one line below the y position
  LDA renderYPos
  STA sprites, x
  INX
  LDA renderTile
  STA sprites, x
  INX
  LDA renderAtts
  STA sprites, x
  INX
  LDA renderXPos
  STA sprites, x
  LDA spritePointer
  CLC
  ADC #SPRITE_POINTER_JUMP  
  STA spritePointer
  RTS
  
;****************************************************************
; Modules import                                                ;
;****************************************************************

  .include "lib\backgroundManager.asm"
  .include "lib\levelManager.asm"
  .include "lib\controllerManager.asm"  
  .include "lib\collisionManager.asm"
  .include "lib\playerController.asm"
  .include "lib\explosionsController.asm"
  .include "lib\bulletController.asm"
  .include "lib\enemiesManager.asm"
  .include "lib\elevatorManager.asm"

Bank2End:
  
  .bank 0
  .org $8000
    
  .include "lib\paletteManager.asm"   

  .include "states\game.asm"
    
Bank0Start:
Bank0End:
    
  .bank 1
  .org $A000

Bank1Start:

Bank1End:
  
  .bank 3
  .org $E000
  
Bank3Start:
  
  .include "data\levels.asm"
  .include "data\enemies.asm"
 
Bank3End:
  
;****************************************************************
; Vectors                                                       ;
;****************************************************************

  .bank 3
  .org $FFFA  ; vectors starts here
  .dw NMI     ; when an NMI happens (once per frame if enabled) the processor will jump to the label NMI:
  .dw RESET   ; when the processor first turns on or is reset, it will jump to the label RESET:
  .dw 0       ; external interrupt IRQ is not used

;****************************************************************
; CHR import                                                    ;
;****************************************************************
  
  .bank 4
  .org $0000

  .incbin "PlatformerGraphics\chr\spr_00.chr"
  .incbin "PlatformerGraphics\chr\bg_00.chr"