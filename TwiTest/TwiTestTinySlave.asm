.include "tn25def.inc"

.equ    I2C_SCL_DDR         = DDRB
.equ    I2C_SDA_DDR         = DDRB
.equ    I2C_SCL_PORT        = PORTB
.equ    I2C_SDA_PORT         = PORTB
.equ    I2C_SCL_PIN         = PINB
.equ    I2C_SDA_PIN         = PINB
.equ    I2C_SCL_BIT         = 2
.equ    I2C_SDA_BIT         = 0


.equ    I2C_SLAVE_ADDRESS   = 0xA6
.def    R_I2C_FLAGS         = r16
.def    R_I2C_TMP           = r17

.macro  I2C_CHECK_SLAVE_ADDRESS
    cpi     R_I2C_TMP, I2C_SLAVE_ADDRESS
.endmacro

.macro  I2C_SEND_BYTE
   ldi     R_I2C_TMP, 0x19
   out     USIDR, R_I2C_TMP
.endmacro

.macro  I2C_RECV_BYTE
.endmacro

.macro  I2C_START_BEGIN
.endmacro

.macro  I2C_START_END
.endmacro

.macro  I2C_OV_BEGIN
.endmacro

.macro  I2C_OV_END
.endmacro


.dseg
;.org	SRAM_START

;----------------------------------------------------------
.cseg
.ORG 0
	RJMP RESET
.ORG USI_STARTaddr		;USI_STRaddr
    rjmp I2C_START
.ORG USI_OVFaddr
    rjmp I2C_OV
;----------------------------------------------------------
RESET:
.ifdef SPH
    ldi     R_I2C_TMP, high(RAMEND)
    out     SPH, R_I2C_TMP
.endif
    ldi     R_I2C_TMP, low(RAMEND)
    out     SPL, R_I2C_TMP
    
	;outi DDRD, 0xFF
	;outi PORTD,0
	
	;sbi ACSR,ACD					;disable AnalogCoparator
	
	ldi     R_I2C_TMP, 1 << SE
    out     MCUCR, R_I2C_TMP				;Sleep On///Power-Down Mode

    ; ustawienie preskalera na 8 MHz
    ldi     r31, 1 << CLKPCE
    out     CLKPR, r31
    ldi     r31, 0 << CLKPS2 | 0 << CLKPS1 | 0 << CLKPS0
    out     CLKPR, r31


;I2Cinit:
	rcall   I2C_INIT
	sei

MainLoop:
	sleep
	WDR
    
    rjmp MainLoop

.include <I2CTinySlave.asm>
