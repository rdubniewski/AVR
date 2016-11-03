/*
 * SterownikZaworu.asm
 *
 *  Created: 2014-01-04 19:31:09
 *   Author: Rafal
 */ 

.include    <tn25def.inc>
.include    "SterownikZaworu.inc"
.include    "OWireMaster.inc"
.include    "DS18B20.inc"
.include    "Wait_Tiny25_Timer0.inc"

#define WAIT_MICROSEC_OWIRE_MASTER              WAIT_MICROSEC_TINY25_TIMER0
#define WAIT_MICROSEC_MINUS_TICKS_OWIRE_MASTER  WAIT_MICROSEC_MINUS_TICKS_TINY25_TIMER0

.cseg
.org        0x0             rjmp    RESET

.org        OVF1addr        ; oznaczenie z¹dania pomiaru albo zliczania timera
                            .if     MEASURE_TIMER_TICKS == 1
                                sbr     R_CONTROL, 1 << R_CONTROL_CHECK_MOTOR_BIT
                            .else
                                sbr     R_CONTROL, 1 << R_CONTROL_CHECK_TIMER_BIT
                            .endif
                            reti

.org        USI_STARTaddr   rjmp    USI_I2C_START
.org        USI_OVFaddr     rjmp    USI_I2C_OV
.org        INT_VECTORS_SIZE


RESET:
RESET_SOFT:
    cli

    ; ZEGAR
    ldi     R_TMP_1, 1 << CLKPCE
    ldi     R_TMP_2, CLKPR_DEF
    out     CLKPR, R_TMP_1
    out     CLKPR, R_TMP_2

    ; zainicjowanie stosu
.ifdef  SPH
    ldi     R_TMP_1, high(RAMEND)
    out     SPH, R_TMP_1
.endif
    ldi     R_TMP_1, low(RAMEND)
    out     SPL, R_TMP_1
    
    ; zainicjowanie portow
    clr     R_TMP_1
    out     DDRB, R_TMP_1
    out     PORTB, R_TMP_1
.ifdef  MOTOR_DDR
    cbi     MOTOR_DDR, MOTOR_BIT
    cbi     MOTOR_PORT, MOTOR_BIT
.else
    cbi     MOTOR_RIGHT_PORT, MOTOR_RIGHT_BIT
    sbi     MOTOR_RIGHT_DDR, MOTOR_RIGHT_BIT
    cbi     MOTOR_LEFT_PORT, MOTOR_LEFT_BIT
    sbi     MOTOR_LEFT_DDR, MOTOR_LEFT_BIT
.endif
    OWIRE_MASTER_1

    /*
    ldi     R_TMP_1, 0xFF
    ldi     R_TMP_2, high(RAMEND + 1)
    ldi     R_POINTER_H, high(SRAM_START)
    ldi     R_POINTER_L, low(SRAM_START)
    st      R_POINTER+, R_TMP_1
    cpi     R_POINTER_L, low(RAMEND + 1)
    cpc     R_POINTER_H, R_TMP_2
    brlo    PC - 3
    ; kasowanie pamieci
    */

    ; zmienne
    clr     R_ZERO
    clr     R_CONTROL
    ; Typ i wercja ukladu
    ldi     R_TMP_1, DEVICE_TYPE_DEF
    sts     DEVICE_TYPE, R_TMP_1
    ldi     R_TMP_1, DEVICE_VERSION_DEF
    sts     DEVICE_VERSION, R_TMP_1
    ; domyslne
    ldi     R_TMP_1, TEMPERATURE_REQUEST_DEFAULT
    sts     TEMPERATURE_REQUEST, R_TMP_1
    ldi     R_TMP_1, TEMPERATURE_IN_MAX_DEFAULT
    sts     TEMPERATURE_IN_MAX, R_TMP_1
    ; zerowanie
    sts     WORKING_STATE, R_ZERO
    sts     MOTOR_ENABLED_COUNTER_H, R_ZERO
    sts     MOTOR_ENABLED_COUNTER_L, R_ZERO
    ldi     R_TMP_1, MESAURE_FREQUENCY
    mov     R_MOTOR_ENABLED_TIMER_COUNTER, R_TMP_1
    clr     R_MOTOR_PWM_COUNTER_PERIOD
    clr     R_MOTOR_PWM_COUNTER
    
    ; konfigurowanie oszczednosci enargii
    sbi     ACSR, ACD
    ldi     R_TMP_1, 0 << PRTIM0 | 1 << PRADC
    out     PRR, R_TMP_1

    ; wlaczenie usypiania procesora.
    ; nie dziala wybudzanie z timera1 w trybie asynchronicznym
    in      R_TMP_1, MCUCR
    sbr     R_TMP_1, 1 << SE
    cbr     R_TMP_1, 0 << SM1  |  0 << SM0 
    out     MCUCR, R_TMP_1

    ; inicjowanie I2C
    rcall   USI_I2C_INIT

    ; wczytanie konfiguracji
    rcall   LOAD_FROM_EE

    ; Wyszukanie sensorów gdy w konfiguracji ich nie bylo
    lds     R_TMP_1, SENSOR_COUNT
    cpi     R_TMP_1, 1
    brsh    PC + 2
    rcall   SEARCH_SENSORS

    ; konfigurowanie timera
    in      R_TMP_1, TIMSK
    sbr     R_TMP_1, TIMER_MASK_DEF
    out     TIMSK, R_TMP_1    
    ldi     R_TMP_1, TIMER_OCR_DEF
    out     TIMER_OCR, R_TMP_1
.if     MEASURE_TIMER_TICKS > 1
    ldi     R_TIMER_COUNTER, MEASURE_TIMER_TICKS
.endif
    ; uruchomienie timera
    lds     R_TMP_1, TIMER_CONTROL_1
    sbr     R_TMP_1, TIMER_CONTROL_1_DEF
    out     TIMER_CONTROL_1, R_TMP_1
    lds     R_TMP_1, TIMER_CONTROL_2
    sbr     R_TMP_1, TIMER_CONTROL_2_DEF
    out     TIMER_CONTROL_2, R_TMP_1

;    rcall   SEARCH_SENSORS
;    rjmp    PC - 1

;    TEST_LOOP:
;    OWIRE_MASTER_1
;    WAIT_MICROSEC 500
;    OWIRE_MASTER_0
;    WAIT_MICROSEC 500
;    rjmp TEST_LOOP
    

    sei

//rcall   SAVE_TO_EE

    ; praca
    rcall   CONFIGURE_SENSORS
    rcall   START_MEASURE

;    rcall   CHECK_MOTOR
;    rcall   READ_OTHER_SENSORS
;    ; wystartowanie kolejnego pomiaru
;    rcall   CONFIGURE_SENSORS
;    rcall   START_MEASURE

MAIN_LOOP:
    ; sprawdzenie czy przyszedl komunikat z timera
.if     MEASURE_TIMER_TICKS > 1
    sbrc    R_CONTROL, R_CONTROL_CHECK_TIMER_BIT
    rcall   CHECK_TIMER
.endif


/*
    WAIT_MICROSEC   20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
    WAIT_MILISEC	20
*/

    ; Sterowanie silnikiem, pomiary dodatkowych czujnikow
    sbrs    R_CONTROL, R_CONTROL_CHECK_MOTOR_BIT
    rjmp  MAIN_LOOP_NO_CHEC_MOTORS
    ; Wyszukanie sensorów gdy w konfiguracji ich nie bylo
    lds     R_TMP_1, SENSOR_COUNT
    cpi     R_TMP_1, 1
    brsh    PC + 2
    rcall   SEARCH_SENSORS
    rcall   CHECK_MOTOR
    rcall   READ_OTHER_SENSORS
    ; wystartowanie kolejnego pomiaru
    rcall   CONFIGURE_SENSORS
    rcall   START_MEASURE
MAIN_LOOP_NO_CHEC_MOTORS:

    ; przetwarzainie zadania z I2C
    sbrc    R_CONTROL, R_CONTROL_I2C_READ_BYTE_BIT
    rcall   I2C_CHECK_REQUEST

    sleep

    rjmp    MAIN_LOOP
;----------------------------------------------------------------------------
.if     MEASURE_TIMER_TICKS > 1

CHECK_TIMER:
    ; wylaczenie flagi timera
    cbr     R_CONTROL, 1 << R_CONTROL_TIMER_MEASURE_OVERFLOW_BIT
    ; sbr     R_TMP_1, 1 << TIMER_OV_FLAG
    ; out     TIFR, R_TMP_1

    dec     R_TIMER_COUNTER
    brne    _T_END
    
    ldi     R_TIMER_COUNTER, MEASURE_TIMER_TICKS
    sbr     R_CONTROL, 1 << R_CONTROL_CHECK_MOTOR_BIT
    
_T_END:

    ret

.endif
;----------------------------------------------------------------------------
; Wysyla do czujnikow konfiguracje precyzji temperatury.
CONFIGURE_SENSORS:
    sts     DS18B20_SCRATCHPAD_BYTE_1, R_ZERO
    sts     DS18B20_SCRATCHPAD_BYTE_2, R_ZERO
    ldi     R_TMP_1, DS18B20_SCRATCHPAD_CONFIG_9_BIT
    sts     DS18B20_SCRATCHPAD_CONFIG, R_TMP_1
    rcall   OWIRE_MASTER_DETECT_PRESENCE
    rcall   OWIRE_MASTER_SKIP_ROM
    rcall   DS18B20_WRITE_SCRATCHPAD
    ret
;----------------------------------------------------------------------------
SEARCH_SENSORS:
    clr     R_SENSOR_INDEX
    ldi     R_POINTER_L, low(SENSOR_ROMS)
    ldi     R_POINTER_H, high(SENSOR_ROMS)
    rcall   OWIRE_MASTER_SEARCH_ROM
    sts     SENSOR_COUNT, R_SENSOR_INDEX
    clr     R_SENSOR_INDEX
    ret
;----------------------------------------------------------------------------
OWIRE_ROM_FOUND:
    ; Sprawdzenie czy podlaczony jest wlasciwy czujnik
    lds     R_TMP_1, OWIRE_ROM_FAMILY_CODE
    cpi     R_TMP_1, DS18B20_ROM_FAMILY_CODE
    brne    _ORF_END

    ; sprawdzenie skonczylo sie miejsce w tablicy czujnikow.
    cpi     R_SENSOR_INDEX, MAX_SENSOR_COUNT
    brsh    _ORF_END

    ; Wlasiwy czujnik
    lds     R_TMP_1, OWIRE_ROM_ID + 0
    st      R_POINTER +, R_TMP_1
    lds     R_TMP_1, OWIRE_ROM_ID + 1
    st      R_POINTER +, R_TMP_1
    lds     R_TMP_1, OWIRE_ROM_ID + 2
    st      R_POINTER +, R_TMP_1
    lds     R_TMP_1, OWIRE_ROM_ID + 3
    st      R_POINTER +, R_TMP_1
    lds     R_TMP_1, OWIRE_ROM_ID + 4
    st      R_POINTER +, R_TMP_1
    lds     R_TMP_1, OWIRE_ROM_ID + 5
    st      R_POINTER +, R_TMP_1

    inc     R_SENSOR_INDEX

