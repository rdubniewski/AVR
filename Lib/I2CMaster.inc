/****************************************************************************
File:				I2CMaster.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2012.04.17
Modified:			2012.04.17
****************************************************************************/
#ifndef _I2CMASTER_INC_
#define _I2CMASTER_INC_


.ifndef R_I2C_DATA
	.def R_I2C_DATA = r16
	.warning "Rejestrowi danych R_I2C_DATA magistrali I2C zostal przypisany R16, Zdefiniuj rejestr przed wlaczeniem I2CMaster.inc"
.endif

.ifndef I2C_SCL_PORT
	.equ I2C_SCL_PORT = PORTB
	.warning "Port dla bitu SCL magistrali I2C zostal przypisany do PORTB, Okresl I2C_SCL_PORT przed wlaczeniem I2CMaster.inc"
.endif

.ifndef I2C_SCL_BIT
	.equ I2C_SCL_BIT = 0
	.warning "Bit SCL magistrali I2C zostal przypisany do bitu 0, Okresl I2C_SCL_BIT przed wlaczeniem I2CMaster.inc"
.endif


.ifndef I2C_SDA_PORT
	.equ I2C_SDA_PORT = PORTB
	.warning "Port dla bitu SDA magistrali I2C zostal przypisany do PORTB, Okresl I2C_SDA_PORT przed wlaczeniem I2CMaster.inc"
.endif

.ifndef I2C_SDA_BIT
	.equ I2C_SDA_BIT = 1
	.warning "Bit SDA magistrali I2C zostal przypisany do bitu 1, Okresl I2C_SDA_BIT przed wlaczeniem I2CMaster.inc"
.endif


.ifdef PORTA
	.if(I2C_SCL_PORT == PORTA)
		.equ I2C_SCL_PIN = PINA
		.equ I2C_SCL_DDR = DDRA
	.endif
	.if(I2C_SDA_PORT == PORTA)
		.equ I2C_SDA_PIN = PINA
		.equ I2C_SDA_DDR = DDRA
	.endif
.endif
.ifdef PORTB
	.if(I2C_SCL_PORT == PORTB)
		.equ I2C_SCL_PIN = PINB
		.equ I2C_SCL_DDR = DDRB
	.endif
	.if(I2C_SDA_PORT == PORTB)
		.equ I2C_SDA_PIN = PINB
		.equ I2C_SDA_DDR = DDRB
	.endif
.endif
.ifdef PORTC
	.if(I2C_SCL_PORT == PORTC)
		.equ I2C_SCL_PIN = PINC
		.equ I2C_SCL_DDR = DDRC
	.endif
	.if(I2C_SDA_PORT == PORTC)
		.equ I2C_SDA_PIN = PINC
		.equ I2C_SDA_DDR = DDRC
	.endif
.endif
.ifdef PORTD
	.if(I2C_SCL_PORT == PORTD)
		.equ I2C_SCL_PIN = PIND
		.equ I2C_SCL_DDR = DDRD
	.endif
	.if(I2C_SDA_PORT == PORTD)
		.equ I2C_SDA_PIN = PIND
		.equ I2C_SDA_DDR = DDRD
	.endif
.endif
.ifdef PORTE
	.if(I2C_SCL_PORT == PORTE)
		.equ I2C_SCL_PIN = PINE
		.equ I2C_SCL_DDR = DDRE
	.endif
	.if(I2C_SDA_PORT == PORTE)
		.equ I2C_SDA_PIN = PINE
		.equ I2C_SDA_DDR = DDRE
	.endif
.endif
.ifdef PORTF
	.if(I2C_SCL_PORT == PORTF)
		.equ I2C_SCL_PIN = PINF
		.equ I2C_SCL_DDR = DDRF
	.endif
	.if(I2C_SDA_PORT == PORTF)
		.equ I2C_SDA_PIN = PINF
		.equ I2C_SDA_DDR = DDRF
	.endif
.endif


#endif

