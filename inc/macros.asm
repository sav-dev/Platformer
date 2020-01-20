;****************************************************************
; Macros                                                        ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   PlaySfx                                                     ;
;                                                               ;
; Description:                                                  ;
;   Play SFX macro                                              ;
;                                                               ;
; Input variables:                                              ;
;   1) sound to play                                            ;
;   2) priority                                                 ;
;****************************************************************
  
  macro PlaySfx
    LDY #SOUND_BANK
    JSR SwitchBank
    LDA \1
    STA <sound_param_byte_0
    LDA \2
    STA <sound_param_byte_1
    JSR play_sfx
    JSR RestoreBank
  endm

;****************************************************************
; Name:                                                         ;
;   PlaySfxLowPri                                               ;
;                                                               ;
; Description:                                                  ;
;   Play SFX with low pri macro                                 ;
;                                                               ;
; Input variables:                                              ;
;   1) sound to play                                            ;
;****************************************************************  
  
  macro PlaySfxLowPri
    PlaySfx \1, #soundeffect_one
  endm
  
;****************************************************************
; Name:                                                         ;
;   PlaySfxHighPri                                              ;
;                                                               ;
; Description:                                                  ;
;   Play SFX with high pri macro                                ;
;                                                               ;
; Input variables:                                              ;
;   1) sound to play                                            ;
;****************************************************************  

  
  macro PlaySfxHighPri
    PlaySfx \1, #soundeffect_two
  endm
  
;****************************************************************
; Name:                                                         ;
;   PlaySfxZp                                                   ;
;                                                               ;
; Description:                                                  ;
;   Play SFX macro (sound to play is in a ZP var)               ;
;                                                               ;
; Input variables:                                              ;
;   1) sound to play                                            ;
;   2) priority                                                 ;
;****************************************************************
  
  macro PlaySfxZp
    LDY #SOUND_BANK
    JSR SwitchBank
    LDA <\1
    STA <sound_param_byte_0
    LDA \2
    STA <sound_param_byte_1
    JSR play_sfx
    JSR RestoreBank
  endm

;****************************************************************
; Name:                                                         ;
;   PlaySfxLowPriZp                                             ;
;                                                               ;
; Description:                                                  ;
;   Play SFX with low pri macro (sound to play is in a ZP var)  ;
;                                                               ;
; Input variables:                                              ;
;   1) sound to play                                            ;
;****************************************************************  
  
  macro PlaySfxLowPriZp
    PlaySfxZp \1, #soundeffect_one
  endm
  
;****************************************************************
; Name:                                                         ;
;   PlaySfxHighPriZp                                            ;
;                                                               ;
; Description:                                                  ;
;   Play SFX with high pri macro (sound to play is in a ZP var) ;
;                                                               ;
; Input variables:                                              ;
;   1) sound to play                                            ;
;****************************************************************  

  
  macro PlaySfxHighPriZp
    PlaySfxZp \1, #soundeffect_two
  endm