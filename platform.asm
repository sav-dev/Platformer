;****************************************************************
; iNES headers                                                  ;
;****************************************************************

  .inesprg 8  ; 8x 16KB = 128 PRG code
  .ineschr 0  ; no CHR ROM
  .inesmap 2  ; mapper 2 = UNROM
  .inesmir 1  ; vertical mirroring for horizontal scrolling
  
;****************************************************************
; Variables                                                     ;
;****************************************************************
    
  .include "ggsound\ggsound.inc"
  .include "inc\zeroPage.asm"
  .include "inc\variables.asm"
  
;****************************************************************
; Global constants                                              ;
;****************************************************************

  .include "inc\constants.asm"
  .include "inc\constSprites.asm"
  
;****************************************************************
; RESET handler                                                 ;
;****************************************************************

Bank14:

  .bank 14
  .org $C000 

Bank14Start:
  
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
  
initPPU:
  LDA #$00                 
  STA <needDma
  STA <needDraw
  STA <needPpuReg

  STA <bufferOffset
  
  JSR ClearPalettes        ; clear all palettes so there's no initial color flashing
  JSR ClearSprites         ; clear all sprites
  JSR ClearBackgrounds     ; clear all backgrounds
                           
  LDA #%00000110           ; init PPU - disable sprites and background
  STA <soft2001            
  STA $2001                
  LDA #%10010000           ; enable NMI, sprites from PT 0, bg from PT 1, 1 VRAM inc
  STA <soft2000            
  STA $2000                
  BIT $2002                
  LDA #$00                 ; no horizontal scroll (yet)
  STA $2005                
  LDA #$00                 ; no vertical scroll
  STA $2005                
                
  INC <needDma
  INC <needDraw
  JSR WaitForFrame         ; wait for one frame for everything to get loaded
  
initSprChr:
  LDY #CHR_BANK
  JSR SelectBank
  LDA #LOW(sprChr)
  STA <genericPointer
  LDA #HIGH(sprChr)
  STA <genericPointer + $01
  JSR LoadSprChr

initGame:
  LDA #GAMESTATE_TITLE
  STA <gameState
  LDY #FIRST_BANK
  JSR SelectBank
  JSR LoadTitle
  
;****************************************************************
; Game loop                                                     ;
;****************************************************************

GameLoop:

  .incrementFrameCounter:
    INC <frameCount
  
  .readController:
    JSR ReadController      ; always read controller input first    
                                                        
  .checkGameState:          
    LDA <gameState
    ;CMP #GAMESTATE_GAME    ; GAMESTATE_GAME = 0
    BEQ .gameStateGame
    CMP #GAMESTATE_EXPL
    BEQ .gameStateExpl
    CMP #GAMESTATE_TITLE
    BEQ .gameStateTitle
    CMP #GAMESTATE_STAGE_SELECT
    BEQ .gameStateStageSelect
    CMP #GAMESTATE_CREDITS
    BEQ .gameStateCredits
    CMP #GAMESTATE_STORY
    BEQ .gameStateStory
  
  .gameStateGame:
    JSR GameFrame
    JMP GameLoopDone
  
  .gameStateExpl:
    JSR ExplFrame
    JMP GameLoopDone
  
  .gameStateTitle:
    JSR TitleFrame
    JMP GameLoopDone
    
  .gameStateStageSelect:
    ;JSR StageSelectFrame todo 0010
    JMP GameLoopDone
  
  .gameStateCredits:
    ;JSR CreditsFrame todo 0010
    JMP GameLoopDone
  
  .gameStateStory:
    JSR StoryFrame
    JMP GameLoopDone
  
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
  LDA <needDma              
  BEQ NoDma               
    LDA #SPRITES_LOW_BYTE   ; do sprite DMA
    STA $2003               ; conditional via the 'needDma' flag
    LDA #SPRITES_HIGH_BYTE  
    STA $4014
    LDA #$00
    JMP DmaDone
  NoDma:                    ; since we always do DMA in the game logic, if we hit this it means we're lagging
    NOP                     ; useful for debugging. backlog - remove this once the game is done
  DmaDone:                  
                            
  LDA <needDraw             ; do other PPU drawing
  BEQ DrawDone              ; conditional via the 'needDraw' flag
    BIT $2002               ; clear VBl flag, reset $2005/$2006 toggle
    JSR DoDrawing           ; draw the stuff from the drawing buffer
    JMP DoPpuReg            ; after drawing PPU reg is required
  DrawDone:
                            
  LDA <needPpuReg           ; PPU register updates
  BEQ PpuRegDone            ; conditional via the 'needPpuReg' flag
  DoPpuReg:
    LDA <soft2001           ; copy buffered $2000/$2001
    STA $2001               
    LDA <soft2000           
    STA $2000               
                            
    BIT $2002               ; set the scroll
    LDA <scroll             ; set horizontal scroll
    STA $2005                
    LDA #$00                ; no vertical scroll
    STA $2005               
  PpuRegDone:
                     
  LDA #$00                  ; clear the sleeping flag so that WaitForFrame will exit, also clear all conditional flags
  STA <needDma
  STA <needDraw
  STA <needPpuReg
  STA <sleeping             
                         
  soundengine_update        ; update the sound engine
                         
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
  INC <sleeping
  .loop:
    LDA <sleeping
    BNE .loop
  RTS