_ORF_END:
    ret
;----------------------------------------------------------------------------
CHECK_MOTOR:
    cbr     R_CONTROL,  1 << R_CONTROL_CHECK_MOTOR_BIT  |   \
                        1 << R_CONTROL_MOTOR_STOPPED_BIT

    ; Stan pracy budowany jest na R_WORKING_STATE
    clr     R_WORKING_STATE

    ; Bit odwrocenia kierunku
    bst     R_CONTROL, R_CONTROL_CHANGE_DIRECTION_BIT
    bld     R_WORKING_STATE, WORKING_STATE_CHANGE_DIRECTION_BIT

    ; pobranie temperatury zasilania
    lds     R_DATA, SENSOR_INDEXES
    andi    R_DATA, 0x0F
    ; sprawdzenie czy indeks czujnika zasilania jest poprawny
    lds     R_TMP_1, SENSOR_COUNT
    cp      R_DATA, R_TMP_1
    brlo    _CM_IN_CORRECT
    ; bledny indeks czujnika zasilania
    sbr     R_WORKING_STATE, 0b10000000
    rjmp    _CM_MOTOR_STOP
_CM_IN_CORRECT:
    ; poprawna temperatura zasilania
    ; zachowanie indeksu czujnika zasilania, pzyda sie pare linii dalej
    mov     R_SENSOR_IN_INDEX, R_DATA
    rcall   READ_TEMPERATURE

    ; sprawdzenie czy temperatura zasilania nie jest zbyt wysoka
    lds     R_TMP_1, TEMPERATURE_IN_MAX
    cp      R_ZERO, R_TEMPERATURE_L
    cpc     R_TMP_1, R_TEMPERATURE_H
    brlo    _CM_TO_HIGH
    breq    _CM_MOTOR_STOP

    ; pobranie indeksu czujnika powrotu
    lds     R_DATA, SENSOR_INDEXES
    swap    R_DATA
    andi    R_DATA, 0x0F
    ; sprawdzenie czy czujnik zostal okreslony
    cpi     R_DATA, 0x0F
    breq    _CM_OUT_NOT_DEFINED
    ; czujnik powrotu zostal okreslony
    ; sprawdzenie czy czujnik powrotu ma wlasciwy indeks
    lds     R_TMP_1, SENSOR_COUNT
    cp      R_DATA, R_TMP_1
    brlo    _CM_OUT_CORRECT
    ; bledny indeks czujnika powrotu
    sbr     R_WORKING_STATE, 0b01000000
    rjmp    _CM_MOTOR_STOP
_CM_OUT_CORRECT:
    ; zachowanie pomiaru czujnika zasilania do usrednienia
    mov     R_TEMPERATURE_H_TMP, R_TEMPERATURE_H
    mov     R_TEMPERATURE_L_TMP, R_TEMPERATURE_L
    lsr     R_TEMPERATURE_H_TMP
    ror     R_TEMPERATURE_L_TMP
    ; zachowanie indeksu czujnika powrotu, pzyda sie pare linii dalej
    mov     R_SENSOR_OUT_INDEX, R_DATA
    ; odczyt temperatury
    rcall   READ_TEMPERATURE
    ; usrednienie wyniku
    lsr     R_TEMPERATURE_H
    ror     R_TEMPERATURE_L
    add     R_TEMPERATURE_L, R_TEMPERATURE_L_TMP
    adc     R_TEMPERATURE_H, R_TEMPERATURE_H_TMP
_CM_OUT_NOT_DEFINED:
_CM_GET_TEMPERATURE_END:

    ; Porownanie temperatury
    lds     R_TMP_1, TEMPERATURE_REQUEST
    sub     R_TEMPERATURE_L, R_ZERO
    sbc     R_TEMPERATURE_H, R_TMP_1
    brmi    _CM_TO_LOW
    breq    _CM_MOTOR_STOP

_CM_TO_HIGH:
    ; Sprawdzenie czy silnik ma pracowac pulsacyjnie
    rcall   CHECK_MOTOR_PWN
    sbrc    R_CONTROL, R_CONTROL_MOTOR_STOPPED_BIT
    rjmp    _CM_MOTOR_STOP_NO_RESET_PWM_COUNTER
    ; sprawdzenie czy cilnik kraci sie za dlugo w jednym kierunku
    ldi     R_DATA, 1 << R_CONTROL_PREV_MOTOR_LEFT_BIT
    rcall   CHECK_STOP_MOTOR
    sbrc    R_CONTROL, R_CONTROL_MOTOR_STOPPED_BIT
    rjmp    _CM_MOTOR_STOP_NO_RESET_COUNTER
    ; wlaczenie silnika
    sbrc    R_CONTROL, R_CONTROL_CHANGE_DIRECTION_BIT
    rjmp    _CM_MOTOR_RIGHT
    rjmp    _CM_MOTOR_LEFT

_CM_TO_LOW:
    ; Sprawdzenie czy silnik ma pracowac pulsacyjnie
    rcall   CHECK_MOTOR_PWN
    sbrc    R_CONTROL, R_CONTROL_MOTOR_STOPPED_BIT
    rjmp    _CM_MOTOR_STOP_NO_RESET_PWM_COUNTER
    ; sprawdzenie czy cilnik kraci sie za dlugo w jednym kierunku
    ldi     R_DATA, 1 << R_CONTROL_PREV_MOTOR_RIGHT_BIT
    rcall   CHECK_STOP_MOTOR
    sbrc    R_CONTROL, R_CONTROL_MOTOR_STOPPED_BIT
    rjmp    _CM_MOTOR_STOP_NO_RESET_COUNTER
    ; wlaczenie silnika
    sbrc    R_CONTROL, R_CONTROL_CHANGE_DIRECTION_BIT
    rjmp    _CM_MOTOR_LEFT
   ; rjmp    _CM_MOTOR_RIGHT

