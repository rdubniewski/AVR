/*
 * TwiTest.asm
 *
 *  Created: 2012-04-12 08:24:24
 *   Author: Rafal
 */ 



.include <tn25def.inc>

; Wlaczenie I2C
.def R_I2C_DATA	= r16
.equ I2C_SCL_PORT	= PORTB
.equ I2C_SCL_BIT	= 1
.equ I2C_SDA_PORT	= PORTB
.equ I2C_SDA_BIT	= 2
.include "I2CMaster.inc"

.cseg
.org 0x0
	rjmp RESET

.org USI_STARTaddr
	reti

.org USI_OVFaddr	
	reti

.org INT_VECTORS_SIZE
RESET:
	; zainicjowanie stosu
	ldi r31, RAMEND
	out SPL, r31

	; zainicjowanie portow
	clr r31
	out DDRB, r31
	out PORTB, r31
	
	
	; wlaczenie przerwan
	sei

	rcall I2C_INIT

	ldi r30, 10
MAIN_LOOP:

	rjmp MAIN_LOOP

	; adres rejestru		
	rcall I2C_START
	
	ldi R_I2C_DATA, 0xA0
	rcall I2C_SEND_BYTE
	ldi R_I2C_DATA, 0
	rcall I2C_SEND_BYTE
	
	; odczyt 
	rcall I2C_START
	ldi R_I2C_DATA, 0xA1
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
.include "I2CMaster.asm"
