LogoAndTextDataStart:

;****************************************************************
; LogoAndTextData                                               ;
; Holds info for rendering the logo and text (auto-generated)   ;
;****************************************************************

;****************************************************************
; Logo                                                          ;
;****************************************************************

LOGO_X = $04
LOGO_Y = $05
INITIAL_LOGO_ADDR_L = $A4
INITIAL_LOGO_ADDR_H = $20
LOGO_ROW_LENGTH = $18
LOGO_ROWS = $06
Logo:
  .byte $2C, $2D, $2E, $2F, $2E, $30, $2E, $2E, $31, $32, $33, $2E, $2E, $34, $2E, $2E, $2E, $2E, $2E, $2E, $35, $2E, $36, $37
  .byte $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42, $3C, $43, $44, $45, $46, $2E, $47, $48, $49, $4A, $3C, $4B, $4C
  .byte $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $51, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60, $51, $61, $4D
  .byte $4D, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $65, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $65, $75, $4D
  .byte $76, $4B, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F, $79, $80, $81, $82, $83, $84, $85, $86, $87, $88, $79, $39, $89
  .byte $8A, $8B, $84, $8C, $84, $8D, $84, $84, $8E, $8F, $90, $84, $84, $91, $84, $84, $84, $84, $84, $84, $84, $84, $92, $93

;****************************************************************
; Strings                                                       ;
;****************************************************************

StringPointers:
; 0
; "Press start"
STR_0 = 0
  .byte LOW(string0), HIGH(string0)

; 1
; "Start game"
STR_1 = 2
  .byte LOW(string1), HIGH(string1)

; 2
; "Password"
STR_2 = 4
  .byte LOW(string2), HIGH(string2)

; 3
; "Credits"
STR_3 = 6
  .byte LOW(string3), HIGH(string3)

; 4
; "Sav 2020"
STR_4 = 8
  .byte LOW(string4), HIGH(string4)

; 5
; "Programming  : Sav"
STR_5 = 10
  .byte LOW(string5), HIGH(string5)

; 6
; "SFX, music   : Sav"
STR_6 = 12
  .byte LOW(string6), HIGH(string6)

; 7
; "Sound engine : Gradual Games"
STR_7 = 14
  .byte LOW(string7), HIGH(string7)

; 8
; "Graphics from opengameart.com"
STR_8 = 16
  .byte LOW(string8), HIGH(string8)

; 9
; "by the following users:"
STR_9 = 18
  .byte LOW(string9), HIGH(string9)

; 10
; "Surt"
STR_10 = 20
  .byte LOW(string10), HIGH(string10)

; 11
; "Master484"
STR_11 = 22
  .byte LOW(string11), HIGH(string11)

; 12
; "Redshrike"
STR_12 = 24
  .byte LOW(string12), HIGH(string12)

; 13
; "chipmunk"
STR_13 = 26
  .byte LOW(string13), HIGH(string13)

; 14
; "Daniel Cook"
STR_14 = 28
  .byte LOW(string14), HIGH(string14)

; 15
; "Monster Logix Studio"
STR_15 = 30
  .byte LOW(string15), HIGH(string15)

; 16
; "Credits"
STR_16 = 32
  .byte LOW(string16), HIGH(string16)

; 17
; "Stage"
STR_17 = 34
  .byte LOW(string17), HIGH(string17)

; 18
; "Level"
STR_18 = 36
  .byte LOW(string18), HIGH(string18)

; 19
; "Select"
STR_19 = 38
  .byte LOW(string19), HIGH(string19)

; 20
; ": 1 8 4 3"
STR_20 = 40
  .byte LOW(string20), HIGH(string20)

; 21
; ": 8 6 2 4"
STR_21 = 42
  .byte LOW(string21), HIGH(string21)

; 22
; ": 0 3 5 6"
STR_22 = 44
  .byte LOW(string22), HIGH(string22)

; 23
; ": 8 2 4 4"
STR_23 = 46
  .byte LOW(string23), HIGH(string23)

; 24
; ": 9 0 1 4"
STR_24 = 48
  .byte LOW(string24), HIGH(string24)

; 25
; "When patrolling remote"
STR_25 = 50
  .byte LOW(string25), HIGH(string25)

; 26
; "sectors of the galaxy,"
STR_26 = 52
  .byte LOW(string26), HIGH(string26)

; 27
; "you notice something weird"
STR_27 = 54
  .byte LOW(string27), HIGH(string27)

; 28
; "about one of the planets"
STR_28 = 56
  .byte LOW(string28), HIGH(string28)

; 29
; "below. It's supposed"
STR_29 = 58
  .byte LOW(string29), HIGH(string29)

; 30
; "to be uninhabited, but there"
STR_30 = 60
  .byte LOW(string30), HIGH(string30)

; 31
; "are clear life signals."
STR_31 = 62
  .byte LOW(string31), HIGH(string31)

; 32
; "You decide to land and"
STR_32 = 64
  .byte LOW(string32), HIGH(string32)

; 33
; "investigate."
STR_33 = 66
  .byte LOW(string33), HIGH(string33)

; 34
; "After making it through the"
STR_34 = 68
  .byte LOW(string34), HIGH(string34)

; 35
; "enemy encampments, you get"
STR_35 = 70
  .byte LOW(string35), HIGH(string35)

; 36
; "to a large structure high"
STR_36 = 72
  .byte LOW(string36), HIGH(string36)

; 37
; "in the mountains. Inside you"
STR_37 = 74
  .byte LOW(string37), HIGH(string37)

; 38
; "see  a large well leading"
STR_38 = 76
  .byte LOW(string38), HIGH(string38)

; 39
; "deep  below the surface."
STR_39 = 78
  .byte LOW(string39), HIGH(string39)

; 40
; "You enter the cave formations,"
STR_40 = 80
  .byte LOW(string40), HIGH(string40)

; 41
; "hoping to find out what's"
STR_41 = 82
  .byte LOW(string41), HIGH(string41)

; 42
; "going on on this planet."
STR_42 = 84
  .byte LOW(string42), HIGH(string42)

; 43
; placeholder
  .byte $00, $00

; 44
; placeholder
  .byte $00, $00

; 45
; placeholder
  .byte $00, $00

; 46
; placeholder
  .byte $00, $00

; 47
; placeholder
  .byte $00, $00

; 48
; placeholder
  .byte $00, $00

; 49
; placeholder
  .byte $00, $00

; 50
; "Excepteur sint occaecat"
STR_50 = 100
  .byte LOW(string50), HIGH(string50)

; 51
; "cupidatat non proident,"
STR_51 = 102
  .byte LOW(string51), HIGH(string51)

; 52
; "sunt in culpa qui officia"
STR_52 = 104
  .byte LOW(string52), HIGH(string52)

; 53
; "deserunt mollit anim id est."
STR_53 = 106
  .byte LOW(string53), HIGH(string53)

; 54
; placeholder
  .byte $00, $00

; 55
; placeholder
  .byte $00, $00

; 56
; placeholder
  .byte $00, $00

; 57
; placeholder
  .byte $00, $00

; 58
; placeholder
  .byte $00, $00

; 59
; placeholder
  .byte $00, $00

; 60
; "Curabitur pretium tincidunt."
STR_60 = 120
  .byte LOW(string60), HIGH(string60)

; 61
; "Nulla gravida orci a odio, "
STR_61 = 122
  .byte LOW(string61), HIGH(string61)

; 62
; "nullam varius, turpis et "
STR_62 = 124
  .byte LOW(string62), HIGH(string62)

; 63
; "commodo pharetra, est eros"
STR_63 = 126
  .byte LOW(string63), HIGH(string63)