_CM_MOTOR_RIGHT:
.ifdef MOTOR_DDR
    sbi     MOTOR_PORT, MOTOR_BIT
    sbi     MOTOR_DDR, MOTOR_BIT
.else
    cbi     MOTOR_LEFT_PORT, MOTOR_LEFT_BIT
    sbi     MOTOR_RIGHT_PORT, MOTOR_RIGHT_BIT
.endif
    ldi     R_WORKING_STATE, 1 << WORKING_STATE_MOTOR_RIGHT_BIT
    rjmp    _CM_END

_CM_MOTOR_LEFT:
.ifdef  MOTOR_DDR
    cbi     MOTOR_PORT, MOTOR_BIT
    sbi     MOTOR_DDR, MOTOR_BIT
.else
    cbi     MOTOR_RIGHT_PORT, MOTOR_RIGHT_BIT
    sbi     MOTOR_LEFT_PORT, MOTOR_LEFT_BIT
.endif
    ldi     R_WORKING_STATE, 1 << WORKING_STATE_MOTOR_LEFT_BIT
    rjmp    _CM_END

_CM_MOTOR_STOP:
    clr     R_MOTOR_PWM_COUNTER_PERIOD
    clr     R_MOTOR_PWM_COUNTER
    ldi     R_TMP_1, MESAURE_FREQUENCY
    mov     R_MOTOR_ENABLED_TIMER_COUNTER, R_TMP_1

_CM_MOTOR_STOP_NO_RESET_PWM_COUNTER:
    ; reset licznika czasu pracy silnika.
    sts     MOTOR_ENABLED_COUNTER_H, R_ZERO
    sts     MOTOR_ENABLED_COUNTER_L, R_ZERO
    cbr     R_CONTROL, R_CONTROL_PREV_MOTOR_MASK

_CM_MOTOR_STOP_NO_RESET_COUNTER:
.ifdef  MOTOR_DDR
    cbi     MOTOR_DDR, MOTOR_BIT
    cbi     MOTOR_PORT, MOTOR_BIT
.else
    cbi     MOTOR_RIGHT_PORT, MOTOR_RIGHT_BIT
    cbi     MOTOR_LEFT_PORT, MOTOR_LEFT_BIT
.endif
_CM_END:

    ; zachowanie stanu pracy
    sts     WORKING_STATE, R_WORKING_STATE

    ret
;----------------------------------------------------------------------------
READ_OTHER_SENSORS:
    lds     R_TMP_1, SENSOR_COUNT
    mov     R_LOOP, R_TMP_1
    ; zmniejszenie ilosci pomiarow gdy jest okreslony czujnik zasilania
    lds     R_TMP_2, SENSOR_INDEXES
    andi    R_TMP_2, 0x0F
    mov     R_SENSOR_IN_INDEX, R_TMP_2
    cp      R_TMP_2, R_LOOP
    brsh    PC + 2
    dec     R_TMP_1
    ; pominiecie czujnika powrotu
    lds     R_TMP_2, SENSOR_INDEXES
    swap    R_TMP_2
    andi    R_TMP_2, 0x0F
    mov     R_SENSOR_OUT_INDEX, R_TMP_2
    cp      R_TMP_2, R_LOOP
    brsh    PC + 2
    dec     R_TMP_1

    ; sprawdzenie czy jest jakis sensor do odczytu
    tst     R_TMP_1
    breq    _ROS_END
    brmi    _ROS_END

    ; okreslenie ilosci wczytywanych czujnikow
    ldi     R_LOOP, MAX_SENSOR_READ_ONCE
    cp      R_LOOP, R_TMP_1 ; tu jest ilosc czujnikow
    brlo    PC + 2
    ; MAX_SENSOR_READ_ONCE jest wieksze niez ilosc czujnikow
    mov     R_LOOP, R_TMP_1

; petla wczytywania kilku temperatur
_ROS_LOOP:
    ; pominieci odczytu dla czujnika zasilania
    cp      R_SENSOR_INDEX, R_SENSOR_IN_INDEX
    breq    _ROS_LOOP_SKIP_SENSOR

    ; pominieci odczytu dla czujnika powrotu
    cp      R_SENSOR_INDEX, R_SENSOR_OUT_INDEX
    breq    _ROS_LOOP_SKIP_SENSOR

    ; indeks odczytywanego sensora
    mov     R_DATA, R_SENSOR_INDEX
    rcall   READ_TEMPERATURE

    dec     R_LOOP

_ROS_LOOP_SKIP_SENSOR:

    ; inkrementacja indeksu
    inc     R_SENSOR_INDEX
    lds     R_TMP_1, SENSOR_COUNT
    cp      R_SENSOR_INDEX, R_TMP_1
    brlo    PC + 2
    clr     R_SENSOR_INDEX

    tst     R_LOOP
    brne    _ROS_LOOP

_ROS_END:

    ret
;----------------------------------------------------------------------------
CHECK_MOTOR_PWN:
    ; ustawienie wyniku w rejestrze R_TEMPERATURE_H, precyzja 0.5
    lsl     R_TEMPERATURE_L
    rol     R_TEMPERATURE_H

    ; negacja gdy ujemna wartosc
    sbrc    R_TEMPERATURE_H, 7
    neg     R_TEMPERATURE_H

    lds     R_TMP_1, MOTOR_PWM_COUNTER_MAX
    ; sprawdzenie czy PWM jest wlaczone w konfiguracji
    tst     R_TMP_1
    breq    _CMP_NO_PWM
    ; obliczenie roznicy do progu dzialania PWM
    cp      R_TMP_1, R_TEMPERATURE_H
    brlo    _CMP_NO_PWM

_CMP_PWM:
    ; wymuszony tryb PWM

    ; ustalenie progu PWM
    sub     R_TMP_1, R_TEMPERATURE_H
    inc     R_TMP_1

    ; Wylaczenie silnika gdy R_MOTOR_PWM_COUNTER jest mniejszy od progu
    cp      R_MOTOR_PWM_COUNTER, R_TMP_1
    brsh    PC + 2
    sbr     R_CONTROL, 1 << R_CONTROL_MOTOR_STOPPED_BIT

    ; Inkrementacja R_MOTOR_PWM_COUNTER_PERIOD
    inc     R_MOTOR_PWM_COUNTER_PERIOD
    ldi     R_TMP_1, MOTOR_PWM_COUNTER_PERIOD_MAX
    cp      R_MOTOR_PWM_COUNTER_PERIOD, R_TMP_1
    brlo    _CMP_PWM_NO_CHANGE_PWM_COUNTER
    clr     R_MOTOR_PWM_COUNTER_PERIOD

    ; inkrementacja R_MOTOR_PWM_COUNTER
    inc     R_MOTOR_PWM_COUNTER
    lds     R_TMP_1, MOTOR_PWM_COUNTER_MAX
    cp      R_MOTOR_PWM_COUNTER, R_TMP_1
    brlo    _CMP_PWM_NO_CHANGE_PWM_COUNTER
    breq    _CMP_PWM_NO_CHANGE_PWM_COUNTER
    clr     R_MOTOR_PWM_COUNTER

_CMP_PWM_NO_CHANGE_PWM_COUNTER:

_CMP_PWM_NO_CHANGE:

    ret

_CMP_NO_PWM:
    clr     R_MOTOR_PWM_COUNTER
    clr     R_MOTOR_PWM_COUNTER_PERIOD

    ret
;----------------------------------------------------------------------------
CHECK_STOP_MOTOR:
    ; jezeli silnik ma sie krecic w ta sama strone co poprzednio
    ; to sprawdzany jest czas krecenia i jak jest za dlugi to 
    ; ustawiany jest bit SREG-Z

    andi    R_DATA, R_CONTROL_PREV_MOTOR_MASK
    mov     R_TMP_1, R_CONTROL
    andi    R_TMP_1, R_CONTROL_PREV_MOTOR_MASK    
    cp      R_DATA, R_TMP_1
    brne    _CSM_CONTINUE_RESET_COUNTER

    ; sprawdzenie czy licznik doszedl do konca
    ; jak tak to zatrzymanie silnika
    lds     R_WAIT_1, MOTOR_ENABLED_COUNTER_H
    lds     R_WAIT_0, MOTOR_ENABLED_COUNTER_L
    lds     R_TMP_2, MOTOR_ENABLED_TIME_H
    lds     R_TMP_1, MOTOR_ENABLED_TIME_L
    cp      R_WAIT_0, R_TMP_1
    cpc     R_WAIT_1, R_TMP_2
    brlo    _CSM_CONTINUE

    ; licznik doszedl do maks, nalezy zatrzymac silnik
    sbr     R_CONTROL, 1 << R_CONTROL_MOTOR_STOPPED_BIT
    rjmp    _CSM_END

_CSM_CONTINUE_RESET_COUNTER:

    ; kasowanie licznika
    sts     MOTOR_ENABLED_COUNTER_H, R_ZERO
    sts     MOTOR_ENABLED_COUNTER_L, R_ZERO
    ldi     R_TMP_1, MESAURE_FREQUENCY
    mov     R_MOTOR_ENABLED_TIMER_COUNTER, R_TMP_1
    rjmp    _CSM_END

_CSM_CONTINUE:
    ; inkrementacja
    dec     R_MOTOR_ENABLED_TIMER_COUNTER
    brne    _CSM_END
    adiw    R_WAIT_0, 1
    sts     MOTOR_ENABLED_COUNTER_H, R_WAIT_1
    sts     MOTOR_ENABLED_COUNTER_L, R_WAIT_0
    ldi     R_TMP_1, MESAURE_FREQUENCY
    mov     R_MOTOR_ENABLED_TIMER_COUNTER, R_TMP_1

_CSM_END:
    ; zapisanie aktualnego kierunku (prev dla nastepnego sprawdzenia)
    cbr     R_CONTROL, R_CONTROL_PREV_MOTOR_MASK
    or      R_CONTROL, R_DATA

    ret
;----------------------------------------------------------------------------
START_MEASURE:
    rcall   OWIRE_MASTER_DETECT_PRESENCE

    ; przeskoczenie adresu, rozkaz wysylany jest do wszystkich
    rcall   OWIRE_MASTER_SKIP_ROM

    ; rozkaz konwersji
    ldi     R_OWIRE_DATA, DS18B20_OP_CONVERT_T
    rcall   OWIRE_M_SEND_BYTE

    rcall   OWIRE_M_READ_BYTE

ret
;----------------------------------------------------------------------------
; Odczytuje temperature czujnika o indeksie podanym w 
; R_READ_TEMPERATURE_SENSOR_INDEX
; Temperature koryguje o wartosc zapisana w DS18B20_SCRATCHPAD_BYTE_1.
; Organizacja DS18B20_SCRATCHPAD_BYTE jest taka sama 
; jak DS18B20_SCRATCHPAD_TEMPERATURE
; odczytana wartosc zapisuje pod odpowiedni indeks 
; w tablicy SENSOR_TEMPERATURES:
READ_TEMPERATURE:
    ; inicjacja transmisji
    rcall   OWIRE_MASTER_DETECT_PRESENCE

        ; przeskoczenie adresu, rozkaz wysylany jest do wszystkich
        ; rcall   OWIRE_MASTER_SKIP_ROM
    ; zachowanie indeksu czujnika
    mov     R_READ_TEMPERATURE_SENSOR_TMP, R_DATA
    ; ustawienie R_POINTER na ID odpowiedniego sensora
    ldi     R_OWIRE_MASTER_POINTER_L, low(SENSOR_ROMS)
    ldi     R_OWIRE_MASTER_POINTER_H, high(SENSOR_ROMS)
    dec     R_DATA
    brmi    PC + 3
    adiw    R_OWIRE_MASTER_POINTER, 6
    rjmp    PC - 3
    ldi     R_OWIRE_DATA, DS18B20_ROM_FAMILY_CODE
    rcall   OWIRE_MASTER_MATCH_ROM_FC_ID_POINTER

    ; odczyt pamieci czujnika
    rcall   DS18B20_READ_SCRATCHPAD

    ; przekopiowanie do pamieci (tablica SENSORS_TEMPERATURE:) 
    ; wartosci temperatury zaokraglonej do 1 stopnia.
    lds     R_TEMPERATURE_L, DS18B20_SCRATCHPAD_TEMPERATURE_L
    lds     R_TEMPERATURE_H, DS18B20_SCRATCHPAD_TEMPERATURE_H
    ; korekta
    lds     R_TMP_1, DS18B20_SCRATCHPAD_BYTE_1
    lds     R_TMP_2, DS18B20_SCRATCHPAD_BYTE_2
    add     R_TEMPERATURE_L, R_TMP_1
    adc     R_TEMPERATURE_H, R_TMP_2
    ; przesuniecie wyniku w lewo o 4
    lsl     R_TEMPERATURE_L
    rol     R_TEMPERATURE_H
    lsl     R_TEMPERATURE_L
    rol     R_TEMPERATURE_H
    lsl     R_TEMPERATURE_L
    rol     R_TEMPERATURE_H
    lsl     R_TEMPERATURE_L
    rol     R_TEMPERATURE_H

    ; zapis pomiaru do tablicy temperatur
    ldi     R_POINTER_L, low(SENSOR_TEMPERATURES)
    ldi     R_POINTER_H, high(SENSOR_TEMPERATURES)
    add     R_POINTER_L, R_READ_TEMPERATURE_SENSOR_TMP
    adc     R_POINTER_H, R_ZERO
    st      R_POINTER, R_TEMPERATURE_H

    ret
;----------------------------------------------------------------------------
I2C_CHECK_REQUEST:
    cbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
    
    ; Identyfikator rozkazu
    lds     R_DATA, I2C_RECV_DATA_REQUEST

    ; sprawdzenie ilosci argumentow
    mov     R_TMP_1, R_I2C_BUF_POINTER_L
    subi    R_TMP_1, I2C_RECV_DATA_ARG_0
    cpi     R_TMP_1, 1
    brlo    _I2C_CR_0_ARG
    breq    _I2C_CR_1_ARG
    cpi     R_TMP_1, 2
    breq    _I2C_CR_2_ARGS

    rjmp    _I2C_CR_END

_I2C_CR_0_ARG:
    ; Zapis danych do EE
    cpi     R_DATA, I2C_REQUEST_SAVE_EE
    breq    _I2C_CR_REQUEST_SAVE_EE

    ; Rozkaz wyszukania czujnikow
    cpi     R_DATA, I2C_REQUEST_SEARCH_SENSORS
    breq    _I2C_CR_REQUEST_SEARCH_SENSORS

    ; Rozkaz resetu
    cpi     R_DATA, I2C_REQUEST_RESET
    breq    _I2C_CR_REQUEST_RESET
    
    rjmp    _I2C_CR_END

_I2C_CR_1_ARG:
    ; Rozkaz z jednym argumentem
    ; ustawienie z¹danej temperatury - I2C_REQUEST_SET_TEMPERATURE
    cpi     R_DATA, I2C_REQUEST_SET_TEMPERATURE
    breq    _I2C_CR_SET_TEMPERATURE_REQUEST

    cpi     R_DATA, I2C_REQUEST_SET_TEMPERATURE_IN_MAX
    breq    _I2C_CR_SET_SET_TEMPERATURE_IN_MAX

    ; ustawienie rozdzielczosci dla PWM - I2C_REQUEST_SET_TEMPERATURE
    cpi     R_DATA, I2C_REQUEST_SET_MOTOR_PWM_COUNTER_MAX
    breq    _I2C_CR_SET_MOTOR_PWM_COUNTER_MAX

    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS, 7 lub 10 bit
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    breq    _I2C_CR_SET_SLAVE_ADDRES_H

    ; indeksy czujnikow.
    cpi     R_DATA, I2C_REQUEST_SET_SENSOR_INDEXES
    breq    _I2C_CR_SET_SENSOR_INDEXES

    rjmp    _I2C_CR_END

_I2C_CR_2_ARGS:
    ; Rozkaz z dwoma argumentami
    ; ustawienie maksymalnego czasu pracy silnika - I2C_REQUEST_SET_MOTOR_ENABLED_TIME
    cpi     R_DATA, I2C_REQUEST_SET_MOTOR_ENABLED_TIME
    breq    _I2C_CR_SET_MOTOR_ENABLED_TIME

    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS, 10 bit
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    breq    _I2C_CR_SET_SLAVE_ADDRES_L

    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_RESET:
    ; Rozkaz RESET
    cli
    rjmp    RESET_SOFT

_I2C_CR_REQUEST_SAVE_EE:
    rcall   SAVE_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_SEARCH_SENSORS:
    ; Rozkaz wyszukania czujnikow
    rcall   SEARCH_SENSORS
    rjmp    _I2C_CR_END

_I2C_CR_SET_TEMPERATURE_REQUEST:
    ; Rozkaz ustawienia zadanej temperatury
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     TEMPERATURE_REQUEST, R_TMP_1
    rjmp    _I2C_CR_END

_I2C_CR_SET_SET_TEMPERATURE_IN_MAX:
    ; Rozkaz ustawienia maksymalnej temperatury zasilania
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     TEMPERATURE_IN_MAX, R_TMP_1
    rjmp    _I2C_CR_END

_I2C_CR_SET_MOTOR_PWM_COUNTER_MAX:
    ; Rozkaz ustawienia rozdzielczosci PWM
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    ; korekta
    sbrc    R_TMP_1, 7
    ldi     R_TMP_1, MOTOR_PWM_COUNTER_MAX_DEFAULT
    sts     MOTOR_PWM_COUNTER_MAX, R_TMP_1
    rjmp    _I2C_CR_END

_I2C_CR_SET_SLAVE_ADDRES_H:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    cpi     R_TMP_1, 0b1111000
    brsh    _I2C_CR_END ; koniec gdy adres jest zaw ysoki - zarezerwowany
    cpi     R_TMP_1, 0b1000
    brlo    _I2C_CR_END ; koniec gdy adres jest za niski - zarezerwowany
    lsl     R_TMP_1
    ; adres jest poprawny jak na 7 bitowy
    mov     R_I2C_MY_ADDRESS, R_TMP_1
//    rcall   SAVE_MY_I2C_ADDRESS_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_SET_SLAVE_ADDRES_L:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    lds     R_TMP_2, I2C_RECV_DATA_ARG_1
    cpi     R_TMP_1, high(1024)
    brsh    _I2C_CR_END ; koniec gdy niepoprawny adres
    ; sformatowanie adresu do bezposredniego porównania
    lsl     R_TMP_1
    sbr     R_TMP_1, 0b11110000
    mov     R_I2C_MY_ADDRESS, R_TMP_1
    mov     R_I2C_MY_ADDRESS_L, R_TMP_2

    rjmp    _I2C_CR_END

_I2C_CR_SET_SENSOR_INDEXES:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     SENSOR_INDEXES, R_TMP_1
    rjmp    _I2C_CR_END

_I2C_CR_SET_MOTOR_ENABLED_TIME:
    lds     R_TMP_2, I2C_RECV_DATA_ARG_1
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     MOTOR_ENABLED_TIME_H, R_TMP_2
    sts     MOTOR_ENABLED_TIME_L, R_TMP_1
//    rcall   SAVE_MOTOR_ENABLED_TIME_TO_EE

_I2C_CR_END:
    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.macro  LOAD_BYTE_FROM_EE
    ldi     R_DATA, @0
    rcall   LOAD_BYTE_FROM_EE_F
.endmacro

LOAD_BYTE_FROM_EE_F:
    out     EEARL, R_DATA
    sbi     EECR, EERE
    in      R_DATA, EEDR
    ret

LOAD_FROM_EE:
    ; poczekanie na ewentualny poprzedni zapis
    sbic    EECR, EEPE
    rjmp    PC-1

    ; Adres I2C
    LOAD_BYTE_FROM_EE   E_I2C_MY_ADDRESS
    ; korekta gdy adres nie jest zapisany
    sbrc    R_DATA, 0
    ldi     R_DATA, I2C_MY_ADDRESS_DEFAULT
    mov     R_I2C_MY_ADDRESS, R_DATA
    LOAD_BYTE_FROM_EE   E_I2C_MY_ADDRESS
    mov     R_I2C_MY_ADDRESS_L, R_DATA
    ; TEST I2C 7-bit
    ;ldi     R_DATA, 0x32
    ;mov     R_I2C_MY_ADDRESS, R_DATA
    ; TEST I2C 10-bit
    ;ldi     R_DATA, 0b11110000 | (high(567) << 1)
    ;mov     R_I2C_MY_ADDRESS, R_DATA
    ;ldi     R_DATA, low(567)
    ;mov     R_I2C_MY_ADDRESS_L, R_DATA

    LOAD_BYTE_FROM_EE   E_SENSOR_INDEXES
    sts     SENSOR_INDEXES, R_DATA

    LOAD_BYTE_FROM_EE   E_TEMPERATURE_REQUEST
    sts     TEMPERATURE_REQUEST, R_DATA

    LOAD_BYTE_FROM_EE   E_TEMPERATURE_IN_MAX
    sts     TEMPERATURE_IN_MAX, R_DATA

    LOAD_BYTE_FROM_EE   E_SENSOR_COUNT
    mov     R_LOOP, R_DATA
    ; korekta
    cpi     R_LOOP, MAX_SENSOR_COUNT
    brlo    PC + 2
    ldi     R_LOOP, 0
    sts     SENSOR_COUNT, R_LOOP

    ; Identyfikatory sensorow
    ldi     R_TMP_1, E_SENSOR_ROMS
    ldi     R_POINTER_H, high(SENSOR_ROMS)
    ldi     R_POINTER_L, low(SENSOR_ROMS)
