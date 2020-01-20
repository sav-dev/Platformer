;****************************************************************
; Macros                                                        ;
;****************************************************************

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
    LDA \1
    STA <sfxToPlay
    JSR SfxHighPri
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
    LDA \1
    STA <sfxToPlay
    JSR SfxLowPri
  endm 