;****************************************************************
; Name:                                                         ;
;   ClearSprites                                                ;
;                                                               ;
; Description:                                                  ;
;   Clears all 64 sprites by setting all values to $FF          ;
;****************************************************************

ClearSprites:
  LDA #CLEAR_SPRITE_FF
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
    
    CPX <bufferOffset         ; bufferOffset points at the first available byte
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
                              ; POITAG - possible issue - make sure this branch doesn't cross pages
      
    INX                       ; increment X so it points to the next segment      
    JMP .drawLoop             ; jump back to draw

DoDrawingDone:
  
  LDA #$00
  STA <bufferOffset           ; reset buffer offset to 0

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
  STA <soft2001            
  INC <needPpuReg          
  LDX #$04
  JSR SleepForXFrames
  
  LDA #%01111110           ; intensify greens and reds
  STA <soft2001            
  INC <needPpuReg          
  LDX #$04
  JSR SleepForXFrames

  LDA #%00000100           ; disable PPU
  STA <soft2001
  INC <needPpuReg
  LDX #$04
  JSR SleepForXFrames
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   FadeIn                                                      ;
;                                                               ;
; Description:                                                  ;
;   Fades in from black                                         ;
;****************************************************************

FadeIn: ; todo 0010 - is this required

  LDA #%01111110           ; enable PPU with reds and greens intensified
  STA <soft2001            
  INC <needPpuReg          
  LDX #$04
  JSR SleepForXFrames
  
  LDA #%00111110           ; deintensify greens
  STA <soft2001            
  INC <needPpuReg          
  LDX #$04
  JSR SleepForXFrames
  
  LDA #%00011110           ; deintensify reds
  STA <soft2001            
  INC <needPpuReg          
  LDX #$04
  JSR SleepForXFrames
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   FlipGreyscale                                               ;
;                                                               ;
; Description:                                                  ;
;   Flip greyscale                                              ;
;****************************************************************

FlipGreyscale:

  LDA <soft2001
  EOR #%00000001           ; flip the greyscale bit
  STA <soft2001            
  INC <needPpuReg          
  RTS
  
;****************************************************************
; Name:                                                         ;
;   EnablePPU                                                   ;
;                                                               ;
; Description:                                                  ;
;   Enable sprites and backgrounds                              ;
;****************************************************************
  
EnablePPU:  
  LDA #%00011110                ; enable sprites and background
  STA <soft2001                 
  INC <needPpuReg               
  JSR WaitForFrame              
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
  STA <soft2001                 
  INC <needPpuReg               
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
  LDX <spritePointer
  LDA <renderYPos
  SEC
  SBC #$01           ; sprites are rendered one line below the y position
  STA sprites, x
  INX
  LDA <renderTile
  STA sprites, x
  INX
  LDA <renderAtts
  STA sprites, x
  INX
  LDA <renderXPos
  STA sprites, x
  LDA <spritePointer
  CLC
  ADC #SPRITE_POINTER_JUMP  
  STA <spritePointer
  RTS
    
;****************************************************************
; Name:                                                         ;
;   SetVramAddressingTo1                                        ;
;                                                               ;
; Description:                                                  ;
;   Sets VRAM addressing mode to inc by 1                       ;
;****************************************************************

SetVramAddressingTo1:
    LDA #%10010000                ; enable NMI, sprites from PT 0, bg from PT 1. Use NT 0, 1 VRAM increment (for palettes)
    STA <soft2000
    INC <needPpuReg
    JMP WaitForFrame              ; wait for values to be written
  
;****************************************************************
; Name:                                                         ;
;   SetVramAddressingTo32                                       ;
;                                                               ;
; Description:                                                  ;
;   Sets VRAM addressing mode to inc by 32                      ;
;****************************************************************
 
