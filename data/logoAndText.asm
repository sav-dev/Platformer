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
  .byte $2A, $2B, $2C, $2D, $2C, $2E, $2C, $2C, $2F, $30, $31, $2C, $2C, $32, $2C, $2C, $2C, $2C, $2C, $2C, $33, $2C, $34, $35
  .byte $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $3A, $41, $42, $43, $44, $2C, $45, $46, $47, $48, $3A, $49, $4A
  .byte $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $4F, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $4F, $5F, $4B
  .byte $4B, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $63, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $63, $73, $4B
  .byte $74, $49, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $77, $7E, $7F, $80, $81, $82, $83, $84, $85, $86, $77, $37, $87
  .byte $88, $89, $82, $8A, $82, $8B, $82, $82, $8C, $8D, $8E, $82, $82, $8F, $82, $82, $82, $82, $82, $82, $82, $82, $90, $91

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


CURSOR_TILE = $92


LogoAndTextDataEnd:
