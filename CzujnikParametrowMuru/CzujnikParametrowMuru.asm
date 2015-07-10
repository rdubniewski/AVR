/*
 * CzujnikParametrowMuru.asm
 *
 *  Created: 2013-11-18 10:31:26
 *   Author: Rafal
 */

.include    <tn44def.inc>
.include    "CzujnikParametrowMuru.inc"
.include    "Float_32.inc"
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.macro I2C_SCL_0
    sbi     S_SCL_DDR, S_SCL_BIT
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SCL_0_WAIT
;   rcall   I2C_SCL_0_WAIT_F
;.endmacro
;----------------------------------------------------------------------------
I2C_SCL_0_WAIT_F:
    WAIT_TIMER
    I2C_SCL_0
    START_TIMER_TICKS   SENSOR_I2C_DELAY_TICKS
;    ret
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SCL_1
    cbi S_SCL_DDR, S_SCL_BIT
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SCL_1_WAIT
;   rcall   I2C_SCL_1_WAIT_F
;.endmacro
I2C_SCL_1_WAIT_F:
    WAIT_TIMER
    I2C_SCL_1
    START_TIMER_TICKS   SENSOR_I2C_DELAY_TICKS
;    ret
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SDA_X
    @0      S_SDA_0_DDR, S_SDA_0_BIT
    @0      S_SDA_1_DDR, S_SDA_1_BIT
    @0      S_SDA_2_DDR, S_SDA_2_BIT
    @0      S_SDA_3_DDR, S_SDA_3_BIT
    @0      S_SDA_4_DDR, S_SDA_4_BIT
    @0      S_SDA_5_DDR, S_SDA_5_BIT
    @0      S_SDA_6_DDR, S_SDA_6_BIT
    @0      S_SDA_7_DDR, S_SDA_7_BIT
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SDA_0
    I2C_SDA_X   sbi
.endmacro
;----------------------------------------------------------------------------
.macro I2C_SDA_1
    I2C_SDA_X   cbi
.endmacro
;----------------------------------------------------------------------------

/*
; Wait na timerze 1 16 bit - attiny24-44-84
.macro  START_TIMER_MICROSEC
    .set    TICKS   = ((@0) * FREQUENCY) / 1000000 - 11
    .set    _TCCR1B      = 0 << CS12 | 0 << CS11 | 1 << CS10
    .if ( TICKS > 0xFFFF )
        .set    TICKS   = ((@0) * FREQUENCY) / 8000000 - 1
        .set    _TCCR1B      = 0 << CS12 | 1 << CS11 | 0 << CS10
    .endif
    .if ( TICKS > 0xFFFF )
        .set    TICKS   = ((@0) * FREQUENCY) / 64000000
        .set    _TCCR1B      = 0 << CS12 | 1 << CS11 | 1 << CS10
    .endif
    .if ( TICKS > 0xFFFF )
        .set    TICKS   = ((@0) * FREQUENCY) / 256000000
        .set    _TCCR1B      = 1 << CS12 | 0 << CS11 | 0 << CS10
    .endif
    .if ( TICKS > 0xFFFF )
        .set    TICKS   = ((@0) * FREQUENCY) / 1024000000
        .set    _TCCR1B      = 1 << CS12 | 0 << CS11 | 1 << CS10
    .endif
    .if ( TICKS < 1 )
        .set    TICKS = 1
        .set    _TCCR1B      = 0 << CS12 | 0 << CS11 | 1 << CS10
    .endif    
    ldi     R_TMP_1, TICKS >> 8
    out     OCR1AH, R_TMP_1
    ldi     R_TMP_1, low(TICKS)
    out     OCR1AL, R_TMP_1
    ldi     R_TMP_1, 0
    out     TCNT1H, R_TMP_1
    out     TCNT1L, R_TMP_1
    sbi     TIFR1, OCF1A
    ldi     R_TMP_1, _TCCR1B
    out     TCCR1B, R_TMP_1
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER
    sbis    TIFR1, OCF1A
    rjmp    PC - 1
.endmacro
*/
;----------------------------------------------------------------------------
; Wait na timerze 0 8 bit - attiny24-44-84
.macro  START_TIMER_TICKS
    .set    TICKS   = (@0) - 9
    .set    _TCCR0B      = 0 << CS02 | 0 << CS01 | 1 << CS00
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 8 - 1
        .set    _TCCR0B      = 0 << CS02 | 1 << CS01 | 0 << CS00
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 64
        .set    _TCCR0B      = 0 << CS02 | 1 << CS01 | 1 << CS00
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 256
        .set    _TCCR0B      = 1 << CS02 | 0 << CS01 | 0 << CS00
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 1024
        .set    _TCCR0B      = 1 << CS02 | 0 << CS01 | 1 << CS00
    .endif
    .if ( TICKS < 1 )
        .set    TICKS = 1
        .set    _TCCR0B      = 0 << CS02 | 0 << CS01 | 1 << CS00
    .endif    
    ldi     R_TMP_1, TICKS
    out     OCR0B, R_TMP_1
    ldi     R_TMP_1, 0
    out     TCNT0, R_TMP_1
    ldi     R_TMP_1, 1 << OCF0B
    out     TIFR0, R_TMP_1
    ldi     R_TMP_1, _TCCR0B
    out     TCCR0B, R_TMP_1
