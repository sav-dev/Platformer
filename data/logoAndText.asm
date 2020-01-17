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

; 20
; "This is some string, for the"
STR_20 = 10
  .byte LOW(string20), HIGH(string20)

; 21
; "first story screen."
STR_21 = 12
  .byte LOW(string21), HIGH(string21)

; 22
; "It will be displayed on"
STR_22 = 14
  .byte LOW(string22), HIGH(string22)

; 23
; "the story screen right after"
STR_23 = 16
  .byte LOW(string23), HIGH(string23)

; 24
; "the title screen."
STR_24 = 18
  .byte LOW(string24), HIGH(string24)


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
string20:
  .byte $1C, $1E, $12, $13, $1D, $00, $13, $1D, $00, $1D, $19, $17, $0F, $00, $1D, $1E, $1C, $13, $18, $11, $2A, $00, $10, $19, $1C, $00, $1E, $12, $0F
string21:
  .byte $13, $10, $13, $1C, $1D, $1E, $00, $1D, $1E, $19, $1C, $23, $00, $1D, $0D, $1C, $0F, $0F, $18, $2B
string22:
  .byte $17, $13, $1E, $00, $21, $13, $16, $16, $00, $0C, $0F, $00, $0E, $13, $1D, $1A, $16, $0B, $23, $0F, $0E, $00, $19, $18
string23:
  .byte $1C, $1E, $12, $0F, $00, $1D, $1E, $19, $1C, $23, $00, $1D, $0D, $1C, $0F, $0F, $18, $00, $1C, $13, $11, $12, $1E, $00, $0B, $10, $1E, $0F, $1C
string24:
  .byte $11, $1E, $12, $0F, $00, $1E, $13, $1E, $16, $0F, $00, $1D, $0D, $1C, $0F, $0F, $18, $2B


CURSOR_TILE = $94


LogoAndTextDataEnd:
