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
  LDA #$00
  STA <songPlaying
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
  STX <currentSong
  LDA #$01
  STA <songPlaying
  JSR play_song
  JMP RestoreBank
  RTS
  
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
  LDA #$00
  STA <songPlaying
  JMP RestoreBank
  RTS
  
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
  LDA #$01
  STA <songPlaying
  JMP RestoreBank
  RTS
  
;****************************************************************
; Name:                                                         ;
;   SfxHighPri                                                  ;
;                                                               ;
; Description:                                                  ;
;   Play an SFX with high priority                              ;
;                                                               ;
; Input variables:                                              ;
;   sfxToPlay                                                   ;
;****************************************************************
  
SfxHighPri:
  LDY #SOUND_BANK
  JSR SwitchBank
  LDA <sfxToPlay
  STA <sound_param_byte_0
  LDA #soundeffect_two ; high pri
  STA <sound_param_byte_1
  JSR play_sfx
  JMP RestoreBank

;****************************************************************
; Name:                                                         ;
;   SfxLowPri                                                   ;
;                                                               ;
; Description:                                                  ;
;   Play an SFX with low priority                               ;
;                                                               ;
; Input variables:                                              ;
;   sfxToPlay                                                   ;
;****************************************************************
  
SfxLowPri:
  LDY #SOUND_BANK
  JSR SwitchBank
  LDA <sfxToPlay
  STA <sound_param_byte_0
  LDA #soundeffect_one ; low pri
  STA <sound_param_byte_1
  JSR play_sfx
  JMP RestoreBank
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

SoundControllerEnd: