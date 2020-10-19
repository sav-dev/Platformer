LevelsStart:

;****************************************************************
; Levels                                                        ;                           
; Holds information about all levels                            ;
;****************************************************************

;****************************************************************
; Constants                                                     ;
;****************************************************************

LEVEL_DEF_SIZE = $03

;****************************************************************
; Level List                                                    ;                           
;****************************************************************

; format:
; 1st byte = bank to load
; 2nd and 3rd byte = pointer to data

levels:

STAGE_COUNT = $05

  ; stage 1
NUMBER_OF_LEVELS_STAGE_1 = $0D
  .byte $00, LOW(storyStage1), HIGH(storyStage1)
  .byte $02, LOW(level_1_01), HIGH(level_1_01)
  .byte $02, LOW(level_1_02), HIGH(level_1_02)
  .byte $02, LOW(level_1_03), HIGH(level_1_03)
  .byte $02, LOW(level_1_04), HIGH(level_1_04)
  .byte $02, LOW(level_1_05), HIGH(level_1_05)
  .byte $02, LOW(level_1_06), HIGH(level_1_06)
  .byte $02, LOW(level_1_07), HIGH(level_1_07)
  .byte $02, LOW(level_1_08), HIGH(level_1_08)
  .byte $02, LOW(level_1_09), HIGH(level_1_09)
  .byte $02, LOW(level_1_10), HIGH(level_1_10)
  .byte $02, LOW(level_1_11), HIGH(level_1_11)
  .byte $02, LOW(level_1_12), HIGH(level_1_12)
  
  ; stage 2
NUMBER_OF_LEVELS_STAGE_2 = $04
  .byte $00, LOW(storyStage2), HIGH(storyStage2)
  .byte $04, LOW(level_2_01), HIGH(level_2_01)
  .byte $04, LOW(level_2_02), HIGH(level_2_02)
  .byte $04, LOW(level_2_03), HIGH(level_2_03)
  
  ; stage 3
NUMBER_OF_LEVELS_STAGE_3 = $09
  .byte $00, LOW(storyStage3), HIGH(storyStage3)
  .byte $03, LOW(level_3_01), HIGH(level_3_01)
  .byte $03, LOW(level_3_02), HIGH(level_3_02)
  .byte $03, LOW(level_3_03), HIGH(level_3_03)
  .byte $03, LOW(level_3_04), HIGH(level_3_04)
  .byte $04, LOW(level_3_05), HIGH(level_3_05)
  .byte $03, LOW(level_3_06), HIGH(level_3_06)
  .byte $04, LOW(level_3_07), HIGH(level_3_07)
  .byte $03, LOW(level_3_08), HIGH(level_3_08)
  
  ; stage 4
NUMBER_OF_LEVELS_STAGE_4 = $02
  .byte $00, LOW(storyStage4), HIGH(storyStage4)
  .byte $05, LOW(level_4_01), HIGH(level_4_01)

  ; stage 5
NUMBER_OF_LEVELS_STAGE_5 = $02
  .byte $00, LOW(storyStage5), HIGH(storyStage5)
  .byte $05, LOW(level_5_05), HIGH(level_5_05)
  
  ; congrats
NUMBER_OF_LEVELS_CONGRATS = $01
  .byte $00, LOW(storyCongrats), HIGH(storyCongrats)
  
  ; credits
NUMBER_OF_LEVELS_CREDITS = $01
  .byte $00, LOW(storyCredits), HIGH(storyCredits)
  
LevelsEnd:

;****************************************************************
; Constants contd.                                              ;
;****************************************************************

NUMBER_OF_LEVELS = NUMBER_OF_LEVELS_STAGE_1 + NUMBER_OF_LEVELS_STAGE_2 + NUMBER_OF_LEVELS_STAGE_3 + NUMBER_OF_LEVELS_STAGE_4 + NUMBER_OF_LEVELS_STAGE_5 + NUMBER_OF_LEVELS_CONGRATS + NUMBER_OF_LEVELS_CREDITS