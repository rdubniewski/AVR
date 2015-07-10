#ifndef _OWIRE_ASM_
#define _OWIRE_ASM_

.include "OWire.inc"
;.include "Wait.inc"

.cseg

;----------------------------------------------------------------------------
; Oblicza CRC z aktualnego R_OWIRE_CRC i R_OWIRE_DATA
; Wynik jest zapisywany w R_OWIRE_CRC
OWIRE_COMPUTE_CRC:
	push R_LOOP
	push R_OWIRE_DATA
	push R_TMP_1

	ldi R_LOOP, 8
_OCC_LOOP:

	mov R_TMP_1, R_OWIRE_CRC
	eor R_TMP_1, R_OWIRE_DATA
	andi R_TMP_1, 1
	brne _OCC_LOOP_NO_ZERO

_OCC_LOOP_ZERO:
	lsr R_OWIRE_CRC
	rjmp _OCC_LOOP_COMMON

_OCC_LOOP_NO_ZERO:
	ldi R_TMP_1, 0x18
	eor R_OWIRE_CRC, R_TMP_1
	lsr R_OWIRE_CRC
    ldi R_TMP_1, 0x80
	or R_OWIRE_CRC, R_TMP_1

_OCC_LOOP_COMMON:
	lsr R_OWIRE_DATA

	dec R_LOOP
	brne _OCC_LOOP

	pop R_TMP_1
	pop R_OWIRE_DATA
	pop R_LOOP
	
	ret
;----------------------------------------------------------------------------
/*
OWIRE_WAIT_9_MS:
	WAIT_MICROSEC_MINUS_TICKS 9, 7
;    rjmp _OW9M_1
;_OW9M_1:
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_10_MS:
	WAIT_MICROSEC_MINUS_TICKS 10, 7
;    nop
;	rjmp _OW10M_1
;_OW10M_1:
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_55_MS:
    WAIT_MICROSEC_MINUS_TICKS 55, 7
;	push r16
;	ldi r16, 14
;	rjmp _OW55M_LOOP
;_OW55M_LOOP:
;	dec r16
;	brne _OW55M_LOOP
;	pop r16
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_60_MS:
    WAIT_MICROSEC_MINUS_TICKS 60, 7
;	push r16
;	ldi r16, 16
;_OW60M_LOOP:
;	dec r16
;	brne _OW60M_LOOP
;	nop
;	pop r16
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_64_MS:
    WAIT_MICROSEC_MINUS_TICKS 64, 7
;	push r16
;	ldi r16, 17
;	rjmp _OW64M_LOOP
;_OW64M_LOOP:
;	dec r16
;	brne _OW64M_LOOP
;	pop r16
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_70_MS:
    WAIT_MICROSEC_MINUS_TICKS 70, 7
;	push r16
;	ldi r16, 19
;	rjmp _OW70M_LOOP
;_OW70M_LOOP:
;	dec r16
;	brne _OW70M_LOOP
;	pop r16
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_410_MS:
    WAIT_MICROSEC_MINUS_TICKS 410, 7
;	push r16
;	ldi r16, 133
;_OW410M_LOOP:
;	dec r16
;	brne _OW410M_LOOP
;	pop r16
	ret
;----------------------------------------------------------------------------
OWIRE_WAIT_480_MS:
    WAIT_MICROSEC_MINUS_TICKS 480, 7
;	push r16
;	ldi r16, 156
;_OW480M_LOOP:
;	dec r16
;	brne _OW480M_LOOP
;	nop
;	pop r16
	ret
;----------------------------------------------------------------------------
*/
;.include    "Wait.asm"

#endif
