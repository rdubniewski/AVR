/****************************************************************************
File:				TermometrPieca.inc
Author:				Rafa³ Dubniewski
PCB Verssion		1.x
Verssion			1.0
Created:			2012.03.29
Modified:			2012.03.29
****************************************************************************/
.include    "DefineIO.inc"
.include    "I2C_DeviceTypes.inc"


.equ    DEVICE_ID_DEF                   = DEVICE_TANK_MULTI_THERMOMETER_TYPE
.equ    DEVICE_VERSION_DEF              = 0x10

.equ    FREQUENCY                       = 16000000

; Definicja preskalera zegara przy generatorze PLL
.equ    CLKPR_DEF                       = 0 << CLKPS2 | 0 << CLKPS1 | 0 << CLKPS0

; konfiguracja timera kontroli stanu (timer 1), ok 4Hz
.equ    TIMER_FREQUENCY                 = 4
.equ    TIMER_CNT                       = TCNT1
.equ    TIMER_PRESCALER                 = 16384
.equ    TIMER_CONTROL_1                 = TCCR1
.equ    TIMER_CONTROL_1_OFF_DEF         = 1 << PWM1A
.equ    TIMER_CONTROL_1_ON_DEF          = TIMER_CONTROL_1_OFF_DEF |   \
                                          1 << CS13 | 1 << CS12 | 1 << CS11 | 1 << CS10
.equ    TIMER_CONTROL_2                 = GTCCR
.equ    TIMER_CONTROL_2_DEF             = 1 << PWM1B
.equ    TIMER_OCR                       = OCR1C
.equ    TIMER_OCR_DEF                   = (FREQUENCY / TIMER_PRESCALER / TIMER_FREQUENCY) + 0
.equ    TIMER_MASK_DEF                  = 1 << TOIE1


; ilosc taktow timera do pobrania wyniku pomiaru, dla precyzji pomiaru 0.5
; to ok 100ms, damy 200
.set    WAIT_MEASURE_TIME               = TIMER_FREQUENCY * 2 / 10 + 1

.equ    O_WIRE_ROM_STORE_SIZE           = 6
.equ    SENSOR_COUNT_MAX                = 12

; Wylaczenie odkladania na stosie rejestrow w funkcji OWIRE_MASTER_SEARCH_ROM
.equ    OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS   = 1
; Wylaczenie odkladania na stosie rejestrow w funkcji WAIT_*

.equ    I2C_MY_ADDRESS_DEFAULT          = DEVICE_TANK_MULTI_THERMOMETER_I2C_ADDRES
; Zadania I2C
.equ    I2C_REQUEST_MEASURE                         = 0xC0
.equ    I2C_REQUEST_MEASURE_BIT                     = 0
.equ    I2C_REQUEST_MEASURE_STEEL_BIT               = 1
.equ    I2C_REQUEST_MEASURE_SORT_BIT                = 2
.equ    I2C_REQUEST_MEASURE_SORT_DESCENDING_BIT     = 3
.equ    I2C_REQUEST_MEASURE_MASK                    = 0x0F

.equ    I2C_REQUEST_HEAT                            = 0xE0
.equ    I2C_REQUEST_HEAT_CONFIGURE_0                = 0xE0
.equ    I2C_REQUEST_HEAT_TEMPERATURES_0             = 0xE1
.equ    I2C_REQUEST_HEAT_CONFIGURE_1                = 0xE2
.equ    I2C_REQUEST_HEAT_TEMPERATURES_1             = 0xE3

.equ    I2C_REQUEST_SAVE_EE                         = 0xA0
.equ    I2C_REQUEST_SAVE_EE_I2C_ADDRESS_BIT         = 0
.equ    I2C_REQUEST_SAVE_EE_SENSORS_BIT             = 1
.equ    I2C_REQUEST_SAVE_EE_STATE_BIT               = 2
.equ    I2C_REQUEST_SAVE_EE_HEAT_0_BIT              = 3
.equ    I2C_REQUEST_SAVE_EE_HEAT_1_BIT              = 4
.equ    I2C_REQUEST_SAVE_EE_MASK                    = 0x1F

.equ    I2C_REQUEST_REPEAT_TIME                     = 0x62
.equ    I2C_REQUEST_SEARCH_SENSORS                  = 0x68