SetVramAddressingTo32:
    LDA #%10010100                ; enable NMI, sprites from PT 0, bg from PT 1. Use NT 0, 32 VRAM increment (for background)
    STA <soft2000
    INC <needPpuReg
    JMP WaitForFrame              ; wait for values to be written
  
;****************************************************************
; Modules import                                                ;
;****************************************************************

  .include "lib\backgroundManager.asm"    
  .include "lib\playerController.asm"    
  .include "lib\enemiesManager.asm"  
  .include "lib\collisionManager.asm"
  .include "lib\explosionsController.asm"
  .include "lib\paletteManager.asm"   
  .include "lib\bankManager.asm"

  .include "states\game.asm"
  
Bank14End:
  
Bank15:
  
  .bank 15
  .org $E000
  
Bank15Start: 
 
  .include "data\enemies.asm" ; this has to be in this place
  .include "data\bullets.asm"
  
  .include "lib\soundController.asm"
  .include "lib\ggsoundInclude.asm"  
  .include "lib\controllerManager.asm" 
  .include "lib\bulletController.asm"
  .include "lib\chrManager.asm"
  .include "lib\elevatorManager.asm" 
  .include "lib\doorManager.asm"
  .include "lib\levelManager.asm"

  
Bank15End:

;****************************************************************
; UNROM Bank $00                                                ;
;****************************************************************

Bank00:

  .bank 0
  .org $8000
  
Bank00Start:
              
  .include "states\title.asm"
  .include "states\story.asm"
  .include "lib\stringManager.asm"
  .include "lib\cursorController.asm"
  .include "lib\progressManager.asm"
  .include "data\logoAndText.asm"
  .include "data\levels.asm"
              
  story0:
  .incbin "data\stories\testStory.bin"
              
Bank00End:

Bank01:
    
  .bank 1
  .org $A000
  
Bank01Start:

  titleChr:
    .byte $0A
    .incbin "PlatformerGraphics\Chr\titleProcessed.chr"

  titleSound:
    .include "ggsound\sound.asm"  

Bank01End:

;****************************************************************
; UNROM Bank $01                                                ;
;****************************************************************

Bank02:

  .bank 2
  .org $8000

Bank02Start:  

  .include "data\tilesets.asm"
  
  bg0chr:
  .byte $10
  .incbin "PlatformerGraphics\Chr\bg_0Processed.chr"

  bg1chr:
  .byte $0F
  .incbin "PlatformerGraphics\Chr\bg_1processed.chr"
  
Bank02End:
  
Bank03:
  
  .bank 3
  .org $A000
  
Bank03Start:  

  bg2chr:
  .byte $0F
  .incbin "PlatformerGraphics\Chr\bg_2processed.chr"
  
  sprChr:
  .byte $10
  .incbin "PlatformerGraphics\Chr\sprProcessed.chr"

Bank03End:

;****************************************************************
; UNROM Bank $02                                                ;
;****************************************************************

Bank04:

  .bank 4
  .org $8000

Bank04Start:  
Bank04End:
  
Bank05:
  
  .bank 5
  .org $A000

Bank05Start:  
Bank05End:

;****************************************************************
; UNROM Bank $03                                                ;
;****************************************************************

Bank06:

  .bank 6
  .org $8000

Bank06Start:  
Bank06End:
  
Bank07:
  
  .bank 7
  .org $A000

Bank07Start:  
Bank07End:

;****************************************************************
; UNROM Bank $04                                                ;
;****************************************************************

Bank08:

  .bank 8
  .org $8000

Bank08Start:  
Bank08End:
  
Bank09:
  
  .bank 9
  .org $A000

Bank09Start:  
Bank09End:

;****************************************************************
; UNROM Bank $05                                                ;
;****************************************************************

Bank10:

  .bank 10
  .org $8000

Bank10Start:  
Bank10End:
  
Bank11:
  
  .bank 11
  .org $A000

Bank11Start:  
Bank11End:

;****************************************************************
; UNROM Bank $06                                                ;
;****************************************************************

Bank12:

  .bank 12
  .org $8000

Bank12Start:  
Bank12End:
  
Bank13:
  
  .bank 13
  .org $A000

Bank13Start:  
Bank13End:
  
;****************************************************************
; Vectors                                                       ;
;****************************************************************

  .bank 15
  .org $FFFA  ; vectors starts here
  .dw NMI     ; when an NMI happens (once per frame if enabled) the processor will jump to the label NMI:
  .dw RESET   ; when the processor first turns on or is reset, it will jump to the label RESET:
  .dw 0       ; external interrupt IRQ is not used