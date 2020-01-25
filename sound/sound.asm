song_index_song_none = 0

sfx_index_sfx_option_selected = 0
sfx_index_sfx_option_changed = 1
sfx_index_sfx_pause = 2
sfx_index_sfx_keycard = 3
sfx_index_sfx_blinker = 4
sfx_index_sfx_shot_player = 5
sfx_index_sfx_shot_turret = 6
sfx_index_sfx_shot_tank = 7
sfx_index_sfx_shot_gunrob = 8
sfx_index_sfx_shot_boss = 9
sfx_index_sfx_expl_player = 10
sfx_index_sfx_expl_blast = 11
sfx_index_sfx_expl_org = 12

song_list:
  .dw _song_none

sfx_list:
  .dw _sfx_option_selected
  .dw _sfx_option_changed
  .dw _sfx_pause
  .dw _sfx_keycard
  .dw _sfx_blinker
  .dw _sfx_shot_player
  .dw _sfx_shot_turret
  .dw _sfx_shot_tank
  .dw _sfx_shot_gunrob
  .dw _sfx_shot_boss
  .dw _sfx_expl_player
  .dw _sfx_expl_blast
  .dw _sfx_expl_org

envelopes_list:
  .dw volume
  .dw arpeggio
  .dw pitch
  .dw duty

volume:
  .dw volume0
  .dw volume1
  .dw volume2
  .dw volume3
  .dw volume4
  .dw volume5
  .dw volume6
  .dw volume7

arpeggio:
  .dw arpeggio0
  .dw arpeggio1

pitch:
  .dw pitch0
  .dw pitch1
  .dw pitch2
  .dw pitch3
  .dw pitch4

duty:
  .dw duty0
  .dw duty1

volume0:
  .db 15,13,11,10,9,8,7,6,5,4,3,3,2,1,0,ENV_STOP
volume1:
  .db 15,10,5,0,ENV_STOP
volume2:
  .db 0,ENV_STOP
volume3:
  .db 9,9,9,9,9,9,9,9,0,ENV_STOP
volume4:
  .db 8,8,8,8,8,8,8,8,8,8,8,0,ENV_STOP
volume5:
  .db 15,10,7,7,10,12,13,12,10,8,5,3,3,3,3,4,5,6,5,3,2,1,1,0,ENV_STOP
volume6:
  .db 10,8,6,3,2,3,4,5,5,5,5,5,4,4,3,2,2,2,2,1,1,1,1,0,ENV_STOP
volume7:
  .db 0,ENV_STOP

arpeggio0:
  .db ARP_TYPE_ABSOLUTE,0,4,7,4,0,ENV_LOOP,1
arpeggio1:
  .db ARP_TYPE_ABSOLUTE,ENV_STOP

pitch0:
  .db -20,-20,-20,-20,-20,-20,-20,-20,-20,-20,-20,-20,-20,-20,-20,ENV_STOP
pitch1:
  .db 45,42,39,36,33,30,27,24,21,18,ENV_STOP
pitch2:
  .db 8,8,13,15,15,16,30,47,ENV_STOP
pitch3:
  .db 5,45,75,ENV_STOP
pitch4:
  .db 0,ENV_STOP

duty0:
  .db 64,DUTY_ENV_STOP
duty1:
  .db 0,DUTY_ENV_STOP

_song_none:
  .db 0
  .db 6
  .db 0
  .db 5
  .dw 0
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_option_selected:
  .db 0, 1
  .db 0, 1
  .dw _sfx_option_selected_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_option_selected_square1:
  .db CAL,low(_sfx_option_selected_square1_0),high(_sfx_option_selected_square1_0)
  .db TRM
_sfx_option_selected_square1_0:
  .db SLL,15,STV,0,SAR,1,STP,0,SDU,1,E3
  .db RET

_sfx_option_changed:
  .db 0, 1
  .db 0, 1
  .dw _sfx_option_changed_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_option_changed_square1:
  .db CAL,low(_sfx_option_changed_square1_0),high(_sfx_option_changed_square1_0)
  .db TRM
_sfx_option_changed_square1_0:
  .db STV,1,SAR,1,STP,4,SDU,1,SLL,122,SLH,1,B3,SLL,4,B3
  .db RET

_sfx_pause:
  .db 0, 1
  .db 0, 1
  .dw _sfx_pause_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_pause_square1:
  .db CAL,low(_sfx_pause_square1_0),high(_sfx_pause_square1_0)
  .db TRM
_sfx_pause_square1_0:
  .db STV,0,SAR,1,STP,0,SDU,1,SLL,6,D4,C4,SLL,1,STV,2,STP,4
  .db C4
  .db RET

_sfx_keycard:
  .db 0, 1
  .db 0, 1
  .dw _sfx_keycard_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_keycard_square1:
  .db CAL,low(_sfx_keycard_square1_0),high(_sfx_keycard_square1_0)
  .db TRM
_sfx_keycard_square1_0:
  .db STV,1,SAR,1,STP,4,SDU,1,SLL,6,F4,FS4,SLL,4,G4
  .db RET

_sfx_blinker:
  .db 0, 1
  .db 0, 1
  .dw _sfx_blinker_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_blinker_square1:
  .db CAL,low(_sfx_blinker_square1_0),high(_sfx_blinker_square1_0)
  .db TRM
_sfx_blinker_square1_0:
  .db SLL,9,STV,3,SAR,0,STP,4,SDU,1,G1
  .db RET

_sfx_shot_player:
  .db 0, 1
  .db 0, 1
  .dw _sfx_shot_player_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_shot_player_square1:
  .db CAL,low(_sfx_shot_player_square1_0),high(_sfx_shot_player_square1_0)
  .db TRM
_sfx_shot_player_square1_0:
  .db SLL,15,STV,0,SAR,1,STP,1,SDU,1,C4
  .db RET

_sfx_shot_turret:
  .db 0, 1
  .db 0, 1
  .dw _sfx_shot_turret_square1
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_sfx_shot_turret_square1:
  .db CAL,low(_sfx_shot_turret_square1_0),high(_sfx_shot_turret_square1_0)
  .db TRM
_sfx_shot_turret_square1_0:
  .db SLL,12,STV,4,SAR,1,STP,2,SDU,1,C6
  .db RET

_sfx_shot_tank:
  .db 0, 1
  .db 0, 1
  .dw 0
  .dw 0
  .dw 0
  .dw _sfx_shot_tank_noise
  .dw 0

_sfx_shot_tank_noise:
  .db CAL,low(_sfx_shot_tank_noise_0),high(_sfx_shot_tank_noise_0)
  .db TRM
_sfx_shot_tank_noise_0:
  .db SLL,12,STV,4,SAR,1,STP,2,SDU,1,0
  .db RET

_sfx_shot_gunrob:
  .db 0, 1
  .db 0, 1
  .dw 0
  .dw 0
  .dw _sfx_shot_gunrob_triangle
  .dw 0
  .dw 0

_sfx_shot_gunrob_triangle:
  .db CAL,low(_sfx_shot_gunrob_triangle_0),high(_sfx_shot_gunrob_triangle_0)
  .db TRM
_sfx_shot_gunrob_triangle_0:
  .db SLL,12,STV,4,SAR,1,STP,2,SDU,1,C4
  .db RET

_sfx_shot_boss:
  .db 0, 1
  .db 0, 1
  .dw 0
  .dw 0
  .dw 0
  .dw _sfx_shot_boss_noise
  .dw 0

_sfx_shot_boss_noise:
  .db CAL,low(_sfx_shot_boss_noise_0),high(_sfx_shot_boss_noise_0)
  .db TRM
_sfx_shot_boss_noise_0:
  .db SLL,12,STV,4,SAR,1,STP,3,SDU,1,4
  .db RET

_sfx_expl_player:
  .db 0, 1
  .db 0, 1
  .dw 0
  .dw 0
  .dw 0
  .dw _sfx_expl_player_noise
  .dw 0

_sfx_expl_player_noise:
  .db CAL,low(_sfx_expl_player_noise_0),high(_sfx_expl_player_noise_0)
  .db TRM
_sfx_expl_player_noise_0:
  .db SLL,24,STV,5,SAR,1,STP,4,SDU,1,7
  .db RET

_sfx_expl_blast:
  .db 0, 1
  .db 0, 1
  .dw 0
  .dw 0
  .dw 0
  .dw _sfx_expl_blast_noise
  .dw 0

_sfx_expl_blast_noise:
  .db CAL,low(_sfx_expl_blast_noise_0),high(_sfx_expl_blast_noise_0)
  .db TRM
_sfx_expl_blast_noise_0:
  .db SLL,24,STV,6,SAR,1,STP,3,SDU,1,7
  .db RET

_sfx_expl_org:
  .db 0, 1
  .db 0, 1
  .dw 0
  .dw 0
  .dw 0
  .dw _sfx_expl_org_noise
  .dw 0

_sfx_expl_org_noise:
  .db CAL,low(_sfx_expl_org_noise_0),high(_sfx_expl_org_noise_0)
  .db TRM
_sfx_expl_org_noise_0:
  .db SLL,24,STV,6,SAR,1,STP,4,SDU,0,6
  .db RET