.endmacro
;----------------------------------------------------------------------------
.macro  START_TIMER_MICROSEC
    START_TIMER_TICKS   (((@0) * FREQUENCY) / 1000000)
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER
    in      R_TMP_1, TIFR0
    sbrs    R_TMP_1, OCF0B
    rjmp    PC - 2
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER_TICKS
    START_TIMER_TICKS       @0
    WAIT_TIMER
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER_MICROSEC
    START_TIMER_MICROSEC    @0
    WAIT_TIMER
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_SENSOR_SEND_BYTE
    ldi     R_S_SEND_DATA, @0
    rcall   I2C_SENSOR_SEND_BYTE_F
.endmacro
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.cseg

.org    0               rjmp    RESET
.org    OC1Aaddr        sbr     R_CONTROL, 1 << R_CONTROL_HEATING_TIMER_OV_BIT
                        reti
.org    USI_STRaddr     rjmp    USI_I2C_START
.org    USI_OVFaddr     rjmp    USI_I2C_OV

.org    INT_VECTORS_SIZE
RESET:
RESET_SOFT:
    cli

    ; stos
.if ( RAMEND > 0xFF )
    ldi     R_TMP_1, high(RAMEND)
    out     SPH, R_TMP_1
.endif
    ldi     R_TMP_1, low(RAMEND)
    out     SPL, R_TMP_1

    ; ustawienie zegara na 12 MHz
    ldi     R_TMP_1, OSCCAL_DEFAULT
    out     OSCCAL, R_TMP_1
    sts     OSCCAL_VALUE, R_TMP_1

    /*
    rcall   FREQUENCY_TEST
    rcall   LOAD_EE
    rcall   SAVE_FREQUENCY
    ldi     R_TMP_1, 10
    out     OSCCAL, R_TMP_1
    rcall   LOAD_EE
    */

    ; TEST wylicszenie parametrow
    /*
    LDI16   X, 2384 << 2
    sts     SENSORS_DATA + SENSOR_TEMPERATURE_L_OFFSET, XL
    sts     SENSORS_DATA + SENSOR_TEMPERATURE_H_OFFSET, XH
    
    LDI16   X, 1445 << 4
    sts     SENSORS_DATA + SENSOR_HUMIDITY_L_OFFSET, XL
    sts     SENSORS_DATA + SENSOR_HUMIDITY_H_OFFSET, XH
    
    LDI16   Z, SENSORS_DATA
    rcall   CALCULATE_SENSOR_Z ; t: 24.6C, h: 59.9%
    */

    ; Sleep - idle
    ldi     R_TMP_1, 1 << SE | 0 << SM1 | 0 << SM0
    out     MCUCR, R_TMP_1

    rcall   I2C_SENSOR_INIT
    rcall   USI_I2C_INIT
    rcall   LOAD_EE

    ; Zmienne
    clr     R_CONTROL
    ldi     R_TMP_1, 0
    sts     SENSORS_HEAT_TIME_2, R_TMP_1
    sts     SENSORS_HEAT_TIME_1, R_TMP_1
    sts     SENSORS_HEAT_TIME_0, R_TMP_1
    sts     WORKING_STATE, R_TMP_1
    ldi     R_TMP_1, 0xFF
    sts     SENSOR_EXISTS, R_TMP_1

    ; Typ i wercja ukladu
    ldi     R_TMP_1, DEVICE_TYPE_DEF
    sts     DEVICE_TYPE, R_TMP_1
    ldi     R_TMP_1, DEVICE_VERSION_DEF
    sts     DEVICE_VERSION, R_TMP_1
    
    ; konfiguracja timera liczacego sekundy wygrzewania czujnikow
    ldi     R_TMP_2, HEATING_TIMER_OCR_VAL >> 8
    ldi     R_TMP_1, HEATING_TIMER_OCR_VAL & 0xFF
    out     HEATING_TIMER_OCR_H, R_TMP_2
    out     HEATING_TIMER_OCR_L, R_TMP_1
    ldi     R_TMP_1, HEATING_TIMER_CR_OFF_VAL
    out     HEATING_TIMER_CR, R_TMP_1
    in      R_TMP_1, HEATING_TIMER_MSK
    sbr     R_TMP_1, HEATING_TIMER_MSK_VAL
    out     HEATING_TIMER_MSK, R_TMP_1

    rcall   RESET_SENSORS

    ; konfiguracja oszczednosci energii
    ldi     R_TMP_1, 1 << ACD
    out     ACSR, R_TMP_1
    rcall   UPDATE_POWER_SAVE

    rcall   CLEAR_SENSORS_DATA

    rcall   TEST_SENSOR_I2C

    sei


MAIN_LOOP:
    sbrc    R_CONTROL, R_CONTROL_I2C_READ_BYTE_BIT
    rcall   PARSE_I2C_REQUEST

    sbrc    R_CONTROL, R_CONTROL_HEATING_TIMER_OV_BIT
    rcall   INCREMENT_HEAT_COUNTER

    sleep

    rjmp    MAIN_LOOP
;----------------------------------------------------------------------------
; Wysyla na czujniki
TEST_SENSOR_I2C:
    sbic    S_SDA_0_PIN, S_SDA_0_BIT
    ret

    sbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

_TSI2C_LOOP:
    I2C_SENSOR_SEND_BYTE    0b10101010
    rjmp    _TSI2C_LOOP
;----------------------------------------------------------------------------
UPDATE_POWER_SAVE:
    ldi     R_TMP_1, POWER_SAVE_IDLE
    sbrc    R_CONTROL, R_CONTROL_SENSOR_COMMUNICATION_BIT
    andi    R_TMP_1, POWER_SAVE_SENSOR_COMMUNICATION
    sbrc    R_CONTROL, R_CONTROL_HEATING_SENSORS_BIT
    andi    R_TMP_1, POWER_SAVE_HEATING
    out     PRR, R_TMP_1
    ret
