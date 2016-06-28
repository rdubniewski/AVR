#ifndef _CzujnikParametrowMuru_inc_
#define _CzujnikParametrowMuru_inc_

.include    "I2C_DeviceTypes.inc"

.equ    DEVICE_TYPE_DEF                 = DEVICE_WALL_SENSOR_TYPE
/* PCB: 1.x
.equ    DEVICE_VERSION_DEF              = 0x10
*/
; PCB: 2.x
.equ    DEVICE_VERSION_DEF              = 0x20

.equ    FREQUENCY                       = 12000000
; Domyslna licznik dla PLL by wstepnie ustawiæ 12MHz
.equ    OSCCAL_DEFAULT                   = OSCCAL_DEFAULT

.equ    SENSOR_I2C_FREQUENCY            = 100000
.equ    SENSOR_I2C_DELAY_TICKS          = FREQUENCY / SENSOR_I2C_FREQUENCY / 2

.equ    I2C_MY_ADDRESS_DEFAULT          = DEVICE_WALL_SENSOR_I2C_ADDRES

.equ    POWER_SAVE_IDLE                 = 1 << PRTIM1 | 1 << PRTIM0 | 1 << PRADC
.equ    POWER_SAVE_SENSOR_COMMUNICATION = 1 << PRTIM1 | 0 << PRTIM0 | 1 << PRADC
.equ    POWER_SAVE_HEATING              = 0 << PRTIM1 | 1 << PRTIM0 | 1 << PRADC


; Definicje timere liczacego sekundy wygrzewania czujnikow
.equ    HEATING_TIMER_PRESCALER_VAL     = 256
.equ    HEATING_TIMER_CR                = TCCR1B
.equ    HEATING_TIMER_CR_ON_VAL         = 0 << WGM13 | 1 << WGM12 | 1 << CS12
.equ    HEATING_TIMER_CR_OFF_VAL        = 0 << WGM13 | 1 << WGM12 | 0 << CS12
.equ    HEATING_TIMER_CNT_H             = TCNT1H
.equ    HEATING_TIMER_CNT_L             = TCNT1L
.equ    HEATING_TIMER_OCR_H             = OCR1AH
.equ    HEATING_TIMER_OCR_L             = OCR1AL
.equ    HEATING_TIMER_OCR_VAL           = FREQUENCY / HEATING_TIMER_PRESCALER_VAL
.equ    HEATING_TIMER_MSK               = TIMSK1
.equ    HEATING_TIMER_MSK_VAL           = 1 << OCIE1A

.def    R_SREG_INTERRUPT_STORE          = r6
.def    R_SENSOR_EXISTS                 = r7
.def    R_S_DATA_0                      = r8
.def    R_S_DATA_1                      = r9
.def    R_S_DATA_2                      = r10
.def    R_S_DATA_3                      = r11
.def    R_S_DATA_4                      = r12
.def    R_S_DATA_5                      = r13
.def    R_S_DATA_6                      = r14
.def    R_S_DATA_7                      = r15

.def    R_EXISTING_SENSOR_COUNT         = r14
.def    R_TMP_1                         = r16
.def    R_TMP_2                         = r17
.def    R_S_SEND_DATA                   = r18
.def    R_LOOP                          = r19

; rejestry obliczania sa uzywane tylko w jednej funkcji CALCULATE_SENSOR_Z,
; moga pokrywac sie z wszystkimi rejestrami oproz Z i rejestrami obslugi
; przerwan: I2C
.def    R_MUL_TMP_0                     = r15
.def    R_MATH_A_0                      = r16
.def    R_MATH_A_1                      = r17
.def    R_MATH_A_2                      = r18
.def    R_MATH_A_3                      = r19
.def    R_MATH_B_0                      = r20
.def    R_MATH_B_1                      = r21
.def    R_MATH_B_2                      = r28
.def    R_MATH_B_3                      = r29
#define R_MUL_A_0                       R_MATH_A_0
#define R_MUL_A_1                       R_MATH_A_1
#define R_MUL_A_2                       R_MATH_A_2
#define R_MUL_B_0                       R_MATH_B_0
#define R_MUL_B_1                       R_MATH_B_1
#define R_MUL_B_2                       R_MATH_B_2

.equ    MATH_MUL_FULL_SOFT              = 1

; obs³uga USI-I2C, nie moze uzywac rejestrow Y i Z poniewaz
; sa uzywane podczas obliczen
; Rejestr kontrolny
.def    R_CONTROL                       = r22
    .equ    R_CONTROL_I2C_READ_BYTE_BIT             = 0
    .equ    R_CONTROL_SENSOR_COMMUNICATION_BIT      = 1
    .equ    R_CONTROL_HEATING_SENSORS_BIT           = 2
    .equ    R_CONTROL_HEATING_TIMER_OV_BIT          = 3
.def    R_I2C_FLAGS                     = r23
.def    R_I2C_TMP                       = r24
.def    R_I2C_MY_ADDRESS                = r25
.def    R_I2C_MY_ADDRESS_L                = r3
#define R_I2C_BUF_POINTER_L             XL
#define R_I2C_BUF_POINTER_H             XH
#define R_I2C_BUF_POINTER               X
.equ    I2C_STORE_R_TMP                 = 0
.equ    I2C_START_STORE_SREG            = 1

; zezwolenie na adresowanie odczytywanego rejestru zakonczone bitem STOP
.equ    I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS    = 1

; Zadania I2C
.equ    I2C_REQUEST_START_MEASURE       = 0xC1
.equ    I2C_REQUEST_START_HEAT_SENSORS  = 0xC2
.equ    I2C_REQUEST_STOP_HEAT_SENSORS   = 0xC3
.equ    I2C_REQUEST_TEST_FREQUENCY      = 0x90
.equ    I2C_REQUEST_FREQUENCY_INCREMENT = 0x91
.equ    I2C_REQUEST_FREQUENCY_DECREMENT = 0x92
.equ    I2C_REQUEST_FREQUENCY_SET		= 0x94
.equ    I2C_REQUEST_SAVE_FREQUENCY      = 0x98
.equ    I2C_REQUEST_SLAVE_ADDRESS       = 0x81
.equ    I2C_REQUEST_RESET               = 0x88

/* Przypisuje nazwie wyjscie procesora dodaj¹c do nazwy odpowiednie
    przyrostki: _PIN, _PORT, _DDR, _BIT.
@0: Nazwa dla IO.
@1: Litera IO: A, B, C...
@1: Bit portu: <0;7> */
.macro  DEFINE_IO
    .equ @0_DDR      = DDR@1
    .equ @0_PORT     = PORT@1
    .equ @0_PIN      = PIN@1
    .equ @0_BIT      = @2
.endmacro


/* PCB: 1.x
DEFINE_IO   S_SDA_0,    B, 1
DEFINE_IO   S_SDA_1,    B, 2
DEFINE_IO   S_SDA_2,    A, 7
DEFINE_IO   S_SDA_3,    A, 5
DEFINE_IO   S_SDA_4,    A, 3
DEFINE_IO   S_SDA_5,    A, 2
DEFINE_IO   S_SDA_6,    A, 1
DEFINE_IO   S_SDA_7,    A, 0
DEFINE_IO   S_SCL,      B, 0
DEFINE_IO   SCL,        A, 4
DEFINE_IO   SDA,        A, 6
*/

; PCB 2.x
DEFINE_IO   S_SDA_0,    B, 0
DEFINE_IO   S_SDA_1,    B, 1
DEFINE_IO   S_SDA_2,    B, 2
DEFINE_IO   S_SDA_3,    A, 7
DEFINE_IO   S_SDA_4,    A, 5
DEFINE_IO   S_SDA_5,    A, 3
DEFINE_IO   S_SDA_6,    A, 2
DEFINE_IO   S_SDA_7,    A, 1
DEFINE_IO   S_SCL,      A, 0
DEFINE_IO   SCL,        A, 4
DEFINE_IO   SDA,        A, 6

.equ    STATE_MEASURING_BIT             = 4
.equ    STATE_MEASURE_COMPLETE_BIT      = 5
.equ    STATE_HEATING_SENSOR_BIT        = 6
.equ    STATE_ERROR_BIT                 = 7

.equ    SENSOR_COUNT                    = 8

.equ    SENSOR_STRUCT_SIZE              = 4
.equ    SENSOR_TEMPERATURE_H_OFFSET     = 0
.equ    SENSOR_TEMPERATURE_L_OFFSET     = 1
.equ    SENSOR_HUMIDITY_H_OFFSET        = 2
.equ    SENSOR_HUMIDITY_L_OFFSET        = 3

.dseg
I2C_SEND_DATA:
DEVICE_TYPE:                            .byte   1
DEVICE_VERSION:                         .byte   1
I2C_SEND_DATA_DEFAULT_START:
WORKING_STATE:                          .byte   1
SENSOR_EXISTS:                          .byte   1
SENSORS_DATA:                           .byte   SENSOR_COUNT * SENSOR_STRUCT_SIZE
SENSORS_HEAT_TIME:
SENSORS_HEAT_TIME_2:                    .byte   1
SENSORS_HEAT_TIME_1:                    .byte   1
SENSORS_HEAT_TIME_0:                    .byte   1
OSCCAL_VALUE:                           .byte   1
I2C_SEND_DATA_END:
.equ    I2C_SEND_DATA_SIZE              = I2C_SEND_DATA_END - I2C_SEND_DATA

I2C_RECV_DATA:
I2C_RECV_DATA_REQUEST:                  .byte   1
I2C_RECV_DATA_ARG_0:                    .byte   1
I2C_RECV_DATA_END:
.equ    I2C_RECV_DATA_SIZE              = I2C_RECV_DATA_END - I2C_RECV_DATA


.eseg
E_I2C_MY_ADDRESS:                       .db     I2C_MY_ADDRESS_DEFAULT
E_FREQUENCY:                            .db     OSCCAL_DEFAULT
;----------------------------------------------------------------------------
.macro  LDI16
    ldi     @0H, (@1) >> 8
    ldi     @0L, (@1) & 0xFF
.endmacro
;----------------------------------------------------------------------------
#endif
