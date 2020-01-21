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
; "Stage select"
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
; "Part"
STR_18 = 36
  .byte LOW(string18), HIGH(string18)

; 19
; "1"
STR_19 = 38
  .byte LOW(string19), HIGH(string19)

; 20
; "2"
STR_20 = 40
  .byte LOW(string20), HIGH(string20)

; 21
; "3"
STR_21 = 42
  .byte LOW(string21), HIGH(string21)

; 22
; "4"
STR_22 = 44
  .byte LOW(string22), HIGH(string22)

; 23
; "5"
STR_23 = 46
  .byte LOW(string23), HIGH(string23)

; 24
; "6"
STR_24 = 48
  .byte LOW(string24), HIGH(string24)

; 25
; "7"
STR_25 = 50
  .byte LOW(string25), HIGH(string25)

; 26
; "8"
STR_26 = 52
  .byte LOW(string26), HIGH(string26)

; 27
; "9"
STR_27 = 54
  .byte LOW(string27), HIGH(string27)

; 28
; placeholder
  .byte $00, $00

; 29
; placeholder
  .byte $00, $00

; 30
; "This is some string, for the"
STR_30 = 60
  .byte LOW(string30), HIGH(string30)

; 31
; "first story screen."
STR_31 = 62
  .byte LOW(string31), HIGH(string31)

; 32
; "It will be displayed on"
STR_32 = 64
  .byte LOW(string32), HIGH(string32)

; 33
; "the story screen right after"
STR_33 = 66
  .byte LOW(string33), HIGH(string33)

; 34
; "the title screen."
STR_34 = 68
  .byte LOW(string34), HIGH(string34)

; 35
; "Cool, isn't it?"
STR_35 = 70
  .byte LOW(string35), HIGH(string35)

; 36
; placeholder
  .byte $00, $00

; 37
; placeholder
  .byte $00, $00

; 38
; placeholder
  .byte $00, $00

; 39
; placeholder
  .byte $00, $00

; 40
; "Yet another string, this time"
STR_40 = 80
  .byte LOW(string40), HIGH(string40)

; 41
; "it will be displayed on the"
STR_41 = 82
  .byte LOW(string41), HIGH(string41)

; 42
; "second story screen which will"
STR_42 = 84
  .byte LOW(string42), HIGH(string42)

; 43
; "be shown right after the first"
STR_43 = 86
  .byte LOW(string43), HIGH(string43)

; 44
; "one in this little test."
STR_44 = 88
  .byte LOW(string44), HIGH(string44)


Strings:
string0:
  .byte $0B, $1A, $1C, $0F, $1D, $1D, $00, $1D, $1E, $0B, $1C, $1E
string1:
  .byte $0A, $1D, $1E, $0B, $1C, $1E, $00, $11, $0B, $17, $0F
string2:
  .byte $0C, $1D, $1E, $0B, $11, $0F, $00, $1D, $0F, $16, $0F, $0D, $1E
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
  .byte $04, $1A, $0B, $1C, $1E
string19:
  .byte $01, $02
string20:
  .byte $01, $03
string21:
  .byte $01, $04
string22:
  .byte $01, $05
string23:
  .byte $01, $06
string24:
  .byte $01, $07
string25:
  .byte $01, $08
string26:
  .byte $01, $09
string27:
  .byte $01, $0A
string30:
  .byte $1C, $1E, $12, $13, $1D, $00, $13, $1D, $00, $1D, $19, $17, $0F, $00, $1D, $1E, $1C, $13, $18, $11, $2A, $00, $10, $19, $1C, $00, $1E, $12, $0F
string31:
  .byte $13, $10, $13, $1C, $1D, $1E, $00, $1D, $1E, $19, $1C, $23, $00, $1D, $0D, $1C, $0F, $0F, $18, $2B
string32:
  .byte $17, $13, $1E, $00, $21, $13, $16, $16, $00, $0C, $0F, $00, $0E, $13, $1D, $1A, $16, $0B, $23, $0F, $0E, $00, $19, $18
string33:
  .byte $1C, $1E, $12, $0F, $00, $1D, $1E, $19, $1C, $23, $00, $1D, $0D, $1C, $0F, $0F, $18, $00, $1C, $13, $11, $12, $1E, $00, $0B, $10, $1E, $0F, $1C
string34:
  .byte $11, $1E, $12, $0F, $00, $1E, $13, $1E, $16, $0F, $00, $1D, $0D, $1C, $0F, $0F, $18, $2B
string35:
  .byte $0F, $0D, $19, $19, $16, $2A, $00, $13, $1D, $18, $28, $1E, $00, $13, $1E, $26
string40:
  .byte $1D, $23, $0F, $1E, $00, $0B, $18, $19, $1E, $12, $0F, $1C, $00, $1D, $1E, $1C, $13, $18, $11, $2A, $00, $1E, $12, $13, $1D, $00, $1E, $13, $17, $0F
string41:
  .byte $1B, $13, $1E, $00, $21, $13, $16, $16, $00, $0C, $0F, $00, $0E, $13, $1D, $1A, $16, $0B, $23, $0F, $0E, $00, $19, $18, $00, $1E, $12, $0F
string42:
  .byte $1E, $1D, $0F, $0D, $19, $18, $0E, $00, $1D, $1E, $19, $1C, $23, $00, $1D, $0D, $1C, $0F, $0F, $18, $00, $21, $12, $13, $0D, $12, $00, $21, $13, $16, $16
string43:
  .byte $1E, $0C, $0F, $00, $1D, $12, $19, $21, $18, $00, $1C, $13, $11, $12, $1E, $00, $0B, $10, $1E, $0F, $1C, $00, $1E, $12, $0F, $00, $10, $13, $1C, $1D, $1E
string44:
  .byte $18, $19, $18, $0F, $00, $13, $18, $00, $1E, $12, $13, $1D, $00, $16, $13, $1E, $1E, $16, $0F, $00, $1E, $0F, $1D, $1E, $2B


CURSOR_TILE = $94


LogoAndTextDataEnd:
