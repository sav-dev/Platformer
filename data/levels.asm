;****************************************************************
; Levels                                                        ;                           
; Holds information about all levels                            ;
;****************************************************************

;
; Current format:
; 
; - number of unique tiles (1 byte)
; - sprites for each tile (4 bytes each)
;
; - number of columns (1 byte)
; - column of 0s
; - tiles in each column (15 bytes each)
; - column of 0s
; - atts column of 0s
; - attributes (# of columns x 4 bytes)
; - atts column of 0s
;
; - platforms in the following format:
;   - pointer to next screen (from here): (n x 4) + 3 (1 byte)
;   - number of platforms (1 byte)
;   - n times platform data (x1, y1, x2, y2) (n x 4 bytes)
;     both checks should be greater/less or equal - e.g. values will be x1 = 0, x2 = 15
;   - pointer to the previous screen (from here): (n x 4) + 2 (1 byte)
; - threats in the same format
;

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

NUMBER_OF_LEVELS = $02

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

levels:
  .byte LOW(level00), HIGH(level00)
  .byte LOW(level01), HIGH(level01)
  
;****************************************************************
; Level Data                                                    ;                           
;****************************************************************

level00:
  .incbin "data\levels\00.bin"
  
level01:
  .incbin "data\levels\01.bin"