; 64
; "bibendum elit, nec luctus "
STR_64 = 128
  .byte LOW(string64), HIGH(string64)

; 65
; "magna felis sollici mauris."
STR_65 = 130
  .byte LOW(string65), HIGH(string65)

; 66
; placeholder
  .byte $00, $00

; 67
; placeholder
  .byte $00, $00

; 68
; placeholder
  .byte $00, $00

; 69
; placeholder
  .byte $00, $00

; 70
; "Integer in mauris eu nibh"
STR_70 = 140
  .byte LOW(string70), HIGH(string70)

; 71
; "euismod gravida. Duis ac"
STR_71 = 142
  .byte LOW(string71), HIGH(string71)

; 72
; "tellus et risus vulputate"
STR_72 = 144
  .byte LOW(string72), HIGH(string72)

; 73
; "vehicula. "
STR_73 = 146
  .byte LOW(string73), HIGH(string73)

; 74
; "Donec lobortis risus a elit."
STR_74 = 148
  .byte LOW(string74), HIGH(string74)

; 75
; placeholder
  .byte $00, $00

; 76
; placeholder
  .byte $00, $00

; 77
; placeholder
  .byte $00, $00

; 78
; placeholder
  .byte $00, $00

; 79
; placeholder
  .byte $00, $00

; 80
; "Etiam tempor! "
STR_80 = 160
  .byte LOW(string80), HIGH(string80)

; 81
; "Ut ullamcorper, ligula eu"
STR_81 = 162
  .byte LOW(string81), HIGH(string81)

; 82
; "tempor congue, eros est"
STR_82 = 164
  .byte LOW(string82), HIGH(string82)

; 83
; "euismod turpis, id tincidunt"
STR_83 = 166
  .byte LOW(string83), HIGH(string83)

; 84
; "sapien risus a quam. "
STR_84 = 168
  .byte LOW(string84), HIGH(string84)

; 85
; "Maecenas fermentum consequat. "
STR_85 = 170
  .byte LOW(string85), HIGH(string85)

; 86
; "Donec fermentum, pellentesque"
STR_86 = 172
  .byte LOW(string86), HIGH(string86)

; 87
; "malesuada nulla a mi."
STR_87 = 174
  .byte LOW(string87), HIGH(string87)


Strings:
string0:
  .byte $0B, $1A, $1C, $0F, $1D, $1D, $00, $1D, $1E, $0B, $1C, $1E
string1:
  .byte $0A, $1D, $1E, $0B, $1C, $1E, $00, $11, $0B, $17, $0F
string2:
  .byte $08, $1A, $0B, $1D, $1D, $21, $19, $1C, $0E
string3:
  .byte $07, $0D, $1C, $0F, $0E, $13, $1E, $1D
string4:
  .byte $08, $1D, $0B, $20, $00, $03, $01, $03, $01
string5:
  .byte $12, $1A, $1C, $19, $11, $1C, $0B, $17, $17, $13, $18, $11, $00, $00, $29, $00, $1D, $0B, $20
string6:
  .byte $12, $1D, $10, $22, $2A, $00, $17, $1F, $1D, $13, $0D, $00, $00, $00, $29, $00, $1D, $0B, $20
string7:
  .byte $1C, $1D, $19, $1F, $18, $0E, $00, $0F, $18, $11, $13, $18, $0F, $00, $29, $00, $11, $1C, $0B, $0E, $1F, $0B, $16, $00, $11, $0B, $17, $0F, $1D
string8:
  .byte $1D, $11, $1C, $0B, $1A, $12, $13, $0D, $1D, $00, $10, $1C, $19, $17, $00, $19, $1A, $0F, $18, $11, $0B, $17, $0F, $0B, $1C, $1E, $2B, $0D, $19, $17
string9:
  .byte $17, $0C, $23, $00, $1E, $12, $0F, $00, $10, $19, $16, $16, $19, $21, $13, $18, $11, $00, $1F, $1D, $0F, $1C, $1D, $29
