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
;   Initializes sound                                           ;
;****************************************************************

InitializeSound:
  LDA #SOUND_REGION_NTSC
  STA sound_param_byte_0
  LDA #LOW(song_list)
  STA sound_param_word_0
  LDA #HIGH(song_list)
  STA sound_param_word_0 + $01
  LDA #LOW(sfx_list)
  STA sound_param_word_1
  LDA #HIGH(sfx_list)
  STA sound_param_word_1 + $01
  LDA #LOW(envelopes_list)
  STA sound_param_word_2
  LDA #HIGH(envelopes_list)
  STA sound_param_word_2 + $01
  ;LDA #LOW(dpcm_list)
  ;STA sound_param_word_3
  ;LDA #HIGH(dpcm_list)
  ;STA sound_param_word_3 + $01
  JSR sound_initialize

;****************************************************************
; Name:                                                         ;
;   StopSound                                                   ;
;                                                               ;
; Description:                                                  ;
;   Stops all sound                                             ;
;****************************************************************
  
StopSound:
  JMP sound_stop
  
;****************************************************************
; Name:                                                         ;
;   PlaySong                                                    ;
;                                                               ;
; Description:                                                  ;
;   Play the song from this module                              ;
;****************************************************************

PlaySong:
  LDA #song_index_song
  STA sound_param_byte_0
  JSR play_song
  RTS
  
;****************************************************************
; Name:                                                         ;
;   StopSong                                                    ;
;                                                               ;
; Description:                                                  ;
;   Stop playing the song                                       ;
;****************************************************************

StopSong:
  JMP pause_song

;****************************************************************
; Name:                                                         ;
;   ResumeSong                                                  ;
;                                                               ;
; Description:                                                  ;
;   Resumes playing the song                                    ;
;****************************************************************

ResumeSong:
  JMP resume_song
  
;****************************************************************
; Name:                                                         ;
;   SfxShot                                                     ;
;                                                               ;
; Description:                                                  ;
;   Play the 'shot' sfx                                         ;
;****************************************************************

SfxShot:
  LDA #sfx_index_sfx_shot
  STA sound_param_byte_0
  LDA #soundeffect_one
  STA sound_param_byte_1
  JMP play_sfx
  
;****************************************************************
; Name:                                                         ;
;   SfxExplode                                                  ;
;                                                               ;
; Description:                                                  ;
;   Play the 'explode' sfx                                      ;
;****************************************************************

SfxExplode:
  LDA #sfx_index_sfx_explode
  STA sound_param_byte_0
  LDA #soundeffect_one
  STA sound_param_byte_1
  JMP play_sfx
  
;****************************************************************
; EOF                                                           ;
;****************************************************************

SoundControllerEnd: