#ifndef _SterownikOswietlenia_inc_
#define _SterownikOswietlenia_inc_

.include    "I2C_DeviceTypes.inc"

.equ    DEVICE_TYPE_DEF                 = DEVICE_LIGHTING_CONTROLER_TYPE
.equ    DEVICE_VERSION_DEF              = 0x10

.equ    FREQUENCY                       = 12000000

.equ    I2C_MY_ADDRESS_DEFAULT          = DEVICE_LIGHTING_CONTROLER_I2C_ADDRES

; konfiguracja timera kontroli - timer1
.equ    T_FREQUENCY                                 = 200
.equ    T_PRESCALER                                 = 1
.equ    T_PRESCALER_CS                              = 0 << CS12 | 0 << CS11 | 1 << CS10
.equ    T_VALUE                                     = FREQUENCY / T_FREQUENCY / T_PRESCALER - 1

.equ    TIMER_CHECK_BUTTONS_COUNT_DEFAULT           = T_FREQUENCY / 20 ; 20/sec
.equ    TIMER_SEND_LED_DATA_COUNT_DEFAULT           = T_FREQUENCY / 50 ; 50/sec

; Zadania I2C
.equ    I2C_REQUEST_SLAVE_ADDRESS                   = 0x81
.equ    I2C_REQUEST_SAVE_EE                         = 0xA0 ; bity 3:0 okreslaja to co zostanie zapisane
.equ        I2C_REQUEST_SAVE_EE_I2C_ADDRESS_BIT         = 0
.equ        I2C_REQUEST_SAVE_EE_DATA_BIT                = 1
;.equ        I2C_REQUEST_SAVE_EE_OSCCAL_VALUE_BIT        = 2
.equ        I2C_REQUEST_SAVE_EE_MASK                    = 0xF8

.equ    I2C_REQUEST_SET_GROUP_SIZE                  = 0xC1

.equ    I2C_REQUEST_ADD_SECTION                     = 0xC2

.equ    I2C_REQUEST_SET_SECTION_CONTROL             = 0xC4

.equ    I2C_REQUEST_SET_SECTION_DATA                = 0xC8

.equ    I2C_REQUEST_DELETE_SECTION                  = 0xC5

.equ    I2C_REQUEST_CLEAR_SECTIONS                  = 0xCA

.equ    I2C_REQUEST_RESET                           = 0x88


.equ    LED_DATA_COUNT_MAX              = 150
.equ    LED_SECTION_COUNT_MAX           = 33
.equ    BUTTON_COUNT_MAX                = 25

;------------ !!!!!!!!!!!!!!!!!!!!1---------------- 
.def    R_TIMER_CHECK_BUTTONS_COUNTER   = r9
.def    R_TIMER_SEND_LED_DATA_COUNTER   = r10
.def    R_I2C_TWCR_EA1                  = r11
.def    R_I2C_TWCR_EA0                  = r12
.def    R_FF                            = r13
.def    R_SREG_INTERRUPT_STORE          = r14
.def    R_ZERO                          = r15
.def    R_TMP_1                         = r16
.def    R_TMP_2                         = r17
.def    R_TMP_3                         = r18
.def    R_DATA                          = r19
.def    R_CONTROL                       = r21
    .equ    R_CONTROL_I2C_READ_BYTE_BIT             = 0
    .equ    R_CONTROL_TIMER_BIT                     = 1
    .equ    R_LED_POWER_BIT                         = 2
.def    R_LOOP                          = r22
.def    R_COUNTER                       = r23

#define R_POINTER_A_L                   YL
#define R_POINTER_A_H                   YH
#define R_POINTER_A                     Y

#define R_POINTER_B_L                   ZL
#define R_POINTER_B_H                   ZH
#define R_POINTER_B                     Z

.def    R_I2C_TMP                       = r24
.def    R_I2C_TMP_2                     = r25
.def    R_I2C_MY_ADDRESS_L              = r6
;.def    R_I2C_MY_ADDRESS                = r7
#define R_I2C_BUF_POINTER_L             XL
#define R_I2C_BUF_POINTER_H             XH
#define R_I2C_BUF_POINTER               X
.equ    I2C_STORE_R_TMP                 = 0
.equ    I2C_START_STORE_SREG            = 1

; zezwolenie na adresowanie odczytywanego rejestru zakonczone bitem STOP
.equ    I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS    = 1


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

DEFINE_IO   BUTTON_H_0,     A, 1
DEFINE_IO   BUTTON_H_1,     A, 3
DEFINE_IO   BUTTON_H_2,     A, 5
DEFINE_IO   BUTTON_H_3,     A, 7
DEFINE_IO   BUTTON_H_4,     C, 6
DEFINE_IO   BUTTON_V_0,     A, 0
DEFINE_IO   BUTTON_V_1,     A, 2
DEFINE_IO   BUTTON_V_2,     A, 4
DEFINE_IO   BUTTON_V_3,     A, 6
DEFINE_IO   BUTTON_V_4,     C, 7
DEFINE_IO   LED_SDO,        C, 2
.equ        LED_CKO_PORT    = PORTD
.equ        LED_CKO_DDR     = DDRD
DEFINE_IO   LED_POWER,      C, 5
DEFINE_IO   POWER_IO_0,     C, 4

DEFINE_IO   TEST_FREQUENCY, B, 2


.equ    BUTTON_STATE_ON_BIT             = 3


#endif
