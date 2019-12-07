BackgroundManagerStart:

;****************************************************************
; BackgroundManager                                             ;
; Responsible for loading backgrounds                           ;
;                                                               ;
; Game uses vertical scroll, so we update nametables 0 and 1    ;
; Nametable 0 starts at $2000 in PPU                            ;                             
; Nametable 0 attributes start at $23C0 in PPU                  ;
; Nametable 0 starts at $2400 in PPU                            ;                             
; Nametable 0 attributes start at $27C0 in PPU                  ;
;                                                               ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   LoadBackground                                              ;
;                                                               ;
; Description:                                                  ;
;   Loads a background into nametable 0.                        ;
;   Must be called with PPU disabled.                           ;
;                                                               ;
; Input variables:                                              ;
;   genericPointer                                              ;
;   d - number of att. rows to load (also dictates how many     ;
;       tile rows are loaded)                                   ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;****************************************************************

LoadBackground:

  .loadTiles:
    
    LDA $2002                      ; read PPU status to reset the high/low latch
    LDA #$20                       ; loading nametable 0 so address is $2000
    STA $2006                      ; write the high byte of the address ($20)
    LDA #$00                                 
    STA $2006                      ; write the low byte of the address ($00)
                                   
    LDA <d                         ; d = number of att. rows to load
    ASL A                          
    ASL A                          ; d * 4 = number of tile rows to load
    CMP #$1F                       ; carry set if A >= $1F = 31 = too many rows
    BCC .setX                      ; if carry not set, meaning A <= 30, proceed
    LDA #$1E                       ; A = $1E = 30 = max number of rows
    
    .setX:
      TAX                          ; move to X
                                   
    LDA #$00                       
    STA <b                         ; b and c will serve as a counter
    STA <c                         
                                   
    .setTileCounterLoop:           ; set the counters
      LDA <b                       
      CLC                          
      ADC #$20                     ; $20 = 32 bytes = size of a row
      STA <b                       
      LDA <c                       
      ADC #$00                     ; add carry
      STA <c                       
      DEX
      BNE .setTileCounterLoop      
                                   
    LDY #$00               
    
    .loadTilesLoop:                
      LDA [genericPointer], y      ; load a tile byte
      STA $2007                    ; write to the nametable
                                   
      LDA <genericPointer       
      CLC                          
      ADC #$01                     
      STA <genericPointer       
      LDA <genericPointer + $01  
      ADC #$00                     ; add carry
      STA <genericPointer + $01     ; move the pointer
      
      LDA <b
      SEC
      SBC #$01
      STA <b
      LDA <c
      SBC #$00                     ; subtract carry
      STA <c                       ; decrement the loop counter
      
      LDA <b                       ; check exit condition (loop counter being 0)
      BNE .loadTilesLoop
      LDA <c
      BNE .loadTilesLoop

  .loadTilesDone:
  
  .loadAtts:
    
    LDA $2002                      ; read PPU status to reset the high/low latch
    LDA #$23                       ; loading attributes for nametable 0 so address is $23C0
    STA $2006                      ; write the high byte of the address ($23)
    LDA #$C0                                 
    STA $2006                      ; write the low byte of the address ($C0)    
      
    LDA <d                         ; d = number of att. rows to load
    ASL A
    ASL A
    ASL A                          ; A = d * 8; 8 because each attribute row is 8 bytes
    TAX                            ; X will serve as the counter
                                   
    .loadAttsLoop:
      LDA [genericPointer], y      ; load an atts. byte
      STA $2007                    ; write to the nametable      
      
      LDA <genericPointer       
      CLC                          
      ADC #$01                     
      STA <genericPointer       
      LDA <genericPointer + $01  
      ADC #$00                     
      STA <genericPointer + $01     ; move the pointer      
      
      DEX                          ; decrement the loop counter
      BNE .loadAttsLoop            ; check exit condition
      
  .loadAttsDone:
    
  RTS
    
;****************************************************************
; Name:                                                         ;
;   ClearBackgrounds                                            ;
;                                                               ;
; Description:                                                  ;
;   Clears nametables 0 and 1                                   ;
;   Must be called with PPU disabled                            ;
;   Sets all tiles to the "clear tile"                          ;
;   Sets all atts to the "clear atts"                           ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************
    
ClearBackgrounds:

  LDA #$00
  STA <d
  JSR ClearBackground   ; clear nametable 0
  
  INC <d
  JSR ClearBackground   ; clear nametable 1              

  RTS
    
;****************************************************************
; Name:                                                         ;
;   ClearBackground                                             ;
;                                                               ;
; Description:                                                  ;
;   Clears nametables 0 and 1. Must be called with PPU disabled ;
;   Sets all tiles to the "clear tile"                          ;
;                                                               ;
; Used variables:                                               ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************

