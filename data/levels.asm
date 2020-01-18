LevelsStart:

;****************************************************************
; Levels                                                        ;                           
; Holds information about all levels                            ;
;****************************************************************

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

NUMBER_OF_LEVELS = $05

LEVEL_TYPE_GAME = $00
LEVEL_TYPE_STORY = $01

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

; format:
; 1st byte = bank to load
; 2nd and 3rd byte = pointer to data
; 4th byte = lvl type (0 = game, 1 = story)

levels:
  .byte $00, LOW(story0), HIGH(story0), LEVEL_TYPE_STORY
  .byte $02, LOW(level00), HIGH(level00), LEVEL_TYPE_GAME
  .byte $00, LOW(story1), HIGH(story1), LEVEL_TYPE_STORY
  .byte $03, LOW(levelBoss), HIGH(levelBoss), LEVEL_TYPE_GAME
  .byte $00, LOW(credits), HIGH(credits), LEVEL_TYPE_STORY
  
LevelsEnd: