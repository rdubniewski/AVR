#ifndef _DS18B20_INC_
#define _DS18B20_INC_


.equ DS18S20_ROM_FAMILY_CODE			= 0x10
.equ DS18B20_ROM_FAMILY_CODE			= 0x28

.equ DS18B20_OP_CONVERT_T				= 0x44
.equ DS18B20_OP_READ_SCRATCHPAD			= 0xBE
.equ DS18B20_OP_WRITE_SCRATCHPAD		= 0x4E
.equ DS18B20_OP_COPY_SCRATCHPAD			= 0x48
.equ DS18B20_OP_RECALL_EE				= 0xB8
.equ DS18B20_OP_READ_POWER_SUPPLY		= 0xB4

; Wartosci bajtu konfiguracyjnego R_DS18B20_SCRATCHPAD_CONFIG lub
; DS18B20_SCRATCHPAD_CONFIG:
; precyzja 0.5 stopnia, czas pomiaru 93.75ms
.equ DS18B20_SCRATCHPAD_CONFIG_9_BIT	= 0b00011111
; precyzja 0.25 stopnia, czas pomiaru 187.5ms
.equ DS18B20_SCRATCHPAD_CONFIG_10_BIT	= 0b00111111
; precyzja 0.125 stopnia, czas pomiaru 375ms
.equ DS18B20_SCRATCHPAD_CONFIG_11_BIT	= 0b01011111
; precyzja 0.0625 stopnia, czas pomiaru 750ms
.equ DS18B20_SCRATCHPAD_CONFIG_12_BIT	= 0b01111111

;****************************************************************************
; SCRATCHPAD domyslnie jest umiejscowiony w pamieci RAM z nadanymi etykietami:
; DS18B20_SCRATCHPAD_TEMPERATURE_L:		.byte 1
; DS18B20_SCRATCHPAD_TEMPERATURE_H:		.byte 1
; DS18B20_SCRATCHPAD_BYTE_1:			.byte 1
; DS18B20_SCRATCHPAD_BYTE_2:			.byte 1
; DS18B20_SCRATCHPAD_CONFIG:			.byte 1
;
; SCRATCHPAD w obszarze pamieci mozna przydzielic indywidualnie, 
; wtedy nalezy zdefiniowac stala:
; .equ DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED		= 1
; 
; SCRATCHPAD mozna przedefiniowac w obszar rejestrów definiuj¹c stala:
; .equ DS18B20_SCRATCHPAD_IN_REG	= 1
;
; Przy zdefinowanym  DS18B20_SCRATCHPAD_IN_REG  nalezy zdefiniowac rejestry:
; .def R_DS18B20_SCRATCHPAD_TEMPERATURE_L	=r?
; .def R_DS18B20_SCRATCHPAD_TEMPERATURE_H	=r?
; .def R_DS18B20_SCRATCHPAD_BYTE_1			=r?
; .def R_DS18B20_SCRATCHPAD_BYTE_2			=r?
; .def R_DS18B20_SCRATCHPAD_CONFIG			=r?
;****************************************************************************

#endif
