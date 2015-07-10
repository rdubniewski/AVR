/****************************************************************************
File:				Wait.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.01.07
Modified:			2013.01.07
****************************************************************************/

#ifndef _WAIT_INC_
#define _WAIT_INC_

; Dla uzytku ogolnego przeznaczone sa makra WAIT_MICROSEC i WAIT_MILISEC.
; Reszta makt jest zla u¿ytku wewnêtrznego
;	Wymahane jest zdefiniowanie stalej FREQUENCY (Herce), 
; sluczacej do obliczenia ilosci taktow opoznienia.


.ifndef FREQUENCY
	.error "Brak zdefiniowanej stalej FREQUENCY (czestotliwosc taktowania procesora)"
.endif


.ifndef WAIT_NO_STORE_REGS
	.equ	WAIT_NO_STORE_REGS	= 0
.endif

.if WAIT_NO_STORE_REGS == 0
	; z odkladaniem na stos
	.equ	WAIT_REG_STORE_TICKS	= 4
	
	.macro	WAIT_PUSH_REG
		push	@0
	.endmacro

	.macro	WAIT_POP_REG
		pop	@0
	.endmacro
.else
	; bez odkladania na stos
	.equ	WAIT_REG_STORE_TICKS	= 0
	
	.macro	WAIT_PUSH_REG
	.endmacro

	.macro	WAIT_POP_REG
	.endmacro

.endif


; Dla uzytku wewnetrznego !
; Wstawia skok do nastepnej instrukchu - 2 takty lub nop 1 takt
.macro WAIT_TICKS_MAX_2
.if @0 >= 2
	rjmp _WAIT_TICKS_MAX_2_JMP
_WAIT_TICKS_MAX_2_JMP:
.elif @0 == 1
	nop
.endif
.endmacro 


; Dla uzytku wewnetrznego !
; Wstawia skoki do nastepnych instrukcji (2 takty) lub nop (1 takt)
; by uzyskac opoznienie maks 14 taktow
.macro WAIT_TICKS_MAX_14
	WAIT_TICKS_MAX_2 @0
	WAIT_TICKS_MAX_2 @0 - 2
	WAIT_TICKS_MAX_2 @0 - 4
	WAIT_TICKS_MAX_2 @0 - 6
	WAIT_TICKS_MAX_2 @0 - 8
	WAIT_TICKS_MAX_2 @0 - 10
	WAIT_TICKS_MAX_2 @0 - 12
.endmacro



.macro WAIT_TICKS
	.set WAIT_MICROSEC_TICKS	= @0

.if WAIT_MICROSEC_TICKS < (WAIT_REG_STORE_TICKS + 3) * 2

	WAIT_TICKS_MAX_14 WAIT_MICROSEC_TICKS

.elif WAIT_MICROSEC_TICKS <= (0xFF * 3) + (WAIT_REG_STORE_TICKS + 3)

	; nakazanie kompilatorowi skompilowanie WAIT_8_BITS
;	.set USE_WAIT_8_BITS = 1;
	WAIT_PUSH_REG	R_WAIT_0
	ldi R_WAIT_0, low( 1 + (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS - 3) / 3)
;	rcall WAIT_8_BITS
		subi    R_WAIT_0, 1
		brne    PC - 1
	WAIT_TICKS_MAX_14 (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS - 3) % 3
	WAIT_POP_REG	R_WAIT_0

.elif WAIT_MICROSEC_TICKS <= (0xFF * 5) + (WAIT_REG_STORE_TICKS + 5)

	; nakazanie kompilatorowi skompilowanie WAIT_8_BITS
;	.set USE_WAIT_8_BITS = 1;
	WAIT_PUSH_REG	R_WAIT_0
	ldi R_WAIT_0, low( 1 + (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS - 5) / 5)
;	rcall WAIT_8_BITS
		rjmp	PC + 1
		subi    R_WAIT_0, 1
		brne    PC - 2
	WAIT_TICKS_MAX_14 (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS - 5) % 5
	WAIT_POP_REG	R_WAIT_0

.elif WAIT_MICROSEC_TICKS <= (0xFFFF * 4) + (WAIT_REG_STORE_TICKS * 2 + 5)

	; nakazanie kompilatorowi skompilowanie WAIT_16_BITS
	;.set USE_WAIT_16_BITS = 1;
	WAIT_PUSH_REG	R_WAIT_1
	WAIT_PUSH_REG	R_WAIT_0
	ldi R_WAIT_0, low( 1 + (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS * 2 - 5) / 4)
	ldi R_WAIT_1, high( 1 + (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS * 2 - 5) / 4)
	;rcall WAIT_16_BITS
		subi    R_WAIT_0, 1
		sbci    R_WAIT_1, 0
		brne    PC - 2   
	WAIT_TICKS_MAX_14 (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS * 2 - 5) % 4
	WAIT_POP_REG	R_WAIT_0
	WAIT_POP_REG	R_WAIT_1

.elif WAIT_MICROSEC_TICKS <= (0xFFFF * 6) + (WAIT_REG_STORE_TICKS * 2 + 7)

	; nakazanie kompilatorowi skompilowanie WAIT_16_BITS
	;.set USE_WAIT_16_BITS = 1;
	WAIT_PUSH_REG	R_WAIT_1
	WAIT_PUSH_REG	R_WAIT_0
	ldi R_WAIT_0, low( 1 + (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS * 2 - 7) / 6)
	ldi R_WAIT_1, high( 1 + (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS * 2 - 7) / 6)
	;rcall WAIT_16_BITS
		rjmp	PC + 1
		subi    R_WAIT_0, 1
		sbci    R_WAIT_1, 0
		brne    PC - 3   
	WAIT_TICKS_MAX_14 (WAIT_MICROSEC_TICKS - WAIT_REG_STORE_TICKS * 2 - 7) % 6
	WAIT_POP_REG	R_WAIT_0
	WAIT_POP_REG	R_WAIT_1

.elif WAIT_MICROSEC_TICKS <= (0xFFFFFF * 5) + 26

	; nakazanie kompilatorowi skompilowanie WAIT_24_BITS
	.set USE_WAIT_24_BITS = 1;	
	push R_WAIT_2
	push R_WAIT_1
	push R_WAIT_0
	ldi R_WAIT_0, low( 1 + (WAIT_MICROSEC_TICKS - 26) / 5)
	ldi R_WAIT_1, high( 1 + (WAIT_MICROSEC_TICKS - 26) / 5)
	ldi R_WAIT_2, low( ((WAIT_MICROSEC_TICKS - 26) / 5) / 0x10000 )
	rcall WAIT_24_BITS
	WAIT_TICKS_MAX_14 (WAIT_MICROSEC_TICKS + 4) % 5
	pop R_WAIT_0
	pop R_WAIT_1
	pop R_WAIT_2

.elif WAIT_MICROSEC_TICKS <= (0xFFFFFFFF * 6) + 32

	; nakazanie kompilatorowi skompilowanie WAIT_32_BITS
	.set USE_WAIT_32_BITS = 1;	
	push R_WAIT_3
	push R_WAIT_2
	push R_WAIT_1
	push R_WAIT_0
	ldi R_WAIT_0, low( 1 + (WAIT_MICROSEC_TICKS - 32) / 6)
	ldi R_WAIT_1, high( 1 + (WAIT_MICROSEC_TICKS - 32) / 6)
	ldi R_WAIT_2, low( ((WAIT_MICROSEC_TICKS - 32) / 6) / 0x10000 )
	ldi R_WAIT_3, high( ((WAIT_MICROSEC_TICKS - 32) / 6) / 0x10000 )
	rcall WAIT_32_BITS
	WAIT_TICKS_MAX_14 (WAIT_MICROSEC_TICKS + 4) % 6
	pop R_WAIT_0
	pop R_WAIT_1
	pop R_WAIT_2
	pop R_WAIT_3

.else

	.error "za duzo taktow:"

.endif

.endmacro


; odczekuje podana ilosc mikrosekund minus okreslona ilosc taktow procesora
; dzia³a na rejestrach Y i Z
; Parametry:
; 0: Ilosc mikrosekund
; 1: ilosc taktow mniej
.macro WAIT_MICROSEC_MINUS_TICKS

	; Ilosc taktow petli liczacej bez pominiecia taktow na wywolanie
	; funkcji i odlozenie rejestrow na stos
	WAIT_TICKS	((@0) * FREQUENCY / 1000000) - (@1)
.endmacro


; odczekuje podana ilosc mikrosekun
; dzia³a na rejestrach Y i Z
; Parametry:
; 0: Ilosc mikrosekund
.macro WAIT_MICROSEC
    WAIT_MICROSEC_MINUS_TICKS @0, 0
.endmacro


; Odczekuje podana ilosc milisekund
; dzia³a na rejestrach Y i Z
; Parametry:
; 0: Ilosc milisekund
.macro WAIT_MILISEC
	WAIT_MICROSEC_MINUS_TICKS @0 * 1000, 0
.endmacro

#endif