_LFE_SENSORS_LOOP:
    dec     R_LOOP
    brmi    _LFE_SENSORS_LOOP_END
    ; identyfikator sensora
    ldi     R_TMP_2, 6
_LFE_SENSOR_ROM_LOOP:
    out     EEARL, R_TMP_1
    sbi     EECR, EERE
    in      R_DATA, EEDR
    inc     R_TMP_1
    ; zapis
    st      R_POINTER+, R_DATA
    ;
    dec     R_TMP_2
    brne    _LFE_SENSOR_ROM_LOOP
    ;
    rjmp    _LFE_SENSORS_LOOP
_LFE_SENSORS_LOOP_END:

    ; rozdzielczosc PWM
    LOAD_BYTE_FROM_EE   E_MOTOR_PWM_COUNTER_MAX
    ; korekta gdy nie jest zapisana wartosc
    sbrc    R_DATA, 7
    ldi     R_DATA, MOTOR_PWM_COUNTER_MAX_DEFAULT
    sts     MOTOR_PWM_COUNTER_MAX, R_DATA

    ; maksymalny czas wlaczenia silnika
    LOAD_BYTE_FROM_EE   E_MOTOR_ENABLED_TIME_H
    mov     R_TMP_2, R_DATA
    LOAD_BYTE_FROM_EE   E_MOTOR_ENABLED_TIME_L
    ; korekta gdy czas wlaczenia silnika jest za duzy
    sbrs    R_TMP_2, 7
    rjmp    PC + 3
    ldi     R_TMP_2, high(MOTOR_ENABLED_TIME_DEFAULT)
    ldi     R_DATA, low(MOTOR_ENABLED_TIME_DEFAULT)
    sts     MOTOR_ENABLED_TIME_H, R_TMP_2
    sts     MOTOR_ENABLED_TIME_L, R_DATA

    ret
;----------------------------------------------------------------------------
SAVE_BYTE_TO_EE_F:
    ; poczekanie na poprzedni zapis
    sbic    EECR, EEPE
    rjmp    PC-1

    ; adres
    out     EEARL, R_TMP_1

    ; pobranie istniejacej wartosci
    sbi     EECR, EERE
    push    R_TMP_1
    in      R_TMP_1, EEDR
    cp      R_DATA, R_TMP_1
    pop     R_TMP_1
    breq    _STEF_END

    ; zapis
    out     EEDR, R_DATA
    cli
    sbi     EECR, EEMPE
    sbi     EECR, EEPE
    sei

_STEF_END:
    ret
;----------------------------------------------------------------------------
.macro  SAVE_BYTE_TO_EE
    ldi     R_TMP_1, E_@0
    lds     R_DATA, @0
    rcall   SAVE_BYTE_TO_EE_F
.endmacro

.macro  SAVE_REG_TO_EE
    ldi     R_TMP_1, @0
    mov     R_DATA, @1
    rcall   SAVE_BYTE_TO_EE_F
.endmacro
;----------------------------------------------------------------------------
SAVE_TO_EE:
    ; Adres I2C
    SAVE_REG_TO_EE  E_I2C_MY_ADDRESS, R_I2C_MY_ADDRESS
    SAVE_REG_TO_EE  E_I2C_MY_ADDRESS_L, R_I2C_MY_ADDRESS_L
    SAVE_BYTE_TO_EE SENSOR_INDEXES
    SAVE_BYTE_TO_EE TEMPERATURE_REQUEST
    SAVE_BYTE_TO_EE TEMPERATURE_IN_MAX
    SAVE_BYTE_TO_EE SENSOR_COUNT

    ; Identyfikatory sensorow
    ldi     R_TMP_1, E_SENSOR_ROMS
    ldi     R_POINTER_H, high(SENSOR_ROMS)
    ldi     R_POINTER_L, low(SENSOR_ROMS)
    lds     R_LOOP, SENSOR_COUNT
_STE_SENSORS_LOOP:
    dec     R_LOOP
    brmi    _STE_SENSORS_LOOP_END
    ; identyfikator sensora
    ldi     R_TMP_2, 6
_STE_SENSOR_ROM_LOOP:
    out     EEARL, R_TMP_1
    ld      R_DATA, R_POINTER+
    rcall   SAVE_BYTE_TO_EE_F
    inc     R_TMP_1
    ;
    dec     R_TMP_2
    brne    _STE_SENSOR_ROM_LOOP
    ;
    rjmp    _STE_SENSORS_LOOP
_STE_SENSORS_LOOP_END:

    ; rozdzielczosc PWM
    SAVE_BYTE_TO_EE MOTOR_PWM_COUNTER_MAX
    SAVE_BYTE_TO_EE MOTOR_ENABLED_TIME_L
    SAVE_BYTE_TO_EE MOTOR_ENABLED_TIME_H
    
    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;       Obsluga I2C
;----------------------------------------------------------------------------
.macro      I2C_BYTE_RECEIVED
    sbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
.endmacro
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.include    "SterownikZaworu_DSEG.asm"
.include    "SterownikZaworu_ESEG.asm"

.include    "OWireMaster.asm"
.include    "DS18B20.asm"
.include    "I2CTinySlaveMacro1.inc"
.include    "I2CTinySlave.asm"
.include    "Wait_Tiny25_Timer0.asm"
;.include    "Wait.asm"
