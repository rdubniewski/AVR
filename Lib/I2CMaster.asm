/****************************************************************************
File:				I2CMaster.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2012.04.17
Modified:			2012.04.17
****************************************************************************/

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
