song_index_song_title = 0
song_index_song_story = 1
song_index_song_stage_outside = 2
song_index_song_stage_base = 3
song_index_song_stage_space = 4
song_index_song_stage_caves = 5
song_index_song_stage_skulls = 6
song_index_song_congrats = 7

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
  .dw _song_title
  .dw _song_story
  .dw _song_stage_outside
  .dw _song_stage_base
  .dw _song_stage_space
  .dw _song_stage_caves
  .dw _song_stage_skulls
  .dw _song_congrats

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
  .dw volume8
  .dw volume9
  .dw volume10
  .dw volume11
  .dw volume12
  .dw volume13
  .dw volume14

arpeggio:
  .dw arpeggio0
  .dw arpeggio1
  .dw arpeggio2
  .dw arpeggio3

pitch:
  .dw pitch0
  .dw pitch1
  .dw pitch2
  .dw pitch3
  .dw pitch4
  .dw pitch5
  .dw pitch6
  .dw pitch7

duty:
  .dw duty0
  .dw duty1
  .dw duty2

volume0:
  .db 15,13,11,10,9,8,7,6,5,4,3,3,2,1,0,ENV_STOP
volume1:
  .db 15,10,5,0,ENV_STOP
volume2:
  .db 0,ENV_STOP
volume3:
  .db 9,9,9,9,9,9,9,9,0,ENV_STOP
volume4:
  .db 4,4,4,4,4,4,4,4,4,4,4,0,ENV_STOP
volume5:
  .db 15,10,7,7,10,12,13,12,10,8,5,3,3,3,3,4,5,6,5,3,2,1,1,0,ENV_STOP
volume6:
  .db 10,8,6,3,2,3,4,5,5,5,5,5,4,4,3,2,2,2,2,1,1,1,1,0,ENV_STOP
volume7:
  .db 9,7,4,3,2,2,3,4,4,2,1,1,1,0,ENV_STOP
volume8:
  .db 9,7,5,4,3,2,1,1,0,ENV_STOP
volume9:
  .db 4,2,1,1,0,ENV_STOP
volume10:
  .db 6,6,5,5,5,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,0,ENV_STOP
volume11:
  .db 6,5,4,3,2,2,2,1,0,ENV_STOP
volume12:
  .db 4,5,6,7,8,8,8,9,9,9,9,9,9,9,9,9,9,8,8,8,7,7,6,6,5,4,4,3,2,2,2,2,2,3,3,3,4,4,5,6,7,7,7,7,7,6,5,4,4,3,3,2,2,2,1,1,1,1,1,1,ENV_STOP
volume13:
  .db 1,ENV_STOP
volume14:
  .db 0,ENV_STOP

arpeggio0:
  .db ARP_TYPE_ABSOLUTE,0,4,7,4,0,ENV_LOOP,1
arpeggio1:
  .db ARP_TYPE_ABSOLUTE,0,0,-1,-1,-2,ENV_STOP
arpeggio2:
  .db ARP_TYPE_ABSOLUTE,0,4,7,ENV_LOOP,1
arpeggio3:
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
  .db 0,1,2,1,0,ENV_LOOP,0
pitch5:
  .db 0,0,0,0,0,0,0,0,-1,-1,1,1,1,1,-1,-1,-1,-1,ENV_LOOP,10
pitch6:
  .db 82,ENV_LOOP,0
pitch7:
  .db 0,ENV_STOP

duty0:
  .db 64,DUTY_ENV_STOP
duty1:
  .db 192,DUTY_ENV_STOP
duty2:
  .db 0,DUTY_ENV_STOP

_song_title:
  .db 0
  .db 6
  .db 0
  .db 5
  .dw 0
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_song_story:
  .db 0
  .db 15
  .db 128
  .db 12
  .dw 0
  .dw _song_story_square2
  .dw 0
  .dw 0
  .dw 0

_song_story_square2:
_song_story_square2_loop:
  .db CAL,low(_song_story_square2_0),high(_song_story_square2_0)
  .db GOT
  .dw _song_story_square2_loop

_song_story_square2_0:
  .db STV,12,SAR,3,STP,5,SDU,0,SL4,D4,F4,A4,D4,D4,F3,A3,D3,F3,A3
  .db C4,F3,F3,A3,C4,F4
  .db RET

_song_stage_outside:
  .db 0
  .db 6
  .db 0
  .db 5
  .dw 0
  .dw 0
  .dw 0
  .dw 0
  .dw 0

_song_stage_base:
  .db 150
  .db 10
  .db 210
  .db 8
  .dw _song_stage_base_square1
  .dw _song_stage_base_square2
  .dw 0
  .dw _song_stage_base_noise
  .dw 0

_song_stage_base_square1:
  .db CAL,low(_song_stage_base_square1_0),high(_song_stage_base_square1_0)
_song_stage_base_square1_loop:
  .db CAL,low(_song_stage_base_square1_1),high(_song_stage_base_square1_1)
  .db CAL,low(_song_stage_base_square1_2),high(_song_stage_base_square1_2)
  .db GOT
  .dw _song_stage_base_square1_loop

_song_stage_base_square2:
  .db CAL,low(_song_stage_base_square2_0),high(_song_stage_base_square2_0)
_song_stage_base_square2_loop:
  .db CAL,low(_song_stage_base_square2_0),high(_song_stage_base_square2_0)
  .db CAL,low(_song_stage_base_square2_1),high(_song_stage_base_square2_1)
  .db GOT
  .dw _song_stage_base_square2_loop

_song_stage_base_noise:
  .db CAL,low(_song_stage_base_noise_0),high(_song_stage_base_noise_0)
_song_stage_base_noise_loop:
  .db CAL,low(_song_stage_base_noise_1),high(_song_stage_base_noise_1)
  .db CAL,low(_song_stage_base_noise_2),high(_song_stage_base_noise_2)
  .db GOT
  .dw _song_stage_base_noise_loop

_song_stage_base_square1_0:
  .db STV,14,SAR,3,STP,7,SDU,2,SLL,64,A0
  .db RET

_song_stage_base_square1_1:
  .db STV,14,SAR,3,STP,7,SDU,2,SL2,A0,STV,9,SL4,G1,G1,G1,G1,C2
  .db C2,C2,C2,G1,G1,G1,G1,C2,C2,C2,SL2,C2
  .db RET

_song_stage_base_square1_2:
  .db STV,14,SAR,3,STP,7,SDU,2,SL2,A0,STV,9,SL4,G1,G1,G1,G1,A1
  .db A1,A1,A1,G1,G1,G1,G1,A1,A1,A1,SL2,A1
  .db RET

_song_stage_base_square2_0:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,G5,E5,D5,SL2,B4,D5,SL4,C5,A4
  .db C5,SL2,D5,E5,SL4,G5,E5,D5,SL2,B4,D5,SL4,C5,A4,C5,SL2,D5,E5
  .db RET

_song_stage_base_square2_1:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,G5,A5,SL2,B5,G5,SL4,B5,A5,C6
  .db SL2,A5,F5,SL4,A5,G5,A5,SL2,B5,G5,SL4,B5,A5,C6,SL2,A5,F5,SL4
  .db A5
  .db RET

_song_stage_base_noise_0:
  .db STV,14,SAR,3,STP,7,SDU,2,SLL,64,A0
  .db RET

_song_stage_base_noise_1:
  .db STV,11,SAR,3,STP,7,SDU,2,SL4,7,STV,9,13,STV,11,SAR,1,9,SAR,3
  .db SL2,7,7,SL4,7,STV,9,13,STV,11,SAR,1,9,SAR,3,SL2,7,7,SL4
  .db 7,STV,9,13,STV,11,SAR,1,9,SAR,3,SL2,7,7,SL4,7,STV,9,13,STV,11
  .db SAR,1,9,SAR,3,SL2,7,7
  .db RET

_song_stage_base_noise_2:
  .db STV,11,SAR,3,STP,7,SDU,2,SL4,7,STV,9,13,STV,11,SAR,1,9,SAR,3
  .db SL2,7,7,SL4,7,STV,9,13,STV,11,SAR,1,9,SAR,3,SL2,7,7,SL4
  .db 7,STV,9,13,STV,11,SAR,1,9,SAR,3,SL2,7,7,SL4,7,STV,9,13,STV,11
  .db SAR,1,9,SAR,3,SL2,7,7
  .db RET

_song_stage_space:
  .db 23
  .db 4
  .db 104
  .db 3
  .dw 0
  .dw _song_stage_space_square2
  .dw _song_stage_space_triangle
  .dw _song_stage_space_noise
  .dw 0

_song_stage_space_square2:
_song_stage_space_square2_loop:
  .db CAL,low(_song_stage_space_square2_0),high(_song_stage_space_square2_0)
  .db CAL,low(_song_stage_space_square2_0),high(_song_stage_space_square2_0)
  .db CAL,low(_song_stage_space_square2_1),high(_song_stage_space_square2_1)
  .db CAL,low(_song_stage_space_square2_1),high(_song_stage_space_square2_1)
  .db CAL,low(_song_stage_space_square2_2),high(_song_stage_space_square2_2)
  .db CAL,low(_song_stage_space_square2_3),high(_song_stage_space_square2_3)
  .db CAL,low(_song_stage_space_square2_2),high(_song_stage_space_square2_2)
  .db CAL,low(_song_stage_space_square2_4),high(_song_stage_space_square2_4)
  .db GOT
  .dw _song_stage_space_square2_loop

_song_stage_space_triangle:
_song_stage_space_triangle_loop:
  .db CAL,low(_song_stage_space_triangle_0),high(_song_stage_space_triangle_0)
  .db CAL,low(_song_stage_space_triangle_0),high(_song_stage_space_triangle_0)
  .db CAL,low(_song_stage_space_triangle_1),high(_song_stage_space_triangle_1)
  .db CAL,low(_song_stage_space_triangle_1),high(_song_stage_space_triangle_1)
  .db CAL,low(_song_stage_space_triangle_2),high(_song_stage_space_triangle_2)
  .db CAL,low(_song_stage_space_triangle_3),high(_song_stage_space_triangle_3)
  .db CAL,low(_song_stage_space_triangle_2),high(_song_stage_space_triangle_2)
  .db CAL,low(_song_stage_space_triangle_4),high(_song_stage_space_triangle_4)
  .db GOT
  .dw _song_stage_space_triangle_loop

_song_stage_space_noise:
_song_stage_space_noise_loop:
  .db CAL,low(_song_stage_space_noise_0),high(_song_stage_space_noise_0)
  .db CAL,low(_song_stage_space_noise_0),high(_song_stage_space_noise_0)
  .db CAL,low(_song_stage_space_noise_0),high(_song_stage_space_noise_0)
  .db CAL,low(_song_stage_space_noise_0),high(_song_stage_space_noise_0)
  .db CAL,low(_song_stage_space_noise_1),high(_song_stage_space_noise_1)
  .db CAL,low(_song_stage_space_noise_1),high(_song_stage_space_noise_1)
  .db CAL,low(_song_stage_space_noise_1),high(_song_stage_space_noise_1)
  .db CAL,low(_song_stage_space_noise_2),high(_song_stage_space_noise_2)
  .db GOT
  .dw _song_stage_space_noise_loop

_song_stage_space_square2_0:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,FS2,E2,CS2,E2,FS2,SL2,E2,CS2
  .db SL4,E2,E2,FS2,E2,CS2,E2,FS2,GS2,A2
  .db RET

_song_stage_space_square2_1:
  .db STV,7,SAR,2,STP,7,SDU,2,SL4,E3,FS3,E3,CS3,E3,FS3,SL2,E3,CS3
  .db SL4,E3,E3,FS3,E3,CS3,E3,FS3,GS3,A3
  .db RET

_song_stage_space_square2_2:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,SLC,E2,SL4,E2,SLC,E2,SL4
  .db E2,SLC,E2,SL4,E2,FS2,GS2,A2
  .db RET

_song_stage_space_square2_3:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,SLC,E2,SL4,E2,SLC,E2,SL4
  .db E2,SLC,E2,STV,7,SAR,2,SL4,E3,CS3,B2,A2
  .db RET

_song_stage_space_square2_4:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,SLC,E2,SL4,E2,SLC,E2,SL4
  .db E2,SLL,28,E2
  .db RET

_song_stage_space_triangle_0:
  .db STV,14,SAR,3,STP,7,SDU,2,SLL,64,A0
  .db RET

_song_stage_space_triangle_1:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,FS2,E2,CS2,E2,FS2,SL2,E2,CS2
  .db SL4,E2,E2,FS2,E2,CS2,E2,FS2,GS2,A2
  .db RET

_song_stage_space_triangle_2:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,SLC,E2,SL4,E2,SLC,E2,SL4
  .db E2,SLC,E2,SL4,E2,FS2,GS2,A2
  .db RET

_song_stage_space_triangle_3:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,SLC,E2,SL4,E2,SLC,E2,SL4
  .db E2,SLC,E2,SL4,E3,CS3,B2,A2
  .db RET

_song_stage_space_triangle_4:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E2,SLC,E2,SL4,E2,SLC,E2,SL4
  .db E2,SLL,28,E2
  .db RET

_song_stage_space_noise_0:
  .db STV,9,SAR,3,STP,7,SDU,2,SL2,11,11,STV,11,7,7,STV,9,SL8,11
  .db SL2,11,11,STV,11,7,7,STV,9,SL8,11,SL2,11,11,STV,11,7,7,STV,9
  .db SL8,11,SL2,11,11,STV,11,7,7,STV,9,11,11,STV,11,7,7
  .db RET

_song_stage_space_noise_1:
  .db STV,11,SAR,3,STP,7,SDU,2,SL2,7,SL6,7,STV,10,STP,4,SL8,13
  .db STV,11,STP,7,SL2,7,SL6,7,STV,10,STP,4,SL8,13,STV,11,STP,7
  .db SL2,7,SL6,7,STV,10,STP,4,SL8,13,STV,11,STP,7,SL2,7,SL6,7,SL2
  .db 7,SL6,7
  .db RET

_song_stage_space_noise_2:
  .db STV,11,SAR,3,STP,7,SDU,2,SL2,7,SL6,7,STV,10,STP,4,SL8,13
  .db STV,11,STP,7,SL2,7,SL6,7,STV,10,STP,4,SL8,13,STV,11,STP,7
  .db SL2,7,SL6,7,STV,10,STP,4,SL8,13,STV,11,STP,7,SL2,7,SAR,1
  .db 11,SAR,3,7,SAR,1,11,SAR,3,7,SAR,1,11,SAR,3,7,SAR,1,11
  .db RET

_song_stage_caves:
  .db 0
  .db 6
  .db 0
  .db 5
  .dw 0
  .dw _song_stage_caves_square2
  .dw _song_stage_caves_triangle
  .dw _song_stage_caves_noise
  .dw 0

_song_stage_caves_square2:
_song_stage_caves_square2_loop:
  .db CAL,low(_song_stage_caves_square2_0),high(_song_stage_caves_square2_0)
  .db CAL,low(_song_stage_caves_square2_0),high(_song_stage_caves_square2_0)
  .db CAL,low(_song_stage_caves_square2_1),high(_song_stage_caves_square2_1)
  .db CAL,low(_song_stage_caves_square2_1),high(_song_stage_caves_square2_1)
  .db CAL,low(_song_stage_caves_square2_1),high(_song_stage_caves_square2_1)
  .db CAL,low(_song_stage_caves_square2_2),high(_song_stage_caves_square2_2)
  .db GOT
  .dw _song_stage_caves_square2_loop