;----------------------------------------------------------------------------
INCREMENT_HEAT_COUNTER:
    ; kasowanie flagi przepolnienia
    cbr     R_CONTROL, 1 << R_CONTROL_HEATING_TIMER_OV_BIT

    ; inkrementacja licznika
    ldi     R_TMP_2, 0
    lds     ZL, SENSORS_HEAT_TIME_0
    lds     ZH, SENSORS_HEAT_TIME_1
    lds     R_TMP_1, SENSORS_HEAT_TIME_2
    adiw    Z, 1
    adc     R_TMP_1, R_TMP_2
    sts     SENSORS_HEAT_TIME_0, ZL
    sts     SENSORS_HEAT_TIME_1, ZH
    sts     SENSORS_HEAT_TIME_2, R_TMP_1

    ret
;----------------------------------------------------------------------------
PARSE_I2C_REQUEST:
    cbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT

    ; podzial rozkazow na ilosc argumentow
    lds     R_TMP_1, I2C_RECV_DATA_REQUEST
    cpi     R_I2C_BUF_POINTER_L, I2C_RECV_DATA_REQUEST + 1
    breq    _PIR_0_ARGS

    cpi     R_I2C_BUF_POINTER_L, I2C_RECV_DATA_ARG_0 + 1
    breq    _PIR_1_ARG

    rjmp    _PIR_END

_PIR_0_ARGS:
    ; Pomiar - I2C_REQUEST_START_MEASURE
    cpi     R_TMP_1, I2C_REQUEST_START_MEASURE
    brne    _PIR_I2C_REQUEST_START_MEASURE_END
    rcall   MEASURE
    rjmp    _PIR_END
_PIR_I2C_REQUEST_START_MEASURE_END:

    ; Rozpoczecie wygrzewania czujnikow - I2C_REQUEST_START_HEAT_SENSORS
    cpi     R_TMP_1, I2C_REQUEST_START_HEAT_SENSORS
    brne    _PIR_I2C_REQUEST_START_HEAT_SENSORS_END
    rcall   START_HEAT_SENSORS
    rjmp    _PIR_END
_PIR_I2C_REQUEST_START_HEAT_SENSORS_END:

    ; Zakonczenie wygrzewania czujnikow - I2C_REQUEST_STOP_HEAT_SENSORS
    cpi     R_TMP_1, I2C_REQUEST_STOP_HEAT_SENSORS
    brne    _PIR_I2C_REQUEST_STOP_HEAT_SENSORS_END
    rcall   STOP_HEAT_SENSORS
    rjmp    _PIR_END
_PIR_I2C_REQUEST_STOP_HEAT_SENSORS_END:

    ; Reset ukladu - I2C_REQUEST_RESET
    cpi     R_TMP_1, I2C_REQUEST_RESET
    brne    _PIR_I2C_REQUEST_RESET_END
    cli
    rjmp    RESET_SOFT
_PIR_I2C_REQUEST_RESET_END:

    ; test czestotliwosci
    cpi     R_TMP_1, I2C_REQUEST_TEST_FREQUENCY
    brne    _PIR_I2C_REQUEST_TEST_FREQUENCY_END
    rcall   FREQUENCY_TEST
    rjmp    _PIR_END
    _PIR_I2C_REQUEST_TEST_FREQUENCY_END:

    ; Korekta czestotliwosci zegara inkrementacja
    cpi     R_TMP_1, I2C_REQUEST_FREQUENCY_INCREMENT
    brne    _PIR_I2C_REQUEST_FREQUENCY_INCREMENT_END
    in      R_TMP_1, OSCCAL
    inc     R_TMP_1
    out     OSCCAL, R_TMP_1
    sts     OSCCAL_VALUE, R_TMP_1
    rcall   FREQUENCY_TEST
    rjmp    _PIR_END
_PIR_I2C_REQUEST_FREQUENCY_INCREMENT_END:

    ; Korekta czestotliwosci zegara dekrementacja
    cpi     R_TMP_1, I2C_REQUEST_FREQUENCY_DECREMENT
    brne    _PIR_I2C_REQUEST_FREQUENCY_DECREMENT_END
    in      R_TMP_1, OSCCAL
    dec     R_TMP_1
    out     OSCCAL, R_TMP_1
    sts     OSCCAL_VALUE, R_TMP_1
    rcall   FREQUENCY_TEST
    rjmp    _PIR_END
_PIR_I2C_REQUEST_FREQUENCY_DECREMENT_END:

    ; Korekta zapis ustawionej czestotliwosci do eepromu
    cpi     R_TMP_1, I2C_REQUEST_SAVE_FREQUENCY
    brne    _PIR_I2C_REQUEST_SAVE_FREQUENCY_END
    rcall   SAVE_FREQUENCY
    rjmp    _PIR_END
_PIR_I2C_REQUEST_SAVE_FREQUENCY_END:

_PIR_1_ARG:
    ; Nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS
    cpi     R_TMP_1, I2C_REQUEST_SLAVE_ADDRESS
    brne    _PIR_I2C_REQUEST_SLAVE_ADDRESS_END
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    cbr     R_TMP_1, 0x01
    mov     R_I2C_MY_ADDRESS, R_TMP_1
    rcall   SAVE_I2C_MY_ADDRESS
