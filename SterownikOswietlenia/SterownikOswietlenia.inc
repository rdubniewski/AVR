#ifndef _SterownikOswietlenia_inc_
#define _SterownikOswietlenia_inc_

.include    "I2C_DeviceTypes.inc"

.equ    DEVICE_TYPE_DEF                 = DEVICE_LIGHTING_CONTROLER_TYPE
.equ    DEVICE_VERSION_DEF              = 0x10

.equ    FREQUENCY                       = 8000000
; Domyslna licznik dla PLL by wstepnie ustawiæ 16MHz
.equ    OSCCAL_DEFAULT                  = 220


.equ    I2C_MY_ADDRESS_DEFAULT          = DEVICE_LIGHTING_CONTROLER_I2C_ADDRES

.equ    I2C_REQUEST_SLAVE_ADDRESS                   = 0x81
.equ    I2C_REQUEST_SAVE_EE                         = 0xA0 ; bity 3:0 okreslaja to co zostanie zapisane
.equ        I2C_REQUEST_SAVE_EE_I2C_ADDRESS_BIT         = 0x00
.equ        I2C_REQUEST_SAVE_EE_OSCCAL_VALUE_BIT        = 0x01
.equ        I2C_REQUEST_SAVE_EE_POINT_COUNT_BIT         = 0x02
.equ        I2C_REQUEST_SAVE_EE_SECTIONS_BIT            = 0x03
.equ        I2C_REQUEST_SAVE_EE_MASK                    = 0xF0
.equ    I2C_REQUEST_SET_POINT_COUNT                 = 0xC1
.equ    I2C_REQUEST_SET_SECTION_CONTROL             = 0xC4 ; bity 1:0 okreslaja numer sekcji
.equ        I2C_REQUEST_SET_SECTION_CONTROL_MASK        = ~0x03
.equ    I2C_REQUEST_SET_SECTION_DATA                = 0xC8 ; bity 1:0 okreslaja numer sekcji
.equ        I2C_REQUEST_SET_SECTION_DATA_MASK           = ~0x03
.equ    I2C_REQUEST_RESET                           = 0x88


.equ    LED_DATA_COUNT_MAX              = 32
.equ    BUTTON_COUNT_MAX                = 9

;------------ !!!!!!!!!!!!!!!!!!!!1---------------- 
; r0 - r5 jest zajete na wynik mnozenia dla RGB.
;
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

#define R_MUL_A_0                       r16
#define R_MUL_A_1                       r17
#define R_MUL_A_2                       r18
#define R_MUL_B_0                       r20

#define R_POINTER_A_L                   YL
#define R_POINTER_A_H                   YH
#define R_POINTER_A                     Y

#define R_POINTER_B_L                   ZL
#define R_POINTER_B_H                   ZH
#define R_POINTER_B                     Z

.def    R_I2C_FLAGS                     = r25
.def    R_I2C_TMP                       = r24
.def    R_I2C_MY_ADDRESS_L              = r6
;.def    R_I2C_MY_ADDRESS                = r7
#define R_I2C_BUF_POINTER_L             XL
#define R_I2C_BUF_POINTER_H             XH
#define R_I2C_BUF_POINTER               X
.equ    I2C_STORE_R_TMP                 = 0
.equ    I2C_START_STORE_SREG            = 1

; zezwolenie na adresowanie odczytywanego rejestru zakonczone bitem STOP
.equ    I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS    = 1

; Zadania I2C



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

;DEFINE_IO   LED_CLK,        B, 0
;DEFINE_IO   LED_DATA,       B, 1
DEFINE_IO   TWI_SCL,        C, 5
DEFINE_IO   TWI_SDA,        C, 4
DEFINE_IO   BUTTON_H_0,     B, 0
DEFINE_IO   BUTTON_H_1,     B, 1
DEFINE_IO   BUTTON_H_2,     B, 2
DEFINE_IO   BUTTON_V_0,     B, 4
DEFINE_IO   BUTTON_V_1,     B, 6
DEFINE_IO   BUTTON_V_2,     B, 7
DEFINE_IO   LED_POWER,      D, 0
DEFINE_IO   LED_SPI_MOSI,   B, 3
DEFINE_IO   LED_SPI_SCK,    B, 5

.dseg

.dseg

; licznik co ile taktow timera bedzie zmiana wartosci danych LED
TIMER_SEND_LED_DATA_COUNT:              .byte   1
TIMER_CHECK_BUTTONS_COUNT:              .byte   1

I2C_SEND_DATA:
DEVICE_TYPE:                            .byte   1
DEVICE_VERSION:                         .byte   1

I2C_SEND_DATA_DEFAULT_START:

;LED_R:                                  .byte   1
;LED_G:                                  .byte   1
;LED_B:                                  .byte   1
BUTTON_STATE_COUNTER:                   .byte   BUTTON_COUNT_MAX * 2

LED_DATA_COUNT:                         .byte   1
; Obliczone wartosci 
LED_DATA_OUT:                           .byte   LED_DATA_COUNT_MAX

LED_SECTIONS:
LED_SECTION_0:
LED_SECTION_0_STATE_H:                  .byte   1
LED_SECTION_0_STATE_L:                  .byte   1
LED_SECTION_0_DATA_SKIP:                .byte   1
LED_SECTION_0_COUNTER:
LED_SECTION_0_COUNTER_H:                .byte   1
LED_SECTION_0_COUNTER_L:                .byte   1
LED_SECTION_0_DATA:                     .byte   LED_DATA_COUNT_MAX

LED_SECTION_1:
LED_SECTION_1_STATE_H:                  .byte   1
LED_SECTION_1_STATE_L:                  .byte   1
LED_SECTION_1_DATA_SKIP:                .byte   1
LED_SECTION_1_COUNTER:
LED_SECTION_1_COUNTER_H:                .byte   1
LED_SECTION_1_COUNTER_L:                .byte   1
LED_SECTION_1_DATA:                     .byte   LED_DATA_COUNT_MAX

LED_SECTION_2:
LED_SECTION_2_STATE_H:                  .byte   1
LED_SECTION_2_STATE_L:                  .byte   1
LED_SECTION_2_DATA_SKIP:                .byte   1
LED_SECTION_2_COUNTER:
LED_SECTION_2_COUNTER_H:                .byte   1
LED_SECTION_2_COUNTER_L:                .byte   1
LED_SECTION_2_DATA:                     .byte   LED_DATA_COUNT_MAX

LED_SECTIONS_END:

.equ    LED_SECTION_STATE_H_STOP_INCREMENT_BIT      = 7

OSCCAL_VALUE:                           .byte   1
I2C_SEND_DATA_END:
.equ    I2C_SEND_DATA_SIZE              = I2C_SEND_DATA_END - I2C_SEND_DATA

I2C_RECV_DATA:
I2C_RECV_DATA_REQUEST:                  .byte   1
I2C_RECV_DATA_ARGS:                     .byte   LED_DATA_COUNT_MAX
I2C_RECV_DATA_END:
.equ    I2C_RECV_DATA_SIZE              = I2C_RECV_DATA_END - I2C_RECV_DATA


.equ    BUTTON_STATE_ON_BIT             = 3

.equ    LED_SECTIONS_SIZE               = LED_SECTIONS_END - LED_SECTIONS

.eseg
E_I2C_MY_ADDRESS:                       .byte   1
E_I2C_MY_ADDRESS_L:                     .byte   1
E_OSCCAL_VALUE:                         .byte   1
E_LED_DATA_COUNT:                       .byte   1
E_LED_SECTIONS:                         .byte   LED_SECTIONS_SIZE

#endif
