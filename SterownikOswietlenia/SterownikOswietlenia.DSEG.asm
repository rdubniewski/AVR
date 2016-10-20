
.dseg

; licznik co ile taktow timera bedzie zmiana wartosci danych LED
TIMER_SEND_LED_DATA_COUNT:              .byte   1
TIMER_CHECK_BUTTONS_COUNT:              .byte   1

I2C_SEND_DATA:
DEVICE_TYPE:                            .byte   1
DEVICE_VERSION:                         .byte   1

I2C_REQUEST_RESULT:                     .byte   1
WORKING_RESULT:                         .byte   1

I2C_SEND_DATA_DEFAULT_START:

BUTTON_STATE_COUNTER:                   .byte   BUTTON_COUNT_MAX * 2

; Tablica iloœci ledow w grupach
LED_GROUP_LEN_TAB:                      .byte   8

; Tablica wartoœci LED do wyœwietleia
LED_DATA_OUT:                           .byte   LED_DATA_COUNT_MAX
LED_DATA_OUT_END:

LED_SECTION_COUNT:                      .byte   1

; Obszar danych sekcji
LED_SECTION_0:
LED_SECTION_0_GROUP:                    .byte   1
LED_SECTION_0_STATE_3:                  .byte   1
LED_SECTION_0_STATE_2:                  .byte   1
LED_SECTION_0_STATE_1:                  .byte   1
LED_SECTION_0_STATE_0:                  .byte   1
LED_SECTION_0_DATA_SKIP:                .byte   1
LED_SECTION_0_COUNTER_H:                .byte   1
LED_SECTION_0_COUNTER_L:                .byte   1
LED_SECTION_0_RESERVED_3:               .byte   1
LED_SECTION_0_RESERVED_2:               .byte   1
LED_SECTION_0_RESERVED_1:               .byte   1
LED_SECTION_0_RESERVED_0:               .byte   1
LED_SECTION_0_DATA:                     .byte   1
LED_SECTIONS_NEXT_DATA:                 .byte   500
LED_SECTIONS_END:

.equ    LED_SECTION_HEADER_SIZE                     = LED_SECTION_0_DATA - LED_SECTION_0
.equ    LED_SECTION_STATE_H_STOP_INCREMENT_BIT      = 7

I2C_SEND_DATA_END:
.equ    I2C_SEND_DATA_SIZE              = I2C_SEND_DATA_END - I2C_SEND_DATA

I2C_RECV_DATA:
I2C_RECV_DATA_REQUEST:                  .byte   1
I2C_RECV_DATA_ARGS:                     .byte   4 + LED_DATA_COUNT_MAX
I2C_RECV_DATA_END:
.equ    I2C_RECV_DATA_SIZE              = I2C_RECV_DATA_END - I2C_RECV_DATA