string10:
  .byte $04, $1D, $1F, $1C, $1E
string11:
  .byte $09, $17, $0B, $1D, $1E, $0F, $1C, $05, $09, $05
string12:
  .byte $09, $1C, $0F, $0E, $1D, $12, $1C, $13, $15, $0F
string13:
  .byte $08, $0D, $12, $13, $1A, $17, $1F, $18, $15
string14:
  .byte $0B, $0E, $0B, $18, $13, $0F, $16, $00, $0D, $19, $19, $15
string15:
  .byte $14, $17, $19, $18, $1D, $1E, $0F, $1C, $00, $16, $19, $11, $13, $22, $00, $1D, $1E, $1F, $0E, $13, $19
string16:
  .byte $07, $0D, $1C, $0F, $0E, $13, $1E, $1D
string17:
  .byte $05, $1D, $1E, $0B, $11, $0F
string18:
  .byte $05, $16, $0F, $20, $0F, $16
string19:
  .byte $06, $1D, $0F, $16, $0F, $0D, $1E
string20:
  .byte $09, $29, $00, $02, $00, $09, $00, $05, $00, $04
string21:
  .byte $09, $29, $00, $09, $00, $07, $00, $03, $00, $05
string22:
  .byte $09, $29, $00, $01, $00, $04, $00, $06, $00, $07
string23:
  .byte $09, $29, $00, $09, $00, $03, $00, $05, $00, $05
string24:
  .byte $09, $29, $00, $0A, $00, $01, $00, $02, $00, $05
string25:
  .byte $16, $21, $12, $0F, $18, $00, $1A, $0B, $1E, $1C, $19, $16, $16, $13, $18, $11, $00, $1C, $0F, $17, $19, $1E, $0F
string26:
  .byte $16, $1D, $0F, $0D, $1E, $19, $1C, $1D, $00, $19, $10, $00, $1E, $12, $0F, $00, $11, $0B, $16, $0B, $22, $23, $2A
string27:
  .byte $1A, $23, $19, $1F, $00, $18, $19, $1E, $13, $0D, $0F, $00, $1D, $19, $17, $0F, $1E, $12, $13, $18, $11, $00, $21, $0F, $13, $1C, $0E
string28:
  .byte $18, $0B, $0C, $19, $1F, $1E, $00, $19, $18, $0F, $00, $19, $10, $00, $1E, $12, $0F, $00, $1A, $16, $0B, $18, $0F, $1E, $1D
string29:
  .byte $14, $0C, $0F, $16, $19, $21, $2B, $00, $13, $1E, $28, $1D, $00, $1D, $1F, $1A, $1A, $19, $1D, $0F, $0E
string30:
  .byte $1C, $1E, $19, $00, $0C, $0F, $00, $1F, $18, $13, $18, $12, $0B, $0C, $13, $1E, $0F, $0E, $2A, $00, $0C, $1F, $1E, $00, $1E, $12, $0F, $1C, $0F
string31:
  .byte $17, $0B, $1C, $0F, $00, $0D, $16, $0F, $0B, $1C, $00, $16, $13, $10, $0F, $00, $1D, $13, $11, $18, $0B, $16, $1D, $2B
string32:
  .byte $16, $23, $19, $1F, $00, $0E, $0F, $0D, $13, $0E, $0F, $00, $1E, $19, $00, $16, $0B, $18, $0E, $00, $0B, $18, $0E
string33:
  .byte $0C, $13, $18, $20, $0F, $1D, $1E, $13, $11, $0B, $1E, $0F, $2B
string34:
  .byte $1B, $0B, $10, $1E, $0F, $1C, $00, $17, $0B, $15, $13, $18, $11, $00, $13, $1E, $00, $1E, $12, $1C, $19, $1F, $11, $12, $00, $1E, $12, $0F