_PIR_I2C_REQUEST_SLAVE_ADDRESS_END:

    ; Ustawienie czestotliwosci
    cpi     R_TMP_1, I2C_REQUEST_FREQUENCY_SET
    brne    _PIR_I2C_REQUEST_FREQUENCY_SET_END
    out     OSCCAL, R_TMP_1
    sts     OSCCAL_VALUE, R_TMP_1
    rcall   FREQUENCY_TEST
    rjmp    _PIR_END
_PIR_I2C_REQUEST_FREQUENCY_SET_END:

_PIR_END:

    ret
;----------------------------------------------------------------------------
FREQUENCY_TEST:
    I2C_SCL_0
    rcall   FREQUENCY_TEST_WAIT
    nop
    I2C_SCL_1
    rcall   FREQUENCY_TEST_WAIT
    sbrs    R_CONTROL, R_CONTROL_I2C_READ_BYTE_BIT
    rjmp    FREQUENCY_TEST
    ret
;----------------------------------------------------------------------------
FREQUENCY_TEST_WAIT:
    ldi     R_TMP_1, 13
    dec     R_TMP_1
    brne    PC - 1
    ret
;----------------------------------------------------------------------------
RESET_SENSORS:
    clr     R_TMP_1
    sts     WORKING_STATE, R_TMP_1

    sbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika
    I2C_SENSOR_SEND_BYTE   0x03 ; Adres rejestru
    I2C_SENSOR_SEND_BYTE   0x00 ; nic
    rcall   I2C_STOP

    cbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

    ret
;----------------------------------------------------------------------------
START_HEAT_SENSORS:
    lds     R_TMP_1, WORKING_STATE
    sbr     R_TMP_1, 1 << STATE_HEATING_SENSOR_BIT
    sts     WORKING_STATE, R_TMP_1

    ; redukcja energii
    sbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika
    I2C_SENSOR_SEND_BYTE   0x03 ; Adres rejestru
    I2C_SENSOR_SEND_BYTE   0x02 ; Wygrzewanie
    rcall   I2C_STOP

    ; kasowanie licznikow tylko gdy nie bylo grzania
    sbrc    R_CONTROL, R_CONTROL_HEATING_SENSORS_BIT
    rjmp    _SHS_NO_CLEAR_COUNTER
    clr     R_TMP_1
    sts     SENSORS_HEAT_TIME_0, R_TMP_1
    sts     SENSORS_HEAT_TIME_1, R_TMP_1
    sts     SENSORS_HEAT_TIME_2, R_TMP_1
_SHS_NO_CLEAR_COUNTER:

    ; redukcja poboru energii
    sbr     R_CONTROL, 1 << R_CONTROL_HEATING_SENSORS_BIT
    cbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

    ldi     R_TMP_1, 0
    out     HEATING_TIMER_CNT_H, R_TMP_1
    out     HEATING_TIMER_CNT_L, R_TMP_1
    ldi     R_TMP_1, HEATING_TIMER_CR_ON_VAL
    out     HEATING_TIMER_CR, R_TMP_1

    ret
;----------------------------------------------------------------------------
STOP_HEAT_SENSORS:
    lds     R_TMP_1, WORKING_STATE
    sbrs    R_TMP_1, STATE_HEATING_SENSOR_BIT
    rjmp    _SHS_NO_RESET_SENSORS
    cbr     R_TMP_1, 1 << STATE_HEATING_SENSOR_BIT
    sts     WORKING_STATE, R_TMP_1
    rcall   RESET_SENSORS    
_SHS_NO_RESET_SENSORS:

    ldi     R_TMP_1, HEATING_TIMER_CR_OFF_VAL
    out     HEATING_TIMER_CR, R_TMP_1

    ; redukcja poboru energii
    cbr     R_CONTROL, 1 << R_CONTROL_HEATING_SENSORS_BIT
    rcall   UPDATE_POWER_SAVE

    ret
;----------------------------------------------------------------------------
MEASURE:
    ; redukcja poboru energii
    sbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

    lds     R_TMP_1, WORKING_STATE
    sbr     R_TMP_1, 1 << STATE_MEASURING_BIT
    cbr     R_TMP_1, 1 << STATE_MEASURE_COMPLETE_BIT | 0x0F
    sts     WORKING_STATE, R_TMP_1

    ldi     R_TMP_1, 0xFF
    sts     SENSOR_EXISTS, R_TMP_1

    rcall   GET_HUMIDITY
    rcall   GET_TEMPERATURE

        ; redukcja poboru energii
    cbr     R_CONTROL, 1 << R_CONTROL_SENSOR_COMMUNICATION_BIT
    rcall   UPDATE_POWER_SAVE

    sts     SENSOR_EXISTS, R_SENSOR_EXISTS ; podczas dalszej obrobki rejest jest kasowany

    rcall   CALCULATE_SENSORS_DATA_WITH_PACK

    lds     R_TMP_1, WORKING_STATE
    cbr     R_TMP_1, (1 << STATE_MEASURING_BIT) | 0x0F
    sbr     R_TMP_1, 1 << STATE_MEASURE_COMPLETE_BIT
    or      R_TMP_1, R_EXISTING_SENSOR_COUNT
    sts     WORKING_STATE, R_TMP_1

    ret
;----------------------------------------------------------------------------
; przelicza dane z czujnikow na wlasciwe parametry 
; i przenosi je na paczatek listy.
; funkcja uzywa rejestru Z i Y nie odkladajac ich na stos
CALCULATE_SENSORS_DATA_WITH_PACK:

    LDI16   Y, SENSORS_DATA
    movw    Z, Y
    clr     R_EXISTING_SENSOR_COUNT
    ldi     R_LOOP, SENSOR_COUNT