.equ    I2C_REQUEST_SLAVE_ADDRESS                   = 0x81
.equ    I2C_REQUEST_RESET                           = 0x88



.equ    I2C_STORE_R_TMP                         = 0
.equ    I2C_START_STORE_SREG                    = 1


; Rejestry u¿ywana w funkcji CHECK_HEATER_POINTER
.def    R_HEAT_CONFIG_L                         = r2
.def    R_HEAT_CONFIG_H                         = r3
.def    R_HEAT_TEMPERATURE_ON                   = r4
.def    R_HEAT_TEMPERATURE_OFF                  = r5
.def    R_HEAT_TEMPERATURE_ON_L                 = r6
.def    R_HEAT_TEMPERATURE_ON_H                 = r7
.def    R_HEAT_TEMPERATURE_ON_CALC_L            = r8
.def    R_HEAT_TEMPERATURE_ON_CALC_H            = r9
.def    R_HEAT_TEMPERATURE_OFF_L                = r10
.def    R_HEAT_TEMPERATURE_OFF_H                = r11
.def    R_HEAT_TEMPERATURE_OFF_CALC_L           = r12
.def    R_HEAT_TEMPERATURE_OFF_CALC_H           = r13

; Rejestry u¿ywane w funkcji OWIRE_MASTER_SEARCH_ROM
.def    R_OWIRE_MASTER_STACK                    = r11
.def    R_OWIRE_MASTER_STACK_PTR                = r12
.def    R_OWIRE_MASTER_STACK_PTR_MAX            = r13
.def    R_SREG_INTERRUPT_STORE                  = r15

; R_TMP_1, musi byæ parzysty i bezpoœrednio przed R_TMP_2,
; wymaga tego kod
.def    R_TMP_1                                 = r16
.def    R_TMP_2                                 = r17

.def    R_DATA                                  = r18
.def    R_LOOP                                  = r19
.def    R_OWIRE_CRC                             = r20
.def    R_TIMER_COUNTER                         = r21
.def    R_TIMER_SEC                             = r22
.def    R_SENSOR_NR                             = r23
.def    R_CONTROL                               = r24
.def    R_I2C_FLAGS                             = r25
; rejestr X (r26:r27) jesy u¿ywany jako wskaznik przy niektorych funkcjach
; i nie moze byc uzywany do rejestrów wykorzystanych w obsludze przerwan
.def    R_I2C_TMP                               = r28
.def    R_I2C_MY_ADDRESS                        = r29
#define R_I2C_BUF_POINTER                       Z
#define R_I2C_BUF_POINTER_L                     ZL
#define R_I2C_BUF_POINTER_H                     ZH

#define R_OWIRE_DATA                            R_DATA
;.equ    I2C_FLAGS                              = GPIOR0

#define R_POINTER                               X
#define R_POINTER_L                             XL
#define R_POINTER_H                             XH

#define R_OWIRE_MASTER_POINTER                  R_POINTER
#define R_OWIRE_MASTER_POINTER_L                R_POINTER_L
#define R_OWIRE_MASTER_POINTER_H                R_POINTER_H

.equ    DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED    = 1

; Bity rejestru kontrolnego pracy programu R_CONTROL
; Flaga ustawiana w przerwaniui timera
.equ    R_CONTROL_CHECK_TIMER_BIT               = 0
; Flaga wyslania zadania pomiaru do czujników.
.equ    R_CONTROL_START_MEASURE_BIT             = 1
; Flaga odczytania temperatuey
.equ    R_CONTROL_READ_TEMPERATURE_BIT          = 2
; flaga pomocnicza przy sortowaniu wyniku
.equ    R_CONTROL_SORT_SWAPED_BIT               = 3
; flaga nakazujaca zatrzymanie 
.equ    R_CONTROL_RESET_TIMER_BIT               = 4
; Flaga informuj¹ca o nadejœciu bajtu
.equ    R_CONTROL_I2C_READ_BYTE_BIT             = 7

.equ    R_CONTROL_REQUEST_MASK                  =   \
            1 << R_CONTROL_I2C_READ_BYTE_BIT |      \
            1 << R_CONTROL_START_MEASURE_BIT |      \
            1 << R_CONTROL_READ_TEMPERATURE_BIT


DEFINE_IO   OWIRE_MASTER,   B, 4
DEFINE_IO   SCL,            B, 2
DEFINE_IO   SDA,            B, 0
DEFINE_IO   HEATER_0,       B, 1
DEFINE_IO   HEATER_1,       B, 3


; Organizacja RAMU
.dseg

I2C_SEND_DATA:
DEVICE_ID:                              .byte   1
DEVICE_VERSION:                         .byte   1
I2C_SEND_DATA_DEFAULT_START:
STATE:                                  .byte   1
    .equ    STATE_MEASURING_BIT                 = 0
    .equ    STATE_COMPLETE_BIT                  = 1
    .equ    STATE_OBSOLETE_BIT                  = 2
    .equ    STATE_CONTINUE_BIT                  = 3
    .equ    STATE_SORT_BIT                      = 4
    .equ    STATE_SORT_DESCENDING_BIT           = 5
    .equ    STATE_HEAT_0_BIT                    = 6
    .equ    STATE_HEAT_1_BIT                    = 7
;    .equ    MEASURE_STATE_MASK                  = 1 << MEASURE_STATE_MEASURING_BIT |  \
;                                              1 << MEASURE_STATE_COMPLETE_BIT  |  \
;                                              1 << MEASURE_STATE_OBSOLETE_BIT
SENSOR_COUNT:                           .byte   1
; odczytane i temperatury czujnikow
SENSORS_TEMPERATURE:                    .byte   SENSOR_COUNT_MAX
; Pocz¹tek odzwierciedlania pamiêci w EEpromie
STORAGE_IN_E_BEGIN:
; Tablica odnalezionych ROMow czujnikow
SENSOR_ROMS:                            .byte   O_WIRE_ROM_STORE_SIZE * SENSOR_COUNT_MAX
REPEAT_TIME:                            .byte   1
HEAT_0:
HEAT_0_CONFIG_H:                        .byte   1
HEAT_0_CONFIG_L:                        .byte   1
HEAT_0_TEMPERATURE_ON:                  .byte   1
HEAT_0_TEMPERATURE_OFF:                 .byte   1
HEAT_1:
HEAT_1_CONFIG_H:                        .byte   1
HEAT_1_CONFIG_L:                        .byte   1
HEAT_1_TEMPERATURE_ON:                  .byte   1
HEAT_1_TEMPERATURE_OFF:                 .byte   1

; Konie odzwierciedlania pamiêci w EEpromie
STORAGE_IN_E_END:

; Koniec pamiêci zwracanej przez i2c
I2C_SEND_DATA_END:


I2C_RECV_DATA:
I2C_RECV_DATA_REQUEST:                  .byte   1
I2C_RECV_DATA_ARGS:                     .byte   2
I2C_RECV_DATA_END:

OWIRE_ROM: 
DS18B20_SCRATCHPAD:

OWIRE_ROM_FAMILY_CODE:
DS18B20_SCRATCHPAD_TEMPERATURE_L:       .byte   1

OWIRE_ROM_ID:
OWIRE_ROM_ID_0:
DS18B20_SCRATCHPAD_TEMPERATURE_H:       .byte   1

OWIRE_ROM_ID_1:
DS18B20_SCRATCHPAD_BYTE_1:              .byte   1

OWIRE_ROM_ID_2:
DS18B20_SCRATCHPAD_BYTE_2:              .byte   1

OWIRE_ROM_ID_3:
DS18B20_SCRATCHPAD_CONFIG:              .byte   1

OWIRE_ROM_ID_4:                         .byte   1
OWIRE_ROM_ID_5:                         .byte   1


; organizacja EEPROM
.eseg

E_I2C_MY_ADDRESS:                       .db I2C_MY_ADDRESS_DEFAULT
E_DEFAULT_STATE:                        .db 0
E_SENSOR_COUNT:                         .db 0xFF
E_STORAGE_MEMORY_BEGIN:                 .byte   (STORAGE_IN_E_END - STORAGE_IN_E_BEGIN)
E_STORAGE_MEMORY_END:
;.equ OWIRE_MASTER_SEARCH_ROM_USING	= 1

; Wskazanie, ze OWIRE_ROM zostal zdefiniowany poza OWireMaster.asm
;.equ OWIRE_ROM_IN_RAM_IS_DEFINED	= 1

;.equ DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED = 0
