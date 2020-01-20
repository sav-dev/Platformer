LevelsStart:

;****************************************************************
; Levels                                                        ;                           
; Holds information about all levels                            ;
;****************************************************************

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

NUMBER_OF_LEVELS = $05
LEVEL_DEF_SIZE   = $03

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

; format:
; 1st byte = bank to load
; 2nd and 3rd byte = pointer to data

levels:
  .byte $00, LOW(story0), HIGH(story0)
  .byte $02, LOW(level00), HIGH(level00)
  .byte $00, LOW(story1), HIGH(story1)
  .byte $03, LOW(levelBoss), HIGH(levelBoss)
  .byte $00, LOW(credits), HIGH(credits)
  
LevelsEnd: