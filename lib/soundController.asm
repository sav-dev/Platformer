SoundControllerStart:

;****************************************************************
; SoundController                                               ;
; Responsible for processing the sound                          ;
;****************************************************************

;****************************************************************
; Name:                                                         ;
;   InitializeSound                                             ;
;                                                               ;
; Description:                                                  ;
;   Initializes sound. Expects the sound bank to be loaded.     ;
;****************************************************************

InitializeSound:
  LDA #SOUND_REGION_NTSC
  STA <sound_param_byte_0
  LDA #LOW(song_list)
  STA <sound_param_word_0
  LDA #HIGH(song_list)
  STA <sound_param_word_0 + $01
  LDA #LOW(sfx_list)
  STA <sound_param_word_1
  LDA #HIGH(sfx_list)
  STA <sound_param_word_1 + $01
  LDA #LOW(envelopes_list)
  STA <sound_param_word_2
  LDA #HIGH(envelopes_list)
  STA <sound_param_word_2 + $01
  ;LDA #LOW(dpcm_list)
  ;STA <sound_param_word_3
  ;LDA #HIGH(dpcm_list)
  ;STA <sound_param_word_3 + $01
  JMP sound_initialize
  
;****************************************************************
; Name:                                                         ;
;   PlaySong                                                    ;
;                                                               ;
; Description:                                                  ;
;   Start playing a song.                                       ;
;                                                               ;
; Input variables:                                              ;
;   X points to the id of the song we want to play.             ;
;****************************************************************

PlaySong:
  LDY #SOUND_BANK
  JSR SwitchBank
  STX <sound_param_byte_0
  JSR play_song
  JMP RestoreBank
  
;****************************************************************
; Name:                                                         ;
;   PauseSong                                                   ;
;                                                               ;
; Description:                                                  ;
;   Pauses playing the song                                     ;
;****************************************************************

PauseSong:
  LDY #SOUND_BANK
  JSR SwitchBank
  TXA
  PHA ; pause_song doesn't restore X register
  JSR pause_song
  PLA
  TAX
  JMP RestoreBank

;****************************************************************
; Name:                                                         ;
;   ResumeSong                                                  ;
;                                                               ;
; Description:                                                  ;
;   Resumes playing the song                                    ;
;****************************************************************

ResumeSong:
  LDY #SOUND_BANK
  JSR SwitchBank
  JSR resume_song
  JMP RestoreBank

;****************************************************************
; Name:                                                         ;
;   SfxOptionSelected                                           ;
;                                                               ;
; Description:                                                  ;
;   Play the 'option selected' sfx                              ;
;****************************************************************
  
SfxOptionSelected:
  PlaySfxHighPri #sfx_index_sfx_shot ; todo 0007: update the sound
  RTS

;****************************************************************
; Name:                                                         ;
;   SfxOptionChanged                                            ;
;                                                               ;
; Description:                                                  ;
;   Play the 'option changed' sfx                               ;
;****************************************************************
  
SfxOptionChanged:
  PlaySfxLowPri #sfx_index_sfx_shot ; todo 0007: update the sound
  RTS
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

SoundControllerEnd: