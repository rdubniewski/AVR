
#include "Wait.inc"


.macro HD44780_PUT_DATA_BIT
	sbrc R_HD44780_DATA, @0
	sbi @1, @2
	sbrs R_HD44780_DATA, @0
	cbi @1, @2
.endmacro
	
.macro HD44780_GET_DATA_BIT
	cbr R_HD44780_DATA, 1 << @0
	sbic @1, @2
	sbr R_HD44780_DATA, 1 << @0
.endmacro
;----------------------------------------------------------------------------
HD44780_CONFIGURE:
	; poczekanie 15 milisekund po podlaczeniu pradu
	WAIT_MILISEC 15
	
	; ustawienie ddr na wyjscia
	sbi HD44780_4_DDR, HD44780_4_BIT
	sbi HD44780_5_DDR, HD44780_5_BIT
	sbi HD44780_6_DDR, HD44780_6_BIT
	sbi HD44780_7_DDR, HD44780_7_BIT

	; zapis instrukcji
	HD44780_RS_INSTRUCTION
	HD44780_RW_WRITE
	
	; ustawienie adresowania 8 bitow 2 razy z tak by wyswietlacz 
	; przelaczyl sie na 8-bitowy tryb gdyby byl w 4-bitowym
	; 8-bit po raz pierwszy
	ldi	  R_HD44780_DATA, HD44780_FUNCTION_SET | HD44780_FS_8_BIT
	HD44780_E_ON
	rcall HD44780_PUT_DATA
	HD44780_E_OFF
	
	WAIT_MICROSEC 4100

	; 8-bit po raz drugi
	ldi	  R_HD44780_DATA, HD44780_FUNCTION_SET | HD44780_FS_8_BIT
	HD44780_E_ON
	rcall HD44780_PUT_DATA
	HD44780_E_OFF
	
	WAIT_MICROSEC 100

	; teraz jest na pewno w trybie 8 bitowym
	; przelaczenie na 4 bity
	ldi	  R_HD44780_DATA, HD44780_FUNCTION_SET | HD44780_FS_4_BIT
	HD44780_E_ON
	rcall HD44780_PUT_DATA
	HD44780_E_OFF

	ret
;----------------------------------------------------------------------------
HD44780_WRITE_DATA:
	rcall HD44780_WAIT_BUSY
	
	HD44780_RS_DATA
	rcall HD44780_WRITE_BYTE

.ifdef R_HD44780_CURSOR_POS
	inc R_HD44780_CURSOR_POS
.else
    .ifdef HD44780_CURSOR_POS
        .ifdef R_HD44780_TMP
            lds     R_HD44780_TMP, HD44780_CURSOR_POS
            inc     R_HD44780_TMP
            sts     HD44780_CURSOR_POS, R_HD44780_TMP
        .else
            push    R_HD44780_DATA
            lds     R_HD44780_DATA, HD44780_CURSOR_POS
            inc     R_HD44780_DATA
            sts     HD44780_CURSOR_POS, R_HD44780_DATA
            pop     R_HD44780_DATA
        .endif
    .endif
.endif

	ret
;----------------------------------------------------------------------------
.ifdef  USE_HD44780_PRINT_CONST_STRING_Z_FUN

HD44780_PRINT_CONST_STRING_Z_FUN:
	lpm R_HD44780_DATA, Z+
	tst R_HD44780_DATA
	breq _HPCSZF_END
	rcall HD44780_WRITE_DATA
	rjmp HD44780_PRINT_CONST_STRING_Z_FUN
_HPCSZF_END:
	ret

.endif
;----------------------------------------------------------------------------
HD44780_SEND_INSTRUCTION:
	rcall HD44780_WAIT_BUSY

	HD44780_RS_INSTRUCTION
	rcall HD44780_WRITE_BYTE

	ret
;----------------------------------------------------------------------------
HD44780_WRITE_BYTE:
	
	; ustawienie ddr na wyjscia
	sbi HD44780_4_DDR, HD44780_4_BIT
	sbi HD44780_5_DDR, HD44780_5_BIT
	sbi HD44780_6_DDR, HD44780_6_BIT
	sbi HD44780_7_DDR, HD44780_7_BIT

	HD44780_RW_WRITE

	HD44780_E_ON
	rcall HD44780_PUT_DATA
	HD44780_E_OFF
	
	swap R_HD44780_DATA	
	HD44780_E_ON
	rcall HD44780_PUT_DATA
	HD44780_E_OFF
	swap R_HD44780_DATA
	
	ret
;----------------------------------------------------------------------------
HD44780_PUT_DATA:
	HD44780_PUT_DATA_BIT 4, HD44780_4_PORT, HD44780_4_BIT
	HD44780_PUT_DATA_BIT 5, HD44780_5_PORT, HD44780_5_BIT
	HD44780_PUT_DATA_BIT 6, HD44780_6_PORT, HD44780_6_BIT
	HD44780_PUT_DATA_BIT 7, HD44780_7_PORT, HD44780_7_BIT
	ret
;----------------------------------------------------------------------------
HD44780_IS_BUSY:
	HD44780_RS_INSTRUCTION
	rcall HD44780_READ_DATA
	ret
;----------------------------------------------------------------------------
HD44780_WAIT_BUSY:
	push R_HD44780_DATA
	HD44780_RS_INSTRUCTION
_AWB_LOOP:
	rcall HD44780_READ_DATA
	sbrc R_HD44780_DATA, 7
	rjmp _AWB_LOOP
	pop R_HD44780_DATA
	ret
;----------------------------------------------------------------------------
HD44780_READ_DATA:
	HD44780_RW_READ

	; ustawienie portow na wejscie
	cbi HD44780_4_DDR, HD44780_4_BIT
	cbi HD44780_5_DDR, HD44780_5_BIT
	cbi HD44780_6_DDR, HD44780_6_BIT
	cbi HD44780_7_DDR, HD44780_7_BIT
	
	HD44780_RW_READ
	clr R_HD44780_DATA
	
	HD44780_E_ON
	rcall HD44780_GET_DATA
	HD44780_E_OFF
	swap R_HD44780_DATA
		
	HD44780_E_ON
	rcall HD44780_GET_DATA
	HD44780_E_OFF
	swap R_HD44780_DATA
	
	ret
;----------------------------------------------------------------------------
HD44780_GET_DATA:
	HD44780_GET_DATA_BIT 4, HD44780_4_PIN, HD44780_4_BIT
	HD44780_GET_DATA_BIT 5, HD44780_5_PIN, HD44780_5_BIT
	HD44780_GET_DATA_BIT 6, HD44780_6_PIN, HD44780_6_BIT
	HD44780_GET_DATA_BIT 7, HD44780_7_PIN, HD44780_7_BIT
	ret
;----------------------------------------------------------------------------