_song_stage_caves_triangle:
_song_stage_caves_triangle_loop:
  .db CAL,low(_song_stage_caves_triangle_0),high(_song_stage_caves_triangle_0)
  .db CAL,low(_song_stage_caves_triangle_0),high(_song_stage_caves_triangle_0)
  .db CAL,low(_song_stage_caves_triangle_1),high(_song_stage_caves_triangle_1)
  .db CAL,low(_song_stage_caves_triangle_1),high(_song_stage_caves_triangle_1)
  .db CAL,low(_song_stage_caves_triangle_1),high(_song_stage_caves_triangle_1)
  .db CAL,low(_song_stage_caves_triangle_2),high(_song_stage_caves_triangle_2)
  .db GOT
  .dw _song_stage_caves_triangle_loop

_song_stage_caves_noise:
_song_stage_caves_noise_loop:
  .db CAL,low(_song_stage_caves_noise_0),high(_song_stage_caves_noise_0)
  .db CAL,low(_song_stage_caves_noise_0),high(_song_stage_caves_noise_0)
  .db CAL,low(_song_stage_caves_noise_0),high(_song_stage_caves_noise_0)
  .db CAL,low(_song_stage_caves_noise_0),high(_song_stage_caves_noise_0)
  .db CAL,low(_song_stage_caves_noise_1),high(_song_stage_caves_noise_1)
  .db CAL,low(_song_stage_caves_noise_2),high(_song_stage_caves_noise_2)
  .db GOT
  .dw _song_stage_caves_noise_loop

_song_stage_caves_square2_0:
  .db STV,8,SAR,3,STP,7,SDU,2,SL6,G1,SL2,B1,SL4,C2,B1,SL6,G1,SL2
  .db B1,SL4,C2,B1,SL6,G1,SL2,B1,SL4,C2,B1,G1,A1,B1,C2
  .db RET

_song_stage_caves_square2_1:
  .db STV,8,SAR,3,STP,7,SDU,2,SL6,G1,SL2,B1,SL4,C2,B1,SL6,G1,SL2
  .db B1,SL4,C2,B1,SL6,G1,SL2,B1,SL4,C2,B1,SL2,G1,G2,A1,A2,B1,B2
  .db C2,C3
  .db RET

_song_stage_caves_square2_2:
  .db STV,8,SAR,3,STP,7,SDU,2,SL6,G1,SL2,B1,SL4,C2,B1,SL6,G1,SL2
  .db B1,SL4,C2,B1,SL6,G1,SL2,B1,SL4,C2,B1,G3,E3,D3,C3
  .db RET

_song_stage_caves_triangle_0:
  .db STV,14,SAR,3,STP,7,SDU,2,SLL,64,A0
  .db RET

_song_stage_caves_triangle_1:
  .db STV,8,SAR,3,STP,7,SDU,2,SL6,G1,SL2,B1,SL4,C2,B1,SL6,G1,SL2
  .db B1,SL4,C2,B1,SL6,G1,SL2,B1,SL4,C2,B1,SL2,G1,G2,A1,A2,B1,B2
  .db C2,C3
  .db RET

_song_stage_caves_triangle_2:
  .db STV,8,SAR,3,STP,7,SDU,2,SL6,G1,SL2,B1,SL4,C2,B1,SL6,G1,SL2
  .db B1,SL4,C2,B1,SL6,G1,SL2,B1,SL4,C2,B1,G3,E3,D3,C3
  .db RET

_song_stage_caves_noise_0:
  .db STV,11,SAR,3,STP,7,SDU,2,SL4,1,STV,9,14,STV,11,SAR,1,7,STV,9
  .db SAR,3,14,STV,11,1,1,SAR,1,7,STV,9,SAR,3,14,STV,11,1,STV,9
  .db 14,STV,11,SAR,1,7,STV,9,SAR,3,14,STV,11,1,1,SAR,1,7,STV,9
  .db SAR,3,14
  .db RET

_song_stage_caves_noise_1:
  .db STV,11,SAR,3,STP,7,SDU,2,SL2,1,STV,9,14,14,14,STV,11
  .db SAR,1,7,STV,9,SAR,3,14,14,14,STV,11,1,STV,9,14,STV,11
  .db 1,STV,9,14,STV,11,SAR,1,7,STV,9,SAR,3,14,14,14,STV,11
  .db 1,STV,9,14,14,14,STV,11,SAR,1,7,STV,9,SAR,3,14,14,14,STV,11
  .db 1,STV,9,14,STV,11,1,STV,9,14,STV,11,SAR,1,7,STV,9,SAR,3
  .db 14,14,14
  .db RET

_song_stage_caves_noise_2:
  .db STV,11,SAR,3,STP,7,SDU,2,SL2,1,STV,9,14,14,14,STV,11
  .db SAR,1,7,STV,9,SAR,3,14,14,14,STV,11,1,STV,9,14,STV,11
  .db 1,STV,9,14,STV,11,SAR,1,7,STV,9,SAR,3,14,14,14,STV,11
  .db 1,STV,9,14,14,14,STV,11,SAR,1,7,STV,9,SAR,3,14,14,14,STV,11
  .db SAR,1,8,SL4,8,SAR,3,2,SL2,2,SAR,1,8,8
  .db RET

_song_stage_skulls:
  .db 160
  .db 5
  .db 176
  .db 4
  .dw 0
  .dw _song_stage_skulls_square2
  .dw 0
  .dw _song_stage_skulls_noise
  .dw 0

_song_stage_skulls_square2:
_song_stage_skulls_square2_loop:
  .db CAL,low(_song_stage_skulls_square2_0),high(_song_stage_skulls_square2_0)
  .db GOT
  .dw _song_stage_skulls_square2_loop

_song_stage_skulls_noise:
_song_stage_skulls_noise_loop:
  .db CAL,low(_song_stage_skulls_noise_0),high(_song_stage_skulls_noise_0)
  .db GOT
  .dw _song_stage_skulls_noise_loop

_song_stage_skulls_square2_0:
  .db STV,8,SAR,3,STP,7,SDU,2,SL4,E1,E1,E1,E1,E1,E1,E1,SL2,E1,G1
  .db SL4,A1,A1,A1,A1,A1,A1,A1,G1
  .db RET

_song_stage_skulls_noise_0:
  .db STV,9,SAR,3,STP,7,SDU,2,SL2,14,14,14,14,14,14,14,14,14,14
  .db 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
  .db 14,14,14
  .db RET

_song_congrats:
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
  .db SLL,15,STV,0,SAR,3,STP,0,SDU,2,E3
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
  .db SLL,4,STV,1,SAR,3,STP,7,SDU,2,B3
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
  .db STV,0,SAR,3,STP,0,SDU,2,SLL,6,D4,C4,SLL,1,STV,2,STP,7
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
  .db STV,1,SAR,3,STP,7,SDU,2,SLL,6,F4,FS4,SLL,4,G4
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
  .db SLL,9,STV,3,SAR,0,STP,7,SDU,2,G1
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
  .db SLL,15,STV,0,SAR,3,STP,1,SDU,2,C4
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
  .db SLL,12,STV,4,SAR,3,STP,2,SDU,2,C6
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
  .db SLL,12,STV,4,SAR,3,STP,2,SDU,2,0
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
  .db SLL,12,STV,4,SAR,3,STP,2,SDU,2,C4
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
  .db SLL,12,STV,4,SAR,3,STP,3,SDU,2,4
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
  .db SLL,24,STV,5,SAR,3,STP,7,SDU,2,7
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
  .db SLL,24,STV,6,SAR,3,STP,3,SDU,2,7
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
  .db SLL,24,STV,6,SAR,3,STP,7,SDU,0,6
  .db RET