_M_PACK_LOOP:
    sbrc    R_SENSOR_EXISTS, 0
    rjmp    _M_PACK_LOOP_SENSOR_NO_EXSTS
_M_PACK_LOOP_SENSOR_EXSTS:
    ldd     R_TMP_1, Y + 0
    std     Z + 0, R_TMP_1
    ldd     R_TMP_1, Y + 1
    std     Z + 1, R_TMP_1
    ldd     R_TMP_1, Y + 2
    std     Z + 2, R_TMP_1
    ldd     R_TMP_1, Y + 3
    std     Z + 3, R_TMP_1

    rcall   CALCULATE_SENSOR_Z
    adiw    Z, SENSOR_STRUCT_SIZE

    inc     R_EXISTING_SENSOR_COUNT
_M_PACK_LOOP_SENSOR_NO_EXSTS:

    lsr     R_SENSOR_EXISTS
    adiw    Y, SENSOR_STRUCT_SIZE
    dec     R_LOOP
    brne    _M_PACK_LOOP

; ustawienie wartosci nieobecnych sensorow na 0xFFFF
    mov     R_LOOP, R_EXISTING_SENSOR_COUNT
_M_RESET_LOOP:
    cpi     R_LOOP, SENSOR_COUNT
    brsh    _M_RESET_LOOP_EXIT

    rcall   CLEAR_SENSOR_DATA_Z
    adiw    Z, SENSOR_STRUCT_SIZE

    inc     R_LOOP
    rjmp    _M_RESET_LOOP

_M_RESET_LOOP_EXIT:

    ret
;----------------------------------------------------------------------------
; kasuje dane wszystkich czujnikow, ustawia 0xFF
; Uzywa rejestru Z nie odkladjac go na stos
CLEAR_SENSORS_DATA:
    LDI16   Z, SENSORS_DATA  
    ldi     R_LOOP, SENSOR_COUNT
_CSD_LOOP:

    rcall   CLEAR_SENSOR_DATA_Z
    adiw    Z, SENSOR_STRUCT_SIZE

    dec     R_LOOP
    brne    _CSD_LOOP

    ret
;----------------------------------------------------------------------------
GET_TEMPERATURE:
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika
    I2C_SENSOR_SEND_BYTE   0x03 ; Adres rejestru
    ; pomiar temperatury + ewentualne grzanie
    ldi     R_S_SEND_DATA, 0x11
    bst     R_CONTROL, R_CONTROL_HEATING_SENSORS_BIT
    bld     R_S_SEND_DATA, 1
    rcall   I2C_SENSOR_SEND_BYTE_F
    rcall   I2C_STOP

    rcall   WAIT_SENSOR_MEASURE

    ; pobranie wyniku
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika - zapis
    I2C_SENSOR_SEND_BYTE   0x01 ; Adres rejestru
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x81 ; Adres czujnika - odczyt
    rcall   I2C_SENSOR_RECV_BYTE_ACK
    LDI16   Z, SENSORS_DATA + SENSOR_TEMPERATURE_H_OFFSET
    rcall   STORE_SENSORS_PART_Z
    rcall   I2C_SENSOR_RECV_BYTE_NAK
    LDI16   Z, SENSORS_DATA + SENSOR_TEMPERATURE_L_OFFSET
    rcall   STORE_SENSORS_PART_Z
    rcall   I2C_STOP

    ret
;----------------------------------------------------------------------------
GET_HUMIDITY:
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika zapis
    I2C_SENSOR_SEND_BYTE   0x03 ; Adres rejestru
    ; pomiar wilgotnosci + ewentualne grzanie
    ldi     R_S_SEND_DATA, 0x01
    bst     R_CONTROL, R_CONTROL_HEATING_SENSORS_BIT
    bld     R_S_SEND_DATA, 1
    rcall   I2C_SENSOR_SEND_BYTE_F

    rcall   I2C_STOP

    rcall   WAIT_SENSOR_MEASURE

    ; pobranie wyniku
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika - zapis
    I2C_SENSOR_SEND_BYTE   0x01 ; Adres rejestru
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x81 ; Adres czujnika - odczyt
    rcall   I2C_SENSOR_RECV_BYTE_ACK
    LDI16   Z, SENSORS_DATA + SENSOR_HUMIDITY_H_OFFSET
    rcall   STORE_SENSORS_PART_Z
    rcall   I2C_SENSOR_RECV_BYTE_NAK
    LDI16   Z, SENSORS_DATA + SENSOR_HUMIDITY_L_OFFSET
    rcall   STORE_SENSORS_PART_Z
    rcall   I2C_STOP

    ret
;----------------------------------------------------------------------------
WAIT_SENSOR_MEASURE:
    // odczekanie 35 ms na zakonczenie konwersji
    WAIT_TIMER_MICROSEC     15000
    WAIT_TIMER_MICROSEC     20000

    ldi     R_LOOP, 50
_WSM_LOOP:
    push    R_LOOP

    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x80 ; Adres czujnika + zapis
    I2C_SENSOR_SEND_BYTE   0x00 ; Adres rejestru
    rcall   I2C_START
    I2C_SENSOR_SEND_BYTE   0x81 ; Adres czujnika + odczyt
    rcall   I2C_SENSOR_RECV_BYTE_NAK
    rcall   I2C_STOP

    pop     R_LOOP

    ; sprawdzenie czy podlaczone czujniki zakonczyly pomiar,
    ; zakonczenie pomiaru sygnalizuje skasowany bit 0 odczytanego stanu
    ; bity sa zapisane w R_TMP_1 w kolejnosci jak w R_SENSOR_EXISTS
    clr     R_TMP_1
    lsr     R_S_DATA_0
    ror     R_TMP_1
    lsr     R_S_DATA_1
    ror     R_TMP_1
    lsr     R_S_DATA_2
    ror     R_TMP_1
    lsr     R_S_DATA_3
    ror     R_TMP_1
    lsr     R_S_DATA_4
    ror     R_TMP_1
    lsr     R_S_DATA_5
    ror     R_TMP_1
    lsr     R_S_DATA_6
    ror     R_TMP_1
    lsr     R_S_DATA_7
    ror     R_TMP_1

    ; koniec moze nastapic gdy:
    ; czujniki sa nieobezne (bit czujnika R_SENSOR_EXISTS jest 1, brak czujnika)
    ; lub
    ; czujnik zakonczyl pomiar (bit stanu w R_TMP_1 jest 0)
    mov     R_TMP_2, R_SENSOR_EXISTS
    com     R_TMP_2
    and     R_TMP_1, R_TMP_2
    breq    _WSM_LOOP_END

    // odczekanie 2 milisekundy przed kolejnym sprawdzeniem 
    WAIT_TIMER_MICROSEC     2000

    dec     R_LOOP
    brne    _WSM_LOOP
_WSM_LOOP_END:

    ret
;----------------------------------------------------------------------------
.dseg
 TEMPERATURE_TMP_0:     .byte   1
 TEMPERATURE_TMP_1:     .byte   1
 TEMPERATURE_TMP_2:     .byte   1
 TEMPERATURE_TMP_3:     .byte   1

 HUMIDITY_TMP_0:        .byte   1
 HUMIDITY_TMP_1:        .byte   1
 HUMIDITY_TMP_2:        .byte   1
 HUMIDITY_TMP_3:        .byte   1

.cseg
CALCULATE_SENSOR_Z:
    FLOAT_32_PUSH   R_MATH_A
    FLOAT_32_PUSH   R_MATH_B

    ; float t = _Params->Temperature;
    ldd     R_FLOAT_A_U16_1, Z + SENSOR_TEMPERATURE_H_OFFSET
    ldd     R_FLOAT_A_U16_0, Z + SENSOR_TEMPERATURE_L_OFFSET
    ; przesuniecie o 2 bity w prawo
    lsr     R_FLOAT_A_U16_1
    ror     R_FLOAT_A_U16_0
    lsr     R_FLOAT_A_U16_1
    ror     R_FLOAT_A_U16_0
    ;; przeliczenie
    rcall   UINT16_TO_FLOAT_A_F

    ; // przeliczenie wartosci temperatury na stopnie C
    ; t = t / 32.0f - 50.0f;
    ; 1. t = t * (1.0 / 32.0)
    FLOAT_32_LDI    R_MATH_B, 0x3D000000 ; 0.03125
    rcall   MUL_FLOAT_32
    ; 2. t = t + -50.0; 
    FLOAT_32_LDI    R_MATH_B, 0xC2480000 ; -50.0
    rcall   ADD_FLOAT_32
    ; zachowanie wyniku temperatury w zmiennej tymczasowej
    FLOAT_32_STS    TEMPERATURE_TMP, R_MATH_A

    ; float h = _Params->Humidity;
    ldd     R_FLOAT_A_U16_1, Z + SENSOR_HUMIDITY_H_OFFSET
    ldd     R_FLOAT_A_U16_0, Z + SENSOR_HUMIDITY_L_OFFSET
    ; przesuniecie o 4 bity w prawo
    lsr     R_FLOAT_A_U16_1
    ror     R_FLOAT_A_U16_0
    lsr     R_FLOAT_A_U16_1
    ror     R_FLOAT_A_U16_0
    lsr     R_FLOAT_A_U16_1
    ror     R_FLOAT_A_U16_0
    lsr     R_FLOAT_A_U16_1
    ror     R_FLOAT_A_U16_0

    rcall   UINT16_TO_FLOAT_A_F
    ; // przeliczenie wartosci przetwornika na wilgotnosci w %
    ; h = h / 16.0f - 24.0f;
    ; 1. h = h * (1.0 / 16.0 )
    FLOAT_32_LDI    R_MATH_B, 0x3D800000 ; 0.0625
    rcall   MUL_FLOAT_32
    ; 2. h = h + -24.0
    FLOAT_32_LDI    R_MATH_B, 0xC1C00000 ; -24.0
    rcall   ADD_FLOAT_32

    ; Obliczenie wilgotnosci liniowej.
    ; Oryginalny wzor z dokumentacji TH02_V1.1.pdf: 
    ; RHLinear1 = RHValue - ((RHValue * RHValue) * -0.00393 + RHValue * 0.4008 + -4.7844)
    ; wzor po uproszczeniu, uzywany w obliczeniach:
    ; h = h  +  (h * h * 0.00393)[A]  +  (h * -0.4008)[B]  +  4.7844[C]
    ; zachowanie wyniku wilgotnosci w zmiennej tymczasowej
    FLOAT_32_STS    HUMIDITY_TMP, R_MATH_A
    ; 1. (h * -0.4008) -> wynik na stosie
    FLOAT_32_LDI    R_MATH_B, 0xBECD35A8 ; -0.4008
    rcall   MUL_FLOAT_32
    FLOAT_32_PUSH   R_MATH_A
    ; 2. (h * h * 0.00393) -> wynik w R_MATH_A
    FLOAT_32_LDS    R_MATH_A, HUMIDITY_TMP
    FLOAT_32_MOV    R_MATH_B, R_MATH_A
    rcall   MUL_FLOAT_32
    FLOAT_32_LDI    R_MATH_B, 0x3B80C73B ; 0.00393
    rcall   MUL_FLOAT_32    
    ; 3. sumowanie wspolczynnikow
    ; h + [A] -> wynik w R_MATH_A
    FLOAT_32_LDS    R_MATH_B, HUMIDITY_TMP
    rcall   ADD_FLOAT_32
    ; ... + [B] -> wynik w R_MATH_A
    FLOAT_32_POP    R_MATH_B
    rcall   ADD_FLOAT_32
    ; ... + [C] -> wynik w R_MATH_A
    FLOAT_32_LDI    R_MATH_B, 0x409919CE ; 4.7844
    rcall   ADD_FLOAT_32
    ; zachowanie wyniku
    FLOAT_32_STS    HUMIDITY_TMP, R_MATH_A

    ; Kompensacja temperaturowa wilgotnosci wg wzoru z dokumentacji:
    ; h = h + (t - 30.0f)[A] * (h * 0.00237f + 0.1973f)[B]
    ; 1. (h * 0.00237 + 0.1973)[B] -> wynik na stosie
    FLOAT_32_LDI    R_MATH_B, 0x3B1B5200 ; 00237
    rcall   MUL_FLOAT_32
    FLOAT_32_LDI    R_MATH_B, 0x3E4A0903 ; 0.1973
    rcall   ADD_FLOAT_32
    FLOAT_32_PUSH   R_MATH_A
    ; 2. (t - 30.0f)[A] -> wynik w R_MATH_A
    FLOAT_32_LDS    R_MATH_A, TEMPERATURE_TMP
    FLOAT_32_LDI    R_MATH_B, 0xC1F00000 ; -30.0
    rcall   ADD_FLOAT_32
    ; 3. [A] * [B] -> wynik w R_MATH_A
    FLOAT_32_POP    R_MATH_B
    rcall   MUL_FLOAT_32
    ; 4. h + ([A][B]) -> wynik w R_MATH_A
    FLOAT_32_LDS    R_MATH_B, HUMIDITY_TMP
    rcall   ADD_FLOAT_32

    ; wilgotnosc * 10.0
    FLOAT_32_LDI    R_MATH_B, 0x41200000 ; 10.0
    rcall   MUL_FLOAT_32

; TO-DO: korekta wilgotnosci poza zakresem <0;100>

    ; zamiana na int16
    rcall   FLOAT_A_TO_INT16_F
    ; zachowanie w strukturze
    std     Z + SENSOR_HUMIDITY_L_OFFSET, R_FLOAT_A_U16_0
    std     Z + SENSOR_HUMIDITY_H_OFFSET, R_FLOAT_A_U16_1

    ; temperatura * 10.0
    FLOAT_32_LDS    R_MATH_A, TEMPERATURE_TMP
    FLOAT_32_LDI    R_MATH_B, 0x41200000 ; 10.0
    rcall   MUL_FLOAT_32
    ; zamiana na int16
    rcall   FLOAT_A_TO_INT16_F
    ; zachowanie w strukturze
    std     Z + SENSOR_TEMPERATURE_L_OFFSET, R_FLOAT_A_U16_0
    std     Z + SENSOR_TEMPERATURE_H_OFFSET, R_FLOAT_A_U16_1

    FLOAT_32_POP    R_MATH_B
    FLOAT_32_POP    R_MATH_A

    ret
;----------------------------------------------------------------------------
CLEAR_SENSOR_DATA_Z:
    ldi     R_TMP_1, 0xFF
    std     Z + 0, R_TMP_1
    std     Z + 1, R_TMP_1
    std     Z + 2, R_TMP_1
    std     Z + 3, R_TMP_1
    ret
;----------------------------------------------------------------------------
.macro  STORE_ONE_SENSOR_PART_Z
    std     Z + SENSOR_STRUCT_SIZE * @0, R_S_DATA_@0
.endmacro

STORE_SENSORS_PART_Z:
    STORE_ONE_SENSOR_PART_Z     0
    STORE_ONE_SENSOR_PART_Z     1
    STORE_ONE_SENSOR_PART_Z     2
    STORE_ONE_SENSOR_PART_Z     3
    STORE_ONE_SENSOR_PART_Z     4
    STORE_ONE_SENSOR_PART_Z     5
    STORE_ONE_SENSOR_PART_Z     6
    STORE_ONE_SENSOR_PART_Z     7
    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
I2C_SENSOR_INIT:
    I2C_SCL_1
    I2C_SDA_1
    cbi     S_SCL_PORT, S_SCL_BIT
    cbi     S_SDA_0_PORT, S_SDA_0_BIT
    cbi     S_SDA_1_PORT, S_SDA_1_BIT
    cbi     S_SDA_2_PORT, S_SDA_2_BIT
    cbi     S_SDA_3_PORT, S_SDA_3_BIT
    cbi     S_SDA_4_PORT, S_SDA_4_BIT
    cbi     S_SDA_5_PORT, S_SDA_5_BIT
    cbi     S_SDA_6_PORT, S_SDA_6_BIT
    cbi     S_SDA_7_PORT, S_SDA_7_BIT
    ret
