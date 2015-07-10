#ifndef _HD44780_INC_
#define _HD44780_INC_

/****************************************************************************
 
               !!!!!!!!!!!!!!     UWAGA     !!!!!!!!!!!!!!

	Biblioteka narazie przygotowana jest tylko dla sterowania 4-bitowego
Nalezy o tym pamietac i podczas wysylania do sterownika
HD44780_FUNCTION_SET nalezy ustawic HD44780_FS_4_BIT 
(niby 0 ale dla jasnosci przegladania kodu w pozniejszym czasie).

	Przed rozpaczêciem komunikacji ze sterownikiem nalezy go zainicjowaæ
wywolujac funkcjê HD44780_CONFIGURE

****************************************************************************/

.equ HD44780_CLEAR					= 0x01

.equ HD44780_HOME					= 0x02

.equ HD44780_ENTRY_MODE				= 0x04
.equ HD44780_EM_SHIFT_CURSOR		= 0
.equ HD44780_EM_SHIFT_DISPLAY		= 1
.equ HD44780_EM_DECREMENT			= 0
.equ HD44780_EM_INCREMENT			= 2

.equ HD44780_DISPLAY				= 0x08
.equ HD44780_D_DISPLAY_OFF			= 0
.equ HD44780_D_DISPLAY_ON			= 4
.equ HD44780_D_CURSOR_OFF			= 0
.equ HD44780_D_CURSOR_ON			= 2
.equ HD44780_D_CURSOR_NOBLINK		= 0
.equ HD44780_D_CURSOR_BLINK			= 1

.equ HD44780_DISPLAY_CURSOR_SHIFT	= 0x10
.equ HD44780_DCS_SHIFT_CURSOR		= 0
.equ HD44780_DCS_SHIFT_DISPLAY		= 8
.equ HD44780_DCS_SHIFT_LEFT			= 0
.equ HD44780_DCS_SHIFT_RIGHT		= 4

.equ HD44780_FUNCTION_SET			= 0x20
.equ HD44780_FS_FONT5x8				= 0
.equ HD44780_FS_FONT5x10			= 4
.equ HD44780_FS_ONE_LINE			= 0
.equ HD44780_FS_TWO_LINES			= 8
.equ HD44780_FS_4_BIT				= 0
.equ HD44780_FS_8_BIT				= 16

.equ HD44780_CGRAM_SET				= 0x40

.equ HD44780_DDRAM_SET				= 0x80

.macro HD44780_RS_INSTRUCTION
	cbi HD44780_RS_PORT, HD44780_RS_BIT
.endmacro

.macro HD44780_RS_DATA
	sbi HD44780_RS_PORT, HD44780_RS_BIT
.endmacro

.macro HD44780_RW_WRITE
	cbi HD44780_RW_PORT, HD44780_RW_BIT
.endmacro

.macro HD44780_RW_READ
	sbi HD44780_RW_PORT, HD44780_RW_BIT
.endmacro

.macro HD44780_E_OFF
	cbi HD44780_E_PORT, HD44780_E_BIT
.endmacro

.macro HD44780_E_ON
	sbi HD44780_E_PORT, HD44780_E_BIT
.endmacro


.macro HD44780_PRINT_CHAR
    ldi     R_HD44780_DATA, @0
	rcall   HD44780_WRITE_DATA	    
.endmacro

.macro HD44780_PRINT_CONST_STRING_Z
.set    USE_HD44780_PRINT_CONST_STRING_Z_FUN = 1
    ldi     ZL, low(@0) * 2
    ldi     ZH, high(@0) * 2
    rcall   HD44780_PRINT_CONST_STRING_Z_FUN
.endmacro

.macro HD44780_STORE_CURSOR_POS
.ifdef R_HD44780_CURSOR_POS
    ldi R_HD44780_CURSOR_POS, @0
.else
    .ifdef  HD44780_CURSOR_POS
        .ifdef  R_HD44780_TMP
            ldi     R_HD44780_TMP, @0
            sts     HD44780_CURSOR_POS, R_HD44780_TMP
        .else
            push    R_HD44780_DATA
            ldi     R_HD44780_DATA, @0
            sts     HD44780_CURSOR_POS, R_HD44780_DATA
            pop     R_HD44780_DATA
        .endif
    .endif
.endif
.endmacro 

; 0: rejestr
; 1: linia
; 2: wiersz
.macro HD44780_16_CALCULATE_POS
	ldi @0, HD44780_DDRAM_SET + (@1 % 2) * 64 +  (@1 / 2) * 16  + @2
.endmacro

.macro HD44780_20_CALCULATE_POS
	ldi @0, HD44780_DDRAM_SET + (@1 % 2) * 64 +  (@1 / 2) * 20  + @2	
.endmacro



; 0: linia
; 1: wiersz
.macro HD44780_16_SET_POS
	HD44780_16_CALCULATE_POS R_HD44780_DATA, @0, @1
	HD44780_STORE_CURSOR_POS @1
	rcall HD44780_SEND_INSTRUCTION
.endmacro

.macro HD44780_20_SET_POS
	HD44780_20_CALCULATE_POS R_HD44780_DATA, @0, @1
	HD44780_STORE_CURSOR_POS @1
	rcall HD44780_SEND_INSTRUCTION
.endmacro


/*
.macro HD44780_40_SET_POS
	ldi @0, HD44780_DDRAM_SET + (@1 % 2) * 64 +  (@1 / 2) * 40  + @2	
.endmacro
*/

#endif