string35:
  .byte $1A, $0F, $18, $0F, $17, $23, $00, $0F, $18, $0D, $0B, $17, $1A, $17, $0F, $18, $1E, $1D, $2A, $00, $23, $19, $1F, $00, $11, $0F, $1E
string36:
  .byte $19, $1E, $19, $00, $0B, $00, $16, $0B, $1C, $11, $0F, $00, $1D, $1E, $1C, $1F, $0D, $1E, $1F, $1C, $0F, $00, $12, $13, $11, $12
string37:
  .byte $1C, $13, $18, $00, $1E, $12, $0F, $00, $17, $19, $1F, $18, $1E, $0B, $13, $18, $1D, $2B, $00, $13, $18, $1D, $13, $0E, $0F, $00, $23, $19, $1F
string38:
  .byte $19, $1D, $0F, $0F, $00, $00, $0B, $00, $16, $0B, $1C, $11, $0F, $00, $21, $0F, $16, $16, $00, $16, $0F, $0B, $0E, $13, $18, $11
string39:
  .byte $18, $0E, $0F, $0F, $1A, $00, $00, $0C, $0F, $16, $19, $21, $00, $1E, $12, $0F, $00, $1D, $1F, $1C, $10, $0B, $0D, $0F, $2B
string40:
  .byte $1E, $23, $19, $1F, $00, $0F, $18, $1E, $0F, $1C, $00, $1E, $12, $0F, $00, $0D, $0B, $20, $0F, $00, $10, $19, $1C, $17, $0B, $1E, $13, $19, $18, $1D, $2A
string41:
  .byte $19, $12, $19, $1A, $13, $18, $11, $00, $1E, $19, $00, $10, $13, $18, $0E, $00, $19, $1F, $1E, $00, $21, $12, $0B, $1E, $28, $1D
string42:
  .byte $18, $11, $19, $13, $18, $11, $00, $19, $18, $00, $19, $18, $00, $1E, $12, $13, $1D, $00, $1A, $16, $0B, $18, $0F, $1E, $2B
string50:
  .byte $17, $0F, $22, $0D, $0F, $1A, $1E, $0F, $1F, $1C, $00, $1D, $13, $18, $1E, $00, $19, $0D, $0D, $0B, $0F, $0D, $0B, $1E
string51:
  .byte $17, $0D, $1F, $1A, $13, $0E, $0B, $1E, $0B, $1E, $00, $18, $19, $18, $00, $1A, $1C, $19, $13, $0E, $0F, $18, $1E, $2A
string52:
  .byte $19, $1D, $1F, $18, $1E, $00, $13, $18, $00, $0D, $1F, $16, $1A, $0B, $00, $1B, $1F, $13, $00, $19, $10, $10, $13, $0D, $13, $0B
string53:
  .byte $1C, $0E, $0F, $1D, $0F, $1C, $1F, $18, $1E, $00, $17, $19, $16, $16, $13, $1E, $00, $0B, $18, $13, $17, $00, $13, $0E, $00, $0F, $1D, $1E, $2B
string60:
  .byte $1C, $0D, $1F, $1C, $0B, $0C, $13, $1E, $1F, $1C, $00, $1A, $1C, $0F, $1E, $13, $1F, $17, $00, $1E, $13, $18, $0D, $13, $0E, $1F, $18, $1E, $2B
string61:
  .byte $1B, $18, $1F, $16, $16, $0B, $00, $11, $1C, $0B, $20, $13, $0E, $0B, $00, $19, $1C, $0D, $13, $00, $0B, $00, $19, $0E, $13, $19, $2A, $00
string62:
  .byte $19, $18, $1F, $16, $16, $0B, $17, $00, $20, $0B, $1C, $13, $1F, $1D, $2A, $00, $1E, $1F, $1C, $1A, $13, $1D, $00, $0F, $1E, $00