;----------------------------------------------------------------------------
I2C_START:
    I2C_SDA_1
    START_TIMER_TICKS   SENSOR_I2C_DELAY_TICKS
    I2C_SCL_1_WAIT
    I2C_SDA_0
    I2C_SCL_0_WAIT
    ret
;----------------------------------------------------------------------------
I2C_STOP:
    I2C_SDA_0
    I2C_SCL_1_WAIT
    WAIT_TIMER_TICKS    SENSOR_I2C_DELAY_TICKS
    I2C_SDA_1
    ret
;----------------------------------------------------------------------------
.macro  S_SDA_GET_BIT
    lsl     R_S_DATA_@0
    sbic    S_SDA_@0_PIN, S_SDA_@0_BIT
    inc     R_S_DATA_@0
.endmacro
;----------------------------------------------------------------------------
I2C_RECV_BIT:
    I2C_SCL_1_WAIT

    WAIT_TIMER

    S_SDA_GET_BIT   0
    S_SDA_GET_BIT   1
    S_SDA_GET_BIT   2
    S_SDA_GET_BIT   3
    S_SDA_GET_BIT   4
    S_SDA_GET_BIT   5
    S_SDA_GET_BIT   6
    S_SDA_GET_BIT   7

    I2C_SCL_0
    START_TIMER_TICKS   SENSOR_I2C_DELAY_TICKS

;   I2C_SCL_0_WAIT

    ret
;----------------------------------------------------------------------------
I2C_SENSOR_SEND_BYTE_F:
    ldi     R_LOOP, 8
_TSB_LOOP:
    lsl     R_S_SEND_DATA
    brcs    _TSB_SEND_BIT_1

_TSB_SEND_BIT_0:
    I2C_SDA_0
    rjmp    _TSB_SEND_BIT_END

_TSB_SEND_BIT_1:
    I2C_SDA_1

_TSB_SEND_BIT_END:

    I2C_SCL_1_WAIT
    I2C_SCL_0_WAIT

    dec     R_LOOP
    brne    _TSB_LOOP

    ; ACK / NAK
    I2C_SDA_1
    rcall   I2C_RECV_BIT

    ; aktualizacja R_SENSOR_EXISTS
    lsr     R_S_DATA_0
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_1
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_2
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_3
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_4
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_5
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_6
    ror     R_SENSOR_EXISTS
    lsr     R_S_DATA_7
    ror     R_SENSOR_EXISTS

    ret
;----------------------------------------------------------------------------
I2C_SENSOR_RECV_BYTE:
    ldi     R_LOOP, 8
_WRB_LOOP:
    rcall   I2C_RECV_BIT
    dec     R_LOOP
    brne    _WRB_LOOP

    ret
;----------------------------------------------------------------------------
I2C_SENSOR_RECV_BYTE_ACK:
    rcall I2C_SENSOR_RECV_BYTE

    ; ACK 
    I2C_SDA_0
    I2C_SCL_1_WAIT
    I2C_SCL_0_WAIT
    I2C_SDA_1

ret
;----------------------------------------------------------------------------
I2C_SENSOR_RECV_BYTE_NAK:
    rcall I2C_SENSOR_RECV_BYTE

    ; NAK
    I2C_SDA_1
    I2C_SCL_1_WAIT
    I2C_SCL_0_WAIT

    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
LOAD_EE:
    ; poczekanie na ewentualny poprzedni zapis
    sbic EECR, EEPE
    rjmp PC-1

    ; Adres
    ldi     R_TMP_1, E_I2C_MY_ADDRESS
    out     EEARL, R_TMP_1
    sbi     EECR, EERE
    in      R_I2C_MY_ADDRESS, EEDR
    ; korekta gdy adres nie jest zapisany
    sbrc    R_I2C_MY_ADDRESS, 0
    ldi     R_I2C_MY_ADDRESS, I2C_MY_ADDRESS_DEFAULT

    ; czestotliwosc
    ldi     R_TMP_1, E_FREQUENCY
    out     EEARL, R_TMP_1
    sbi     EECR, EERE
    in      R_TMP_1, EEDR
    out     OSCCAL, R_TMP_1
    sts     OSCCAL_VALUE, R_TMP_1
    ; korekta gdy adres nie jest zapisany
    sbrc    R_I2C_MY_ADDRESS, 0
    ldi     R_I2C_MY_ADDRESS, I2C_MY_ADDRESS_DEFAULT

    ret
;----------------------------------------------------------------------------
SAVE_FREQUENCY:
    ldi     R_TMP_1, E_FREQUENCY
    out     EEARL, R_TMP_1
    in      R_TMP_1, OSCCAL
    out     EEDR, R_TMP_1
    rjmp    SAVE_EE
;----------------------------------------------------------------------------
SAVE_I2C_MY_ADDRESS:
    ldi     R_TMP_1, E_I2C_MY_ADDRESS
    out     EEARL, R_TMP_1
    out     EEDR, R_I2C_MY_ADDRESS
;----------------------------------------------------------------------------
SAVE_EE:
    ; poczekanie na poprzedni zapis
    sbic EECR, EEPE
    rjmp PC-1

    cli
    sbi     EECR, EEMPE
    sbi     EECR, EEPE
    sei

    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;       Obsluga I2C
.macro  I2C_BYTE_RECEIVED
    sbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
.endmacro
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.include    "Float_32.asm"
.include    "I2CTinySlaveMacro1.inc"
.include    "I2CTinySlave.asm"