ClearBackground:
  
  LDA $2002                 ; read PPU status to reset the high/low latch
  LDA <d                    ; nametable index (0 or 1)
  ASL A
  ASL A                     ; A = d * 4
  CLC
  ADC #$20                  ; A = $20 or $24 (high byte of nametable 0 or 1)
  STA $2006                 ; write the high byte of the address
  LDA #$00                            
  STA $2006                 ; write the low byte of the address (always #$00)
  
  LDA #$00
  STA <b                    ; b and c will serve as a counter
  STA <c         
       
  .clearTilesLoop:
    LDA #CLEAR_TILE
    STA $2007               ; write a byte
    
    LDA <b
    CLC
    ADC #$01
    STA <b
    LDA <c
    ADC #$00
    STA <c                  ; increment the counter
    
    CMP #$03
    BNE .clearTilesLoop
    LDA <b
    CMP #$C0
    BNE .clearTilesLoop
    
  .clearAttsLoop:
    LDA #CLEAR_ATTS
    STA $2007
    
    LDA <b
    CLC
    ADC #$01
    STA <b
    LDA <c
    ADC #$00
    STA <c
    
    CMP #$04
    BNE .clearAttsLoop
  
  RTS

;****************************************************************
; Name:                                                         ;
;   LoadLevelBackground                                         ;
;                                                               ;
; Description:                                                  ;
;   Loads the first screen of a level.                          ;
;   Must be called with PPU disabled.                           ;
;                                                               ;
; Input variables:                                              ;
;   levelPointer                                                ;
;                                                               ;
; Output variables:                                             ;
;   genericPointer - set to the first byte after attributes     ;
;   maxScroll - set to the max the level can scroll             ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   i                                                           ;
;   j                                                           ;
;****************************************************************

LoadLevelBackground:

  LDA $2002                            ; read PPU status to reset the high/low latch
  
  LDY #$00                             ; Y = 0    
  .loadUniqueTileCount:                
    LDA [levelPointer], y              ; first byte of the level data: number of unique tiles
    ASL A                              
    STA <b                             ; b = number of unique tiles * 2
    STA <c                             ; c = number of unique tiles * 2
    INY                                ; Y now points to the tile spec
  
  LDX #$00                             ; X = 0        
  .copySpecLoop1:                       
    LDA [levelPointer], y              ; load a byte of the tile spec
    STA leftTiles, x                   ; write to the tile dictionary (left tiles)
    INY                                ; Y = Y + 1
    INX                                ; X = X + 1
    DEC <b                             ; do this enough times to copy all left tile bytes
    BNE .copySpecLoop1                 ; after the loop, levelPointer points to the number of columns
  
  LDX #$00                             ; X = 0        
  .copySpecLoop2:                       
    LDA [levelPointer], y              ; load a byte of the tile spec
    STA rightTiles, x                  ; write to the tile dictionary (left tiles)
    INY                                ; Y = Y + 1
    INX                                ; X = X + 1
    DEC <c                             ; do this enough times to copy all left tile bytes
    BNE .copySpecLoop2                 ; after the loop, levelPointer points to the number of columns
  
  .loadColumnCount:                    
    LDA [levelPointer], y              ; load the number of columns
    STA <b                             ; store it in b
    STA <d                             ; and d
  
  .calculateMaxScroll:                 ; max scroll = (columnCount - 16) * 16
    SEC                                ; A still contains the column count
    SBC #$10                           ; A = columnCount - 16
    TAX                                ; X = columnCount - 16
    LDA #$00                           
    STA <maxScroll                     
    STA <maxScroll + $01                ; reset max scroll to 0
    .maxScrollLoop:                    ; calculate max scroll in a loop
      LDA <maxScroll                   
      CLC                              
      ADC #$10                         ; add $10 = 16
      STA <maxScroll                   
      LDA <maxScroll + $01              
      ADC #$00                         ; add carry
      STA <maxScroll + $01              
      DEX                              
      BNE .maxScrollLoop               
  
  .advancePointerToColumns:            
    INY                                ; Y now points to the first column of 0s
    TYA                                
    CLC                                
    ADC <levelPointer                  
    STA <levelPointer                  ; advance level pointer
    LDA <levelPointer + $01             
    ADC #$00                           ; add carry
    LDA <levelPointer + $01
    JSR MoveLevelPointerForward        ; level pointer now points to the first actual column
  
  .setLevelBackPointer:                
    LDA <levelPointer                  
    STA <levelBackPointer              
    LDA <levelPointer + $01             
    STA <levelBackPointer + $01         ; levelBackPointer points to the first actual column (which will be the left-most rendered column)
  
  .drawColumns:                        
    LDA #$00                           
    STA <c                             ; c = 0
    .drawColumnLoop:                   ; each iteration of this loop draws one column 
  
      LDA <c                           
      AND #%00010000                   
      LSR A                            
      LSR A                            ; after these operations, A contains 4 if c == $10 and 0 otherwise
      CLC                              
      ADC #$20                         ; add $20 to calculate the high byte of the address
      STA <i                           ; i will contain the high byte of the target address
      LDA <c                           
      AND #%00001111                   
      ASL A                            ; after these operations, A contains column index * 2 if c < $10, and 0 otherwise
      STA <j                           ; j will contain the low byte of the address
  
      LDA <i                           
      STA $2006                        ; write the high-byte
      LDA <j                           
      STA $2006                        ; write the low-byte
  
      LDY #$00                         
      .drawTileLoop1:                  ; each iteration of this loop draws the left-most sprites of the tile
        LDA [levelPointer], y          
        ASL A                          
        TAX                            ; X = tile id * 2
        LDA leftTiles, x               ; sprite 0 (top-left)
        STA $2007                      ; write to nametable
        INX                            ; X = X + 1
        LDA leftTiles, x               ; sprite 1 (bottom-left)
        STA $2007                      ; write to nametable
        INY                            ; Y = Y + 1
        CPY #$0F                       ; $0F = 15 = number of tiles in column
        BNE .drawTileLoop1             ; loop until the column is drawn
  
      LDA <i                           
      STA $2006                        ; write the high-byte
      INC <j                           
      LDA <j                           
      STA $2006                        ; write the low-byte (incremented by 1)
  
      LDY #$00                         
      .drawTileLoop2:                  ; each iteration of this loop draws the right-most sprites of the tile
        LDA [levelPointer], y          
        ASL A                          
        TAX                            ; X = tile id * 2
        LDA rightTiles, x              ; sprite 2 (top-right)
        STA $2007                      ; write to nametable
        INX                            ; X = X + 1
        LDA rightTiles, x              ; sprite 3 (bottom-right)
        STA $2007                      ; write to nametable      
        INY                            ; Y = Y + 1
        CPY #$0F                       ; $0F = 15 = number of tiles in column
        BNE .drawTileLoop2             ; loop until the column is drawn
  
      INC <c                           
      LDA <c                           
      CMP #$11                         ; $11 = 17 = number of columns on one screen + 1 (we only need half of the last column but it doesn't matter)
      BEQ .drawColumnsDone             ; if that many columns where drawn - exit
                                       ; this way we don't move the pointer and it stays pointing to the last column       
      TYA                              
      CLC                              
      ADC <levelPointer                
      STA <levelPointer                ; advance level pointer to the next column
      LDA <levelPointer + $01           
      ADC #$00                         
      STA <levelPointer + $01           ; add carry     
      JMP .drawColumnLoop              
  .drawColumnsDone:                    
                                       
  .moveLevelPointerBack:               ; we have to move the level pointer back, because even though we've drawn the entire column on the right,
    JSR MoveLevelPointerBack           ; from the scrolling perspective we may have drawn just half of it
  .moveLevelBackPointerDone:           
  
  .goToAttributes:                     
    LDA <levelBackPointer              
    STA <genericPointer                   
    LDA <levelBackPointer + $01         
    STA <genericPointer + $01           ; cache level back pointer in the generic pointer
  
    INC <b                             ; b contains number of columns
    .skipColumnDataLoop:               ; increment it as we have to skip one more column of 0s at the end
      JSR MoveLevelBackPointerForward  ; move level back pointer forward
      DEC <b                           ; 
      BNE .skipColumnDataLoop          ; after the loop level back pointer points to the first column of atts 0s
      
    LDA <levelBackPointer
    STA <attsPointer                   
    LDA <levelBackPointer + $01         
    STA <attsPointer + $01              ; set the attsPointer to the first column of atts 0s
    JSR MoveAttsPointerForward         ; atts pointer points to the first atts column
    
    LDA <genericPointer                
    STA <levelBackPointer              
    LDA <genericPointer + $01           
    STA <levelBackPointer + $01         ; restore level back pointer
  
  .setAttsBackPointer:                 
    LDA <attsPointer                   
    STA <attsBackPointer               
    LDA <attsPointer + $01              
    STA <attsBackPointer + $01          ; attsBackPointer points to the first atts column
    JSR MoveBackAttsPointerBack        ; attsBackPointer points to the column of att 0s
  
  .drawAtts:                           
    LDA #$00                           
    STA <c                             ; c = 0
  
    .drawAttsColumnLoop:               ; each iteration of this loop draws one atts column
      LDA <c                           
      AND #%00001000                   
      LSR A                            ; after these operations, A contains 4 if c == $08 and 0 otherwise
      CLC                              
      ADC #$23                         
      STA <i                           ; i now contains the high byte of PPU address ($23 or $27)
      LDA <c                           
      AND #%00000111                   ; after these operations, A contains 0 if c == $08 and c otherwise
      CLC                              
      ADC #$C0                         
      STA <j                           ; i now contains the low byte of PPU address ($C0 - $F8)
  
      LDY #$00                         ; Y = 0
      .drawAttsTilesLoop:              ; each iteration of this loop draws one atts byte
        LDA <i                         
        STA $2006                      
        LDA <j                         
        STA $2006                      ; set PPU address
        LDA [attsPointer], y           ; load attribute byte
        STA $2007                      ; write in PPU
        LDA <j                         
        CLC                            
        ADC #$08                       
        STA <j                         ; advance PPU pointer by 8
        INY                            
        CPY #$08                       ; $08 = 8 = number of att bytes in a column
        BNE .drawAttsTilesLoop         ; loop until the entire column is drawn
  
      INC <c                           
      LDA <c                           
      CMP #$09                         ; $09 = 9 = number of atts columns on one screen + 1
      BEQ .drawAttsDone                ; if that many atts columns where drawn - exit
                                       ; this way we don't move the atts pointer and it stays pointing to the last atts column
  
      JSR MoveAttsPointerForward       ; advance to the next column
      JMP .drawAttsColumnLoop
  .drawAttsDone:
    
  .setGenericPointer:  
    LDA <attsBackPointer
    STA <b
    LDA <attsBackPointer + $01
    STA <c                             ; cache atts back pointer in {b,c}
     
    LDA <d                             ; d contains the number of columns
    LSR A                              ; A = d / 2 = number of attribute columns
    CLC
    ADC #$02                           ; we'll have to skip two more columns of att 0s
    TAX                                ; X = number of attribute columns to skip
    
    .skipAttsLoop:
      JSR MoveBackAttsPointerForward
      DEX
      BNE .skipAttsLoop
      
    LDA <attsBackPointer
    STA <genericPointer
    LDA <attsBackPointer + $01
    STA <genericPointer + $01           ; generic pointer points to the first byte after atts
      
    LDA <b
    STA <attsBackPointer
    LDA <c
    STA <attsBackPointer + $01          ; restore atts back pointer      
  .setGenericPointerDone:
  
LoadLevelBackgroundDone:
  RTS
  
;
; POITAG - possible optimization - lots of code below is duplicated
; for perf. reasons. If PGR ROM is needed, it can be refactored.
;
; POITAG - possible optimization - perf may be a bit better if level
; pointer point to the column to-be-drawn instead of the current one
;

  
;****************************************************************
; Name:                                                         ;
;   IncrementScroll                                             ;
;                                                               ;
; Description:                                                  ;
;   Increments the scroll, then checks if any new rows          ;
;   must be drawn - if yes, buffers that data                   ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;****************************************************************

IncrementScroll:

  LDA #$00
  STA <e                               ; e is a flag that is used later, init it with 0

  ;
  ; back level pointer moves back when scroll:          9->8, 25->24, 41->40 etc
  ; back level pointer should move forward when scroll: 8->9, 24->25, 40->41 etc
  ; 
  ; back atts pointer moves back when scroll:           33->32, 65->64, 97->96 etc
  ; back atts pointer should move forward when scroll:  32->33, 64->65, 96->97 etc 
  ;
  
  .shouldMovePointers:
    .shouldMoveLevelPointer:           ; should move back level pointer forward if current scroll is a multiple of 8 but not 16
      LDA <scroll
      AND #%00001111                   ; check if scroll is a multiple of 16
      BEQ .shouldMoveLevelPointerDone  ; done if lower bits == 0, still check for atts though
      CMP #%00001000                   ; if is multiple of 8, only the 4th bit will be set
      BNE .shouldMovePointersDone      ; if not multiple of 8, exit, also that means we don't have to check for multiple of 32
      JSR MoveLevelBackPointerForward  ; back level pointer must be moved forward as the last 'fully rendered' column has moved
      INC <e                           ; no need to check for new data, mark that by incrementing e
    .shouldMoveLevelPointerDone:
    
    .shouldMoveAttsPointer:            ; should move atts pointer back if current scroll is a multiple of 32
      LDA <scroll
      AND #%00011111                   ; check if scroll is a multiple of 32
      BNE .shouldMovePointersDone      ; done if lower bits != 0
      JSR MoveBackAttsPointerForward   ; back atts pointer must be moved forward as the last 'fully rendered' atts column has moved
      INC <e                           ; no need to check for new data, mark that by incrementing e
    .shouldMoveAttsPointerDone:
  .shouldMovePointersDone:
  
  .updateScroll:                   
    INC <needPpuRegLocal           
    LDA <scroll                    
    CLC                            
    ADC #SCROLL_SPEED              
    STA <scroll                    
  .updateScrollDone:               
                                   
  .checkForScrollWrap:             
    BCC .checkForScrollWrapDone        ; check if scroll wrapped, carry would be set
    INC <scroll + $01                   ; inc the scroll high byte
    LDA <nametable                     
    EOR #%00000001                     
    STA <nametable                     ; swap the nametable from 0 to 1 and vice versa    
    LDA <soft2000                      
    AND #%11111110                     
    ORA <nametable                     
    STA <soft2000                      ; set the base nametable address
    JSR MovePlatformsPointerForward    ; move platforms pointer forward
    JSR MoveThreatsPointerForward      ; move threats pointer forward
    JSR LoadEnemiesForward             ; load enemies for the screen in the front, also moves the enemies pointer
    JSR LoadElevatorsForward           ; load elevators for the screen in the front, also moves the elevators pointer
  .checkForScrollWrapDone:             
                                       
  .newDataCheck:
    LDA <e
    BNE IncrementScrollDone            ; no need to check for anything based on previous actions
  
    .newTileColumnCheck:               
      .checkIfMultipleOf16:            
        LDA <scroll                    
        AND #%00001111                 ; check if scroll is a multiple of 16
        BNE .checkIfMultipleOf8        ; not multiple of 16, check if multiple of 8
        LDA #$00                       
        STA <b                         ; set b to 0 (draw left tiles)
        JSR NewColumnOnTheRight        ; draw new column on the right (left tiles)
        JMP .newAttsColumnCheck        ; jump to attribute check
                                       
      .checkIfMultipleOf8:             
        LDA <scroll                    
        AND #%00000111                 ; check if scroll is a multiple of 8
        BNE .newDataCheckDone          ; done if lower bits != 0. It also means we don't have to check for attributes
        LDA #$01                       
        STA <b                         ; set b to 1 (draw right tiles)
        JSR NewColumnOnTheRight        ; draw new column on the right (right tiles)
    .newTileColumnCheckDone:           
                                       
    .newAttsColumnCheck:               
      LDA <scroll                      
      AND #%00011111                   ; check if scroll is a multiple of 32
      BNE .newAttsColumnCheckDone      ; done if lower bits != 0
      JSR NewAttsOnTheRight            ; draw new atts on the right
    .newAttsColumnCheckDone:           
                                       
    INC <needDrawLocal                 ; if we got here it means draw during NMI will be required    
  .newDataCheckDone:  
  
IncrementScrollDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   NewColumnOnTheRight                                         ;
;                                                               ;
; Description:                                                  ;
;   Buffers new column of tiles on the right                    ;
;                                                               ;
; Input variables:                                              ;
;   b: 0 means draw the left column of tiles,                   ;
;      1 means draw the right column of tiles                   ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************

NewColumnOnTheRight:

  .movePointerForward:
    JSR MoveLevelPointerForward     ; move level pointer forward to the column we want to draw
  .movePointerForwardDone:
  
  .bufferData:

    LDX <bufferOffset               ; load buffer offset to the X register
    LDA #$1E                        ; load $1E = 30 to the A register (we're drawing a column of sprites == 30 bytes)
    STA drawBuffer, x               ; set that to byte 0 of the buffer segment

    INX                             ; increment the X register (now X == 1)
    LDA <nametable
    EOR #$01                        ; A = 1 if nt = 0, A = 0 if nt = 1
    ASL A
    ASL A                           ; A = 4 if nt = 0, A = 0 if nt = 1
    CLC
    ADC #$20                        ; A = $24 if nt = 0, A = $20 if nt = 1 - high byte of the address    
    STA drawBuffer, x               ; set that to byte 1 of the buffer segment

    INX                             ; increment the X register (now X == 2)
    LDA <scroll
    LSR A
    LSR A
    LSR A                           ; A = scroll / 8 - low byte of the address
    STA drawBuffer, x               ; set that to byte 2 of the buffer segment   

    INX                             ; increment the X register (now X == 3)

    INX                             ; increment the X register (now X == 4, points to where we want to write)    
    
    LDY #$00                        ; start out at 0    
    
    LDA <b
    BNE .drawRightTiles             ; b = 1 means draw right tiles, b = 0 means draw left tiles
    
    .drawLeftTiles:                 ; each iteration of this loop draws the left-most sprites of the tile   
      STX <bufferOffset             ; store the X register in the buffer offset
    
      LDA [levelPointer], y         ; load the tile id                                    
      ASL A                         
      TAX                           ; X = tile id * 2
      LDA leftTiles, x              ; sprite 0 (top-left)
      STA <c                        ; store it in c
      INX                           ; X = X + 1
      LDA leftTiles, x              ; sprite 1 (bottom-left)
      STA <d                        ; store it in d
      
      LDX <bufferOffset             ; load the bufferOffset back to X
      
      LDA <c                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
      LDA <d                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
                                    
      INY                           ; Y = Y + 1
      CPY #$0F                      ; $0F = 15 = number of tiles in column
      BNE .drawLeftTiles            ; loop until the column is drawn
    
    JMP .updateBufferOffset         ; skip drawing right tiles    

    .drawRightTiles:                ; each iteration of this loop draws the left-most sprites of the tile    
      STX <bufferOffset             ; store the X register in the buffer offset
    
      LDA [levelPointer], y         ; load the tile id                                    
      ASL A                               
      TAX                           ; X = tile id * 2
      LDA rightTiles, x             ; sprite 2 (top-right)
      STA <c                        ; store it in c
      INX                           ; X = X + 1
      LDA rightTiles, x             ; sprite 3 (bottom-right)
      STA <d                        ; store it in d
      
      LDX <bufferOffset             ; load the bufferOffset back to X
      
      LDA <c                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
      LDA <d                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
                                    
      INY                           ; Y = Y + 1
      CPY #$0F                      ; $0F = 15 = number of tiles in column
      BNE .drawRightTiles           ; loop until the column is drawn
  
    .updateBufferOffset:    
      STX <bufferOffset             ; update bufferOffset, X points to the right place

  .bufferDataDone:
  
  .movePointerBack:  
    LDA <b                          ; move the front pointer back if b == 0, meaning we've drawn the left
    BNE .movePointerBackDone        ; column of sprites, meaning the column of tiles is not yet fully drawn  
    JSR MoveLevelPointerBack
  .movePointerBackDone:
  
  RTS

;****************************************************************
; Name:                                                         ;
;   NewAttsOnTheRight                                           ;
;                                                               ;
; Description:                                                  ;
;   Buffers new column of atts on the right                     ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************

NewAttsOnTheRight:

  .movePointerForward:
    JSR MoveAttsPointerForward      ; move atts pointer forward to the column we want to draw
  .movePointerForwardDone:

  .calculateAddress:
  
    LDA <nametable
    EOR #$01                        ; A = 1 if nt = 0, A = 0 if nt = 1
    ASL A
    ASL A                           ; A = 4 if nt = 0, A = 0 if nt = 1
    CLC
    ADC #$23                        ; A = $27 if nt = 0, A = $23 if nt = 1 - high byte of the address
    STA <c                          ; c holds the high byte of the address - we always write to the other nametable
    
    LDA <scroll
    LSR A
    LSR A
    LSR A
    LSR A
    LSR A
    CLC
    ADC #$C0                        ; A = scroll / 32 + $C0 - low byte of the address
    STA <d                          ; d holds the low byte of the address
      
  .calculateAddressDone:

  .bufferData:
              
    LDX <bufferOffset               ; X will contain buffer offset
    LDY #$00                        ; Y will contain source offset
    
    .drawAtts:

      LDA #$01                      ; load $01 = 01 to the A register (buffering 1 byte at the time)
      STA drawBuffer, x             ; set that to byte 0 of the buffer segment
  
      INX                           ; increment the X register (now X == 1)
      LDA <c                        ; load the high byte of the target address
      STA drawBuffer, x             ; set that to byte 1 of the buffer segment
  
      INX                           ; increment the X register (now X == 2)
      LDA <d                        ; load the low byte of the target address
      STA drawBuffer, x             ; set that to byte 2 of the buffer segment   
      CLC
      ADC #$08                      ; advance low-byte of target address by 8
      STA <d
  
      INX                           ; increment the X register (now X == 3)
      
      INX                           ; increment the X register (now X == 4)
      LDA [attsPointer], y          ; load atts. byte
      STA drawBuffer, x             ; write in the buffer

      INX                           ; increment X so it points to the first free byte      
      
      INY                           ; increment the Y register
      CPY #$08                      ; compare to #$08 = 8 = number of bytes to copy      

      BNE .drawAtts                 ; loop if needed
      
    STX <bufferOffset               ; update the buffer offset, X points to the right place
      
  .bufferDataDone:  
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   DecrementScroll                                             ;
;                                                               ;
; Description:                                                  ;
;   Decrements the scroll, then checks if any new rows          ;
;   must be drawn - if yes, buffers that data                   ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;****************************************************************

DecrementScroll:

  LDA #$00
  STA <e                                ; e is a flag that is used later, init it with 0

  ;
  ; front level pointer moves forward when scroll:      7->8, 23->24, 39->40 etc
  ; front level pointer should move back when scroll:   8->7, 24->23, 40->39 etc
  ; 
  ; front atts pointer moves forward when scroll:       31->32, 63->64, 95->96 etc
  ; front atts pointer should move back when scroll:    32->31, 64->63, 96->95 etc 
  ;
  
  .shouldMovePointers:
    .shouldMoveLevelPointer:           ; should move level pointer back if current scroll is a multiple of 8 but not 16
      LDA <scroll
      AND #%00001111                   ; check if scroll is a multiple of 16
      BEQ .shouldMoveLevelPointerDone  ; done if lower bits == 0, still check for atts though
      CMP #%00001000                   ; if is multiple of 8, only the 4th bit will be set
      BNE .shouldMovePointersDone      ; if not multiple of 8, exit, also that means we don't have to check for multiple of 32
      JSR MoveLevelPointerBack         ; level pointer must be moved back as the last 'fully rendered' column has moved
      INC <e                           ; no need to check for new data, mark that by incrementing e
    .shouldMoveLevelPointerDone:
    
    .shouldMoveAttsPointer:            ; should move atts pointer back if current scroll is a multiple of 32
      LDA <scroll
      AND #%00011111                   ; check if scroll is a multiple of 32
      BNE .shouldMovePointersDone      ; done if lower bits != 0
      JSR MoveAttsPointerBack          ; atts pointer must be moved back as the last 'fully rendered' atts column has moved
      INC <e                           ; no need to check for new data, mark that by incrementing e
    .shouldMoveAttsPointerDone:
  .shouldMovePointersDone:

  .updateScroll:
    INC <needPpuRegLocal
    LDA <scroll
    SEC
    SBC #SCROLL_SPEED
    STA <scroll
  .updateScrollDone:   
   
  .checkForScrollWrap:
    BCS .checkForScrollWrapDone        ; check if scroll wrapped, carry would be set if it did
    DEC <scroll + $01                   ; dec the scroll high byte
    LDA <nametable                     
    EOR #%00000001                     
    STA <nametable                     ; swap the nametable from 0 to 1 and vice versa    
    LDA <soft2000                      
    AND #%11111110                     
    ORA <nametable                     
    STA <soft2000                      ; set the base nametable address
    JSR MovePlatformsPointerBack       ; move platforms pointer back
    JSR MoveThreatsPointerBack         ; move threats pointer back
    JSR LoadEnemiesBack                ; load enemies for the screen in the back, also moves the enemies pointer
    JSR LoadElevatorsBack              ; load elevators for the screen in the back, also moves the elevators pointer
  .checkForScrollWrapDone:

  .newDataCheck:
    LDA <e                             
    BNE DecrementScrollDone            ; no need to check for anything based on previous actions
                                       
    .newTileColumnCheck:               
      .checkIfMultipleOf16:            
        LDA <scroll                    
        AND #%00001111                 ; check if scroll is a multiple of 16
        BNE .checkIfMultipleOf8        ; not multiple of 16, check if multiple of 8
        LDA #$01                       
        STA <b                         ; set b to 1 (draw right tiles)
        JSR NewColumnOnTheLeft         ; draw new column on the left (right tiles)
        JMP .newAttsColumnCheck        ; jump to attribute check
                                       
      .checkIfMultipleOf8:             
        LDA <scroll                    
        AND #%00000111                 ; check if scroll is a multiple of 8
        BNE .newDataCheckDone          ; done if lower bits != 0. It also means we don't have to check for attributes
        LDA #$00                       
        STA <b                         ; set b to 0 (draw left tiles)
        JSR NewColumnOnTheLeft         ; draw new column on the left (left tiles)
    .newTileColumnCheckDone:           
                                       
    .newAttsColumnCheck:               
      LDA <scroll                      
      AND #%00011111                   ; check if scroll is a multiple of 32
      BNE .newAttsColumnCheckDone      ; done if lower bits != 0
      JSR NewAttsOnTheLeft             ; draw new atts on the left
    .newAttsColumnCheckDone:           
                                       
    INC <needDrawLocal                 ; if we got here it means draw during NMI will be required    
  .newDataCheckDone:
  
DecrementScrollDone:
  RTS
  
;****************************************************************
; Name:                                                         ;
;   NewColumnOnTheLeft                                          ;
;                                                               ;
; Description:                                                  ;
;   Buffers new column of tiles on the left                     ;
;                                                               ;
; Input variables:                                              ;
;   b: 0 means draw the left column,                            ;
;      1 means draw the right column                            ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************

NewColumnOnTheLeft:

  .movePointerBack:
    JSR MoveLevelBackPointerBack    ; move level back pointer back to the column we want to draw
  .movePointerBackDone:

  .bufferData:
  
    .calculateAddress:
    
      LDA <scroll
      BNE .scrollNot0Case
      
      .scroll0Case:                 ; scroll = 0: special case: address = 31 in other nametable
        LDA <nametable
        EOR #$01                    ; A = 1 if nt = 0, A = 0 if nt = 1
        ASL A
        ASL A                       ; A = 4 if nt = 0, A = 0 if nt = 1
        CLC
        ADC #$20                    ; A = $24 if nt = 0, A = $20 if nt = 1 - high byte of the address
        STA <c                      ; store the high byte in c
        LDA #$1F                    ; $1F = 31 - low byte of the address
        STA <d                      ; store the low byte in d
        JMP .calculateAddressDone;
      
      .scrollNot0Case:              ; scroll != 0: address = scroll / 8 - 1 in current nametable
        LDA <nametable
        ASL A
        ASL A                       ; A = 4 if nt = 1, A = 0 if nt = 0
        CLC
        ADC #$20                    ; A = $24 if nt = 1, A = $20 if nt = 0 - high byte of the address
        STA <c                      ; store the high byte in c
        LDA <scroll
        LSR A
        LSR A
        LSR A                       ; A = scroll / 8
        STA <d                      ; d = scroll / 8
        DEC <d                      ; d = (scroll / 8) - 1 - low byte of the address
        
    .calculateAddressDone:
  
    LDX <bufferOffset               ; load buffer offset to the X register
    LDA #$1E                        ; load $1E = 30 to the A register (we're drawing a column of sprites == 30 bytes)
    STA drawBuffer, x               ; set that to byte 0 of the buffer segment

    INX                             ; increment the X register (now X == 1)
    LDA <c                          ; load high-byte of target address
    STA drawBuffer, x               ; set that to byte 1 of the buffer segment

    INX                             ; increment the X register (now X == 2)
    LDA <d                          ; load low-byte of target address
    STA drawBuffer, x               ; set that to byte 2 of the buffer segment   

    INX                             ; increment the X register (now X == 3)

    INX                             ; increment the X register (now X == 4, points to where we want to write)    
    
    LDY #$00                        ; start out at 0    
    
    LDA <b
    BNE .drawRightTiles             ; b = 1 means draw right tiles, b = 0 means draw left tiles
    
    .drawLeftTiles:                 ; each iteration of this loop draws the left-most sprites of the tile   
      STX <bufferOffset             ; store the X register in the buffer offset
    
      LDA [levelBackPointer], y     ; load the tile id                                    
      ASL A                         
      TAX                           ; X = tile id * 2
      LDA leftTiles, x              ; sprite 0 (top-left)
      STA <c                        ; store it in c
      INX                           ; X = X + 1
      LDA leftTiles, x              ; sprite 1 (bottom-left)
      STA <d                        ; store it in d
      
      LDX <bufferOffset             ; load the bufferOffset back to X
      
      LDA <c                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
      LDA <d                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
                                    
      INY                           ; Y = Y + 1
      CPY #$0F                      ; $0F = 15 = number of tiles in column
      BNE .drawLeftTiles            ; loop until the column is drawn
    
    JMP .updateBufferOffset         ; skip drawing right tiles    

    .drawRightTiles:                ; each iteration of this loop draws the left-most sprites of the tile    
      STX <bufferOffset             ; store the X register in the buffer offset
    
      LDA [levelBackPointer], y     ; load the tile id                                    
      ASL A                               
      TAX                           ; X = tile id * 2
      LDA rightTiles, x             ; sprite 2 (top-right)
      STA <c                        ; store it in c
      INX                           ; X = X + 1
      LDA rightTiles, x             ; sprite 3 (bottom-right)
      STA <d                        ; store it in d
      
      LDX <bufferOffset             ; load the bufferOffset back to X
      
      LDA <c                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
      LDA <d                        ; sprite 0
      STA drawBuffer, x             ; buffer the sprite
      INX                           ; X = X + 1
                                    
      INY                           ; Y = Y + 1
      CPY #$0F                      ; $0F = 15 = number of tiles in column
      BNE .drawRightTiles           ; loop until the column is drawn
  
    .updateBufferOffset:    
      STX <bufferOffset             ; update bufferOffset, X points to the right place

  .bufferDataDone:
  
  .movePointerForward:  
    LDA <b                          ; move the back pointer forward if b == 1, meaning we've drawn the right
    BEQ .movePointerForwardDone     ; column of sprites, meaning the column of tiles is not yet fully drawn  
    JSR MoveLevelBackPointerForward
  .movePointerForwardDone:
  
  RTS

;****************************************************************
; Name:                                                         ;
;   NewAttsOnTheLeft                                            ;
;                                                               ;
; Description:                                                  ;
;   Buffers new column of atts on the right                     ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   c                                                           ;
;   d                                                           ;
;****************************************************************

NewAttsOnTheLeft:

  .movePointerBack:
    JSR MoveBackAttsPointerBack   ; move back atts pointer back to the column we want to draw
  .movePointerBackDone:
  
  .calculateAddress:

    LDA <scroll
    BNE .scrollNot0Case
    
    .scroll0Case:                 ; scroll = 0: special case: address = C7 in other nametable
      LDA <nametable
      EOR #$01                    ; A = 1 if nt = 0, A = 0 if nt = 1
      ASL A
      ASL A                       ; A = 4 if nt = 0, A = 0 if nt = 1
      CLC
      ADC #$23                    ; A = $27 if nt = 0, A = $23 if nt = 1 - high byte of the address
      STA <c                      ; store the high byte in c
      LDA #$C7                    ; low byte of the address
      STA <d                      ; store the low byte in d
      JMP .calculateAddressDone;
    
    .scrollNot0Case:              ; scroll != 0: (scroll / 32) + $BF in current nametable
      LDA <nametable
      ASL A
      ASL A                       ; A = 4 if nt = 1, A = 0 if nt = 0
      CLC
      ADC #$23                    ; A = $27 if nt = 1, A = $23 if nt = 0 - high byte of the address
      STA <c                      ; store the high byte in c
      LDA <scroll
      LSR A
      LSR A
      LSR A
      LSR A
      LSR A                       ; A = scroll / 32
      CLC
      ADC #$BF                    ; A = (scroll / 32) + $BF
      STA <d                      ; store the low byte in d - low byte of the address
      
  .calculateAddressDone:

  .bufferData:
              
    LDX <bufferOffset               ; X will contain buffer offset
    LDY #$00                        ; Y will contain source offset
    
    .drawAtts:

      LDA #$01                      ; load $01 = 01 to the A register (buffering 1 byte at the time)
      STA drawBuffer, x             ; set that to byte 0 of the buffer segment
  
      INX                           ; increment the X register (now X == 1)
      LDA <c                        ; load the high byte of the target address
      STA drawBuffer, x             ; set that to byte 1 of the buffer segment
  
      INX                           ; increment the X register (now X == 2)
      LDA <d                        ; load the low byte of the target address
      STA drawBuffer, x             ; set that to byte 2 of the buffer segment   
      CLC
      ADC #$08                      ; advance low-byte of target address by 8
      STA <d
  
      INX                           ; increment the X register (now X == 3)
      
      INX                           ; increment the X register (now X == 4)
      LDA [attsBackPointer], y      ; load atts. byte
      STA drawBuffer, x             ; write in the buffer

      INX                           ; increment X so it points to the first free byte      
      
      INY                           ; increment the Y register
      CPY #$08                      ; compare to #$08 = 8 = number of bytes to copy      

      BNE .drawAtts                 ; loop if needed
      
    STX <bufferOffset               ; update the buffer offset, X points to the right place
      
  .bufferDataDone:  
  
  RTS
  
;****************************************************************
; Name:                                                         ;
;   MoveLevelPointerForward                                     ;
;                                                               ;
; Description:                                                  ;
;   Moves the level pointer forward one column.                 ;
;   POITAG - RLE - have an input/output parameter which says    ;
;         how many bytes to move/pointer has been moved by      ;
;****************************************************************

MoveLevelPointerForward:
  LDA <levelPointer
  CLC
  ADC #$0F
  STA <levelPointer
  LDA <levelPointer + $01
  ADC #$00
  STA <levelPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveLevelPointerBack                                        ;
;                                                               ;
; Description:                                                  ;
;   Moves the level pointer back one column.                    ;
;   POITAG - RLE - have an input/output parameter which says    ;
;         how many bytes to move/pointer has been moved by      ;
;****************************************************************

MoveLevelPointerBack:
  LDA <levelPointer
  SEC
  SBC #$0F
  STA <levelPointer
  LDA <levelPointer + $01
  SBC #$00
  STA <levelPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveLevelBackPointerForward                                 ;
;                                                               ;
; Description:                                                  ;
;   Moves the back level pointer forward one column.            ;
;   POITAG - RLE - have an input/output parameter which says    ;
;         how many bytes to move/pointer has been moved by      ;
;****************************************************************

MoveLevelBackPointerForward:
  LDA <levelBackPointer
  CLC
  ADC #$0F
  STA <levelBackPointer
  LDA <levelBackPointer + $01
  ADC #$00
  STA <levelBackPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveLevelBackPointerBack                                    ;
;                                                               ;
; Description:                                                  ;
;   Moves the back level pointer forward one column.            ;
;   POITAG - RLE - have an input/output parameter which says    ;
;         how many bytes to move/pointer has been moved by      ;
;****************************************************************

MoveLevelBackPointerBack:
  LDA <levelBackPointer
  SEC
  SBC #$0F
  STA <levelBackPointer
  LDA <levelBackPointer + $01
  SBC #$00
  STA <levelBackPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveAttsPointerForward                                      ;
;                                                               ;
; Description:                                                  ;
;   Moves the atts pointer forward one column.                  ;
;****************************************************************

MoveAttsPointerForward:
  LDA <attsPointer
  CLC
  ADC #$08
  STA <attsPointer
  LDA <attsPointer + $01
  ADC #$00
  STA <attsPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveAttsPointerBack                                        ;
;                                                               ;
; Description:                                                  ;
;   Moves the atts pointer back one column.                     ;
;****************************************************************

MoveAttsPointerBack:
  LDA <attsPointer
  SEC
  SBC #$08
  STA <attsPointer
  LDA <attsPointer + $01
  SBC #$00
  STA <attsPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveBackAttsPointerForward                                  ;
;                                                               ;
; Description:                                                  ;
;   Moves the back atts pointer forward one column.             ;
;****************************************************************

MoveBackAttsPointerForward:
  LDA <attsBackPointer
  CLC
  ADC #$08
  STA <attsBackPointer
  LDA <attsBackPointer + $01
  ADC #$00
  STA <attsBackPointer + $01
  RTS

;****************************************************************
; Name:                                                         ;
;   MoveBackAttsPointerBack                                     ;
;                                                               ;
; Description:                                                  ;
;   Moves the back atts pointer forward one column.             ;
;****************************************************************

MoveBackAttsPointerBack:
  LDA <attsBackPointer
  SEC
  SBC #$08
  STA <attsBackPointer
  LDA <attsBackPointer + $01
  SBC #$00
  STA <attsBackPointer + $01
  RTS
  
;****************************************************************
; Name:                                                         ;
;   ScrollLeft                                                  ;
;                                                               ;
; Description:                                                  ;
;   Scroll left, move bullets.                                  ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;****************************************************************

ScrollLeft:
  JSR DecrementScroll
  LDA #$01
  STA <b
  JMP ScrollBullets

;****************************************************************
; Name:                                                         ;
;   ScrollRight                                                 ;
;                                                               ;
; Description:                                                  ;
;   Scroll right, move bullets.                                 ;
;                                                               ;
; Used variables:                                               ;
;   X                                                           ;
;   Y                                                           ;
;   b                                                           ;
;   c                                                           ;
;   d                                                           ;
;   e                                                           ;
;****************************************************************

ScrollRight:
  JSR IncrementScroll
  LDA #$00
  STA <b
  JMP ScrollBullets
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

BackgroundManagerEnd: