LevelsStart:

;****************************************************************
; Levels                                                        ;                           
; Holds information about all levels                            ;
;****************************************************************

;****************************************************************
; Constants                                                     ;                           
;****************************************************************

NUMBER_OF_LEVELS = $09
LEVEL_DEF_SIZE   = $03

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

; format:
; 1st byte = bank to load
; 2nd and 3rd byte = pointer to data

levels:

  ; stage 1
  .byte $00, LOW(storyStage1), HIGH(storyStage1)
  .byte $02, LOW(level00), HIGH(level00)
  
  ; stage 2
  .byte $00, LOW(storyStage2), HIGH(storyStage2)
  
  ; stage 3
  .byte $00, LOW(storyStage3), HIGH(storyStage3)
  
  ; stage 4
  .byte $00, LOW(storyStage4), HIGH(storyStage4)

  ; stage 5
  .byte $00, LOW(storyStage5), HIGH(storyStage5)
  .byte $03, LOW(levelBoss), HIGH(levelBoss)
  
  ; congrats
  .byte $00, LOW(storyCongrats), HIGH(storyCongrats)
  
  ; credits
  .byte $00, LOW(storyCredits), HIGH(storyCredits)
  
LevelsEnd: