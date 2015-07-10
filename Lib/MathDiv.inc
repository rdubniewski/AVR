/****************************************************************************
File:				Wait.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.01
Modified:			2013.02.01
****************************************************************************/

#ifndef _MATH_DIV_INC_
#define _MATH_DIV_INC_


; Argumenty dzielenia
/*
.def    R_DIV_DIVIDEND_0				= r16
.def    R_DIV_DIVIDEND_1				= r17
.def    R_DIV_DIVIDEND_2				= r18
.def    R_DIV_DIVIDEND_3				= r19

.def    R_DIV_DIVISOR_0					= r20
.def    R_DIV_DIVISOR_1					= r21
.def    R_DIV_DIVISOR_2					= r22
.def    R_DIV_DIVISOR_3					= r23

.def    R_DIV_RESULT_0					= r16
.def    R_DIV_RESULT_1					= r17
.def    R_DIV_RESULT_2					= r18
.def    R_DIV_RESULT_3					= r19

.def    R_DIV_REMAINDER_0				= r0
.def    R_DIV_REMAINDER_1				= r1
.def    R_DIV_REMAINDER_2				= r2
.def    R_DIV_REMAINDER_3				= r3
*/

; przypisanie rejestrow wyniku, tych samych rejestrow co dzielnej
.ifdef  R_DIV_DIVIDEND_0
    #define     R_DIV_RESULT_0  R_DIV_DIVIDEND_0
.endif

.ifdef  R_DIV_DIVIDEND_1
    #define     R_DIV_RESULT_1  R_DIV_DIVIDEND_1
.endif
.ifdef  R_DIV_DIVIDEND_2
    #define     R_DIV_RESULT_2  R_DIV_DIVIDEND_2
.endif
.ifdef  R_DIV_DIVIDEND_3
    #define     R_DIV_RESULT_3  R_DIV_DIVIDEND_3
.endif


.macro DIV_U8
	.set  USE_DIV_U8_F = 1
	rcall DIV_U8_F
.endmacro

.macro DIV_U16
	.set  USE_DIV_U16_F = 1
	rcall DIV_U16_F
.endmacro

.macro DIV_U24
	.set  USE_DIV_U24_F = 1
	rcall DIV_U24_F
.endmacro

.macro DIV_U24_U8
	.set  USE_DIV_U24_U8_F = 1
	rcall DIV_U24_U8_F
.endmacro

.macro DIV_U32
	.set  USE_DIV_U32_F = 1
	rcall DIV_U32_F
.endmacro

.macro LDI_DIV_16
	ldi @1, @2 & 0xFF
	ldi @0, (@2 >> 8 ) & 0xFF	
.endmacro

.macro LDI_DIV_24
	ldi @2, @3 & 0xFF
	ldi @1, (@3 >> 8 ) & 0xFF
	ldi @0, (@3 >> 16 ) & 0xFF
.endmacro

.macro LDI_DIV_32
	ldi @3, @4 & 0xFF
	ldi @2, (@4 >> 8 ) & 0xFF
	ldi @1, (@4 >> 16 ) & 0xFF
	ldi @0, (@4 >> 24 ) & 0xFF
.endmacro


#endif