string63:
  .byte $1A, $0D, $19, $17, $17, $19, $0E, $19, $00, $1A, $12, $0B, $1C, $0F, $1E, $1C, $0B, $2A, $00, $0F, $1D, $1E, $00, $0F, $1C, $19, $1D
string64:
  .byte $1A, $0C, $13, $0C, $0F, $18, $0E, $1F, $17, $00, $0F, $16, $13, $1E, $2A, $00, $18, $0F, $0D, $00, $16, $1F, $0D, $1E, $1F, $1D, $00
string65:
  .byte $1B, $17, $0B, $11, $18, $0B, $00, $10, $0F, $16, $13, $1D, $00, $1D, $19, $16, $16, $13, $0D, $13, $00, $17, $0B, $1F, $1C, $13, $1D, $2B
string70:
  .byte $19, $13, $18, $1E, $0F, $11, $0F, $1C, $00, $13, $18, $00, $17, $0B, $1F, $1C, $13, $1D, $00, $0F, $1F, $00, $18, $13, $0C, $12
string71:
  .byte $18, $0F, $1F, $13, $1D, $17, $19, $0E, $00, $11, $1C, $0B, $20, $13, $0E, $0B, $2B, $00, $0E, $1F, $13, $1D, $00, $0B, $0D
string72:
  .byte $19, $1E, $0F, $16, $16, $1F, $1D, $00, $0F, $1E, $00, $1C, $13, $1D, $1F, $1D, $00, $20, $1F, $16, $1A, $1F, $1E, $0B, $1E, $0F
string73:
  .byte $0A, $20, $0F, $12, $13, $0D, $1F, $16, $0B, $2B, $00
string74:
  .byte $1C, $0E, $19, $18, $0F, $0D, $00, $16, $19, $0C, $19, $1C, $1E, $13, $1D, $00, $1C, $13, $1D, $1F, $1D, $00, $0B, $00, $0F, $16, $13, $1E, $2B
string80:
  .byte $0E, $0F, $1E, $13, $0B, $17, $00, $1E, $0F, $17, $1A, $19, $1C, $25, $00
string81:
  .byte $19, $1F, $1E, $00, $1F, $16, $16, $0B, $17, $0D, $19, $1C, $1A, $0F, $1C, $2A, $00, $16, $13, $11, $1F, $16, $0B, $00, $0F, $1F
string82:
  .byte $17, $1E, $0F, $17, $1A, $19, $1C, $00, $0D, $19, $18, $11, $1F, $0F, $2A, $00, $0F, $1C, $19, $1D, $00, $0F, $1D, $1E
string83:
  .byte $1C, $0F, $1F, $13, $1D, $17, $19, $0E, $00, $1E, $1F, $1C, $1A, $13, $1D, $2A, $00, $13, $0E, $00, $1E, $13, $18, $0D, $13, $0E, $1F, $18, $1E
string84:
  .byte $15, $1D, $0B, $1A, $13, $0F, $18, $00, $1C, $13, $1D, $1F, $1D, $00, $0B, $00, $1B, $1F, $0B, $17, $2B, $00
string85:
  .byte $1E, $17, $0B, $0F, $0D, $0F, $18, $0B, $1D, $00, $10, $0F, $1C, $17, $0F, $18, $1E, $1F, $17, $00, $0D, $19, $18, $1D, $0F, $1B, $1F, $0B, $1E, $2B, $00
string86:
  .byte $1D, $0E, $19, $18, $0F, $0D, $00, $10, $0F, $1C, $17, $0F, $18, $1E, $1F, $17, $2A, $00, $1A, $0F, $16, $16, $0F, $18, $1E, $0F, $1D, $1B, $1F, $0F
string87:
  .byte $15, $17, $0B, $16, $0F, $1D, $1F, $0B, $0E, $0B, $00, $18, $1F, $16, $16, $0B, $00, $0B, $00, $17, $13, $2B


CURSOR_TILE = $94


LogoAndTextDataEnd:
