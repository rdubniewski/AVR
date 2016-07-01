/*
 * TwiTest.asm
 *
 *  Created: 2012-04-12 08:24:24
 *   Author: Rafal
 */ 



 .equ   FREQUENCY   = 8000000


.include <tn25def.inc>
.include <Wait.inc>

; Wlaczenie I2C
.def R_I2C_DATA	= r16
.equ I2C_SCL_PORT	= PORTB
.equ I2C_SCL_BIT	= 2
.equ I2C_SDA_PORT	= PORTB
.equ I2C_SDA_BIT	= 0

.include "I2CMaster.inc"

.cseg
.org 0x0
	rjmp RESET

;.org USI_STARTaddr
;	reti

;.org USI_OVFaddr	
;	reti

.org INT_VECTORS_SIZE
RESET:
	; zainicjowanie stosu
;	ldi r31, high(RAMEND)
;	out SPH, r31
    ldi r31, low(RAMEND)
	out SPL, r31

	; zainicjowanie portow
	clr r31
	out DDRB, r31
	out PORTB, r31
	
    WAIT_MILISEC 1
	
    ; ustawienie preskalera na 1/8MHz - Tiny25
    ldi     r31, 1 << CLKPCE
    out     CLKPR, r31
    ldi     r31, 1 << CLKPS2 | 1 << CLKPS1
    out     CLKPR, r31

	; wlaczenie przerwan
	sei

	rcall I2C_INIT

    WAIT_MILISEC 1

	ldi r30, 10
MAIN_LOOP:

	;rjmp MAIN_LOOP

	; adres rejestru		
	rcall I2C_START
	
	ldi R_I2C_DATA, 0xA6
	rcall I2C_SEND_BYTE
	ldi R_I2C_DATA, 69
	rcall I2C_SEND_BYTE	
    ldi R_I2C_DATA, 37
	rcall I2C_SEND_BYTE	
    rcall I2C_STOP

	; odczyt 
	rcall I2C_START
	ldi R_I2C_DATA, 0xA6 + 1
	rcall I2C_SEND_BYTE
	
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_NAK

	rcall I2C_STOP

	rjmp MAIN_LOOP
	;reti
;----------------------------------------------------------------------------

.macro I2C_SCL_0
	sbi I2C_SCL_DDR, I2C_SCL_BIT
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SCL_1
	cbi I2C_SCL_DDR, I2C_SCL_BIT
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SDA_0
	sbi I2C_SDA_DDR, I2C_SDA_BIT
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SDA_1
	cbi I2C_SDA_DDR, I2C_SDA_BIT
.endmacro
;----------------------------------------------------------------------------

.cseg

I2C_INIT:
	I2C_SCL_1
	I2C_SDA_1
	cbi I2C_SCL_PORT, I2C_SCL_BIT
	cbi I2C_SDA_PORT, I2C_SDA_BIT
	ret
;----------------------------------------------------------------------------
I2C_START:
	I2C_SDA_1	
	I2C_SCL_1
	I2C_SDA_0
	I2C_SCL_0
	ret
;----------------------------------------------------------------------------
I2C_STOP:
	I2C_SDA_0	
	I2C_SCL_1
	I2C_SDA_1
	ret
;----------------------------------------------------------------------------
I2C_SEND_BIT:
	sbrc R_I2C_DATA, 7
	rjmp _TSB_1

_TSB_0:
	I2C_SDA_0
	I2C_SCL_1
	I2C_SCL_0
	ret

_TSB_1:
	I2C_SDA_1
	I2C_SCL_1
	I2C_SCL_0
	
	ret
;----------------------------------------------------------------------------
I2C_RECV_BIT:
	I2C_SDA_1
	I2C_SCL_1
	
	cbr R_I2C_DATA, 1
	sbic I2C_SDA_PIN, I2C_SDA_BIT
	sbr R_I2C_DATA, 1

	I2C_SCL_0	

	ret
;----------------------------------------------------------------------------
I2C_SEND_BYTE:
	push R_I2C_DATA
	push r31

	ldi r31, 8
_TSB_LOOP:

	rcall I2C_SEND_BIT
	lsl R_I2C_DATA

	dec r31
	brne _TSB_LOOP

	; ACK / NAK
	rcall I2C_RECV_BIT	

	pop r31
	pop R_I2C_DATA
	ret
;----------------------------------------------------------------------------
I2C_RECV_BYTE:
	push r31

	clr R_I2C_DATA
	ldi r31, 8
_WRB_LOOP:

	lsl R_I2C_DATA
	rcall I2C_RECV_BIT
	
	dec r31
	brne _WRB_LOOP

	pop r31
	
	ret 
;----------------------------------------------------------------------------
I2C_RECV_BYTE_ACK:
	rcall I2C_RECV_BYTE

	; ACK 
	I2C_SDA_0
	I2C_SCL_1
	I2C_SCL_0
	
	ret
;----------------------------------------------------------------------------
I2C_RECV_BYTE_NAK:
	rcall I2C_RECV_BYTE

	; NAK 
	I2C_SDA_1
	I2C_SCL_1
	I2C_SCL_0
	
	ret
;----------------------------------------------------------------------------


;.include "I2CMaster.asm"
.include "Wait.asm"


