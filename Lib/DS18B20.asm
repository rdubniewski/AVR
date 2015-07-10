#ifndef _DS18B20_ASM_
#define _DS18B20_ASM_

.include "OWireMaster.asm"
.include "DS18B20.inc"

; Zdefiniowanie SCRATCHPAD w obrzasze pamieci jak nie ma zdefioniowaneu
; odpowiadajacych rejestrow
.ifndef DS18B20_SCRATCHPAD_IN_REG

; Moze sie okazac ze obszar SCRATCHPAD zostal zdefiniowany gdzie indziej
.ifndef DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED

.equ DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED			= 1
.equ DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED_DEFAULT	= 1

.dseg
DS18B20_SCRATCHPAD:
DS18B20_SCRATCHPAD_TEMPERATURE_L:	.byte 1
DS18B20_SCRATCHPAD_TEMPERATURE_H:	.byte 1
DS18B20_SCRATCHPAD_BYTE_1:			.byte 1
DS18B20_SCRATCHPAD_BYTE_2:			.byte 1
DS18B20_SCRATCHPAD_CONFIG:			.byte 1
	
.endif
.endif

; info o sposobie zdefiniowania SCRATCHPAD
.ifdef DS18B20_SCRATCHPAD_IN_REG
	.warning "SCRATCHPAD dla DS18B20 zosta³ zdefiniowany w obszarze rejestrow"
.endif

.ifdef DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED
	.ifdef DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED_DEFAULT
		.warning "SCRATCHPAD dla DS18B20 (5 bajtów) zosta³ zdefiniowany w domyslnym obszarze RAM w DS18B20.asm (DS18B20_SCRATCHPAD:)"
	.else
		.warning "SCRATCHPAD dla DS18B20 zosta³ zdefiniowany w obszarze RAM, poza plikim DS18B20.asm"
	.endif
.endif



.cseg

.macro DS18B20_STORE_SCRATCHPAD_BYTE
.ifdef DS18B20_SCRATCHPAD_IN_REG
	mov @0, R_DATA
.else
	sts @1, R_DATA
.endif
.endmacro

.macro DS18B20_LOAD_SCRATCHPAD_BYTE
.ifdef DS18B20_SCRATCHPAD_IN_REG
	mov R_DATA, @0
.else
	lds R_DATA, @1
.endif
.endmacro

;----------------------------------------------------------------------------
; wysyla zadanie OP_READ_SCRATCHPAD (0xBE) i odczytuje 9 bajtow danych
; wazne dane zapisuje do:
; R_SCRATCHPAD_CONFIG, R_SCRATCHPAD_BYTE_2, R_SCRATCHPAD_BYTE_1, 
; R_SCRATCHPAD_TEMPERATURE_H, R_SCRATCHPAD_TEMPERATURE_L
; Ostatni odczytany bajt (CRC) jest w R_DATA
; Zgodnosc odczutanego bajtu CRC z wyliczonym CRC zygnalizuje skasowany
; bit SREG-Z
DS18B20_READ_SCRATCHPAD:
    ; instrukcja OP_READ_SCRATCHPAD (0xBE)
    ldi     R_DATA, DS18B20_OP_READ_SCRATCHPAD
    rcall   OWIRE_M_SEND_BYTE

    clr     R_OWIRE_CRC
    rcall   OWIRE_M_READ_BYTE_CRC
    DS18B20_STORE_SCRATCHPAD_BYTE \
            R_DS18B20_SCRATCHPAD_TEMPERATURE_L, DS18B20_SCRATCHPAD_TEMPERATURE_L

    rcall   OWIRE_M_READ_BYTE_CRC
    DS18B20_STORE_SCRATCHPAD_BYTE \
            R_DS18B20_SCRATCHPAD_TEMPERATURE_H, DS18B20_SCRATCHPAD_TEMPERATURE_H

    rcall   OWIRE_M_READ_BYTE_CRC
    DS18B20_STORE_SCRATCHPAD_BYTE \
            R_DS18B20_SCRATCHPAD_BYTE_1, DS18B20_SCRATCHPAD_BYTE_1

    rcall   OWIRE_M_READ_BYTE_CRC
    DS18B20_STORE_SCRATCHPAD_BYTE \
            R_DS18B20_SCRATCHPAD_BYTE_2, DS18B20_SCRATCHPAD_BYTE_2

    rcall   OWIRE_M_READ_BYTE_CRC
    DS18B20_STORE_SCRATCHPAD_BYTE \
            R_DS18B20_SCRATCHPAD_CONFIG, DS18B20_SCRATCHPAD_CONFIG

    rcall   OWIRE_M_READ_BYTE_CRC; Reserved (FFh)
    rcall   OWIRE_M_READ_BYTE_CRC; Reserved
    rcall   OWIRE_M_READ_BYTE_CRC; Reserved (10h)

    ; CRC -> R_DATA
    rcall   OWIRE_M_READ_BYTE

    ; sprawdzenie zgodnosci CRC
    cp      R_DATA, R_OWIRE_CRC
    
    ret
;----------------------------------------------------------------------------
DS18B20_WRITE_SCRATCHPAD:
    ; instrukcja WRITE SCRATCHPAD (0x4E)
    ldi     R_DATA, DS18B20_OP_WRITE_SCRATCHPAD
    rcall   OWIRE_M_SEND_BYTE

    DS18B20_LOAD_SCRATCHPAD_BYTE \
	        R_DS18B20_SCRATCHPAD_BYTE_1, DS18B20_SCRATCHPAD_BYTE_1
    rcall   OWIRE_M_SEND_BYTE

    DS18B20_LOAD_SCRATCHPAD_BYTE \
	        R_DS18B20_SCRATCHPAD_BYTE_2, DS18B20_SCRATCHPAD_BYTE_2
    rcall   OWIRE_M_SEND_BYTE

    DS18B20_LOAD_SCRATCHPAD_BYTE \
	        R_DS18B20_SCRATCHPAD_CONFIG, DS18B20_SCRATCHPAD_CONFIG
    rcall   OWIRE_M_SEND_BYTE

    ret
;----------------------------------------------------------------------------

#endif
