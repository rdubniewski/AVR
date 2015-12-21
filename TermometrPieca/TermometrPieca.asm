/****************************************************************************
File:               TermometrPieca.asm
Author:             Rafa³ Dubniewski
PCB Verssion        1.x
Verssion            1.0
Created:            2012.03.29
Modified:           2012.03.29
****************************************************************************/

;.include    <tn25def.inc>

.include    "TermometrPieca.inc"

.include    "OWireMaster.inc"
.include    "I2CTinySlave.inc"
.include    "Wait_Tiny25_Timer0.inc"

#define WAIT_MICROSEC_OWIRE_MASTER              WAIT_MICROSEC_TINY25_TIMER0
#define WAIT_MICROSEC_MINUS_TICKS_OWIRE_MASTER  WAIT_MICROSEC_MINUS_TICKS_TINY25_TIMER0

;#define _TEST_

#ifdef _TEST_
    #warning "UWAGA !!! Wlaczone testowanie kodu"
#endif

.cseg
.org    0x0             rjmp    RESET

.org    OVF1addr        ; oznaczenie z¹dania pomiaru albo zliczania timera
                        sbr     R_CONTROL, 1 << R_CONTROL_CHECK_TIMER_BIT
                        reti

.org    USI_STARTaddr   rjmp    USI_I2C_START
.org    USI_OVFaddr     rjmp    USI_I2C_OV

.org INT_VECTORS_SIZE

RESET:
RESET_SOFT:
    ; wylaczenie przerwan
    cli

    ; ZEGAR
    ldi     R_TMP_1, 1 << CLKPCE
    ldi     R_TMP_2, CLKPR_DEF
    out     CLKPR, R_TMP_1
    out     CLKPR, R_TMP_2

    .macro stsi
        ldi     R_TMP_1, @1
        sts      @0, R_TMP_1
    .endmacro
    
    /* ; test sortowanie
    
    .macro stsi
        ldi     R_TMP_1, @1
        sts      @0, R_TMP_1
    .endmacro
    stsi    SENSORS_TEMPERATURE + 0, 23
    stsi    SENSORS_TEMPERATURE + 1, 45
    stsi    SENSORS_TEMPERATURE + 2, 90
    stsi    SENSORS_TEMPERATURE + 3, 11
    stsi    SENSORS_TEMPERATURE + 4, 9
    stsi    SENSORS_TEMPERATURE + 5, 121
    stsi    SENSORS_TEMPERATURE + 6, 189
    stsi    SENSORS_TEMPERATURE + 7, 33
    stsi    SENSORS_TEMPERATURE + 8, 190
    stsi    SENSORS_TEMPERATURE + 9, 210
    stsi    SENSORS_TEMPERATURE + 10, 21
    stsi    SENSORS_TEMPERATURE + 11, 45
    stsi    SENSORS_TEMPERATURE + 12, 12
    stsi    SENSOR_COUNT, 13
;    stsi    STATE, 1 << STATE_SORT_DESCENDING_BIT
;    rcall   READ_TEMPERATURE_ALL_SENSORS
    rcall   SORT_TEMPERATURE
    */

    ; zainicjowanie stosu
    ldi     R_TMP_1, low(RAMEND)
    out     SPL, R_TMP_1

    ; Test w³¹czania i wy³¹czania grza³ek
    /*
    stsi    SENSOR_COUNT, 12
    stsi    SENSORS_TEMPERATURE + 0, 20
    stsi    SENSORS_TEMPERATURE + 1, 21
    stsi    SENSORS_TEMPERATURE + 2, 22
    stsi    SENSORS_TEMPERATURE + 3, 23
    stsi    SENSORS_TEMPERATURE + 4, 24
    stsi    SENSORS_TEMPERATURE + 5, 25
    stsi    SENSORS_TEMPERATURE + 6, 26
    stsi    SENSORS_TEMPERATURE + 7, 27
    stsi    SENSORS_TEMPERATURE + 8, 28
    stsi    SENSORS_TEMPERATURE + 9, 29
    stsi    SENSORS_TEMPERATURE + 10, 30
    stsi    SENSORS_TEMPERATURE + 11, 31
    stsi    HEAT_0_CONFIG_H, (0b00110000)
    stsi    HEAT_0_CONFIG_L, (0b00010101)
    stsi    HEAT_0_TEMPERATURE_ON, 25
    stsi    HEAT_0_TEMPERATURE_OFF, 30
    stsi    HEAT_1_CONFIG_H, (0b01110000)
    stsi    HEAT_1_CONFIG_L, (0b00101010)
    stsi    HEAT_1_TEMPERATURE_ON, 25
    stsi    HEAT_1_TEMPERATURE_OFF, 30
    rcall   CHECK_HEATERS
    */

    ; zainicjowanie portow
    clr     R_TMP_1
    out     DDRB, R_TMP_1
    out     PORTB, R_TMP_1
    sbi     HEATER_0_DDR, HEATER_0_BIT
    sbi     HEATER_1_DDR, HEATER_1_BIT
    ; komunikacja z czujnikami
    OWIRE_MASTER_1

    ; konfigurowanie oszczesnosci enargii
    sbi     ACSR, ACD
    ldi     R_TMP_1, 0 << PRTIM0 | 1 << PRADC
    out     PRR, R_TMP_1

    ; skonfigurowanie timera kasujacego przestarzaly wynik
    ; konfigurowanie timera
    in      R_TMP_1, TIMSK
    sbr     R_TMP_1, TIMER_MASK_DEF
    out     TIMSK, R_TMP_1    
    ldi     R_TMP_1, TIMER_OCR_DEF
    out     TIMER_OCR, R_TMP_1
    lds     R_TMP_1, TIMER_CONTROL_1
    sbr     R_TMP_1, TIMER_CONTROL_1_OFF_DEF
    out     TIMER_CONTROL_1,  R_TMP_1
    lds     R_TMP_1, TIMER_CONTROL_2
    sbr     R_TMP_1, TIMER_CONTROL_2_DEF
    out     TIMER_CONTROL_2,  R_TMP_1

    ; wlaczenie usypiania procesora.
    in      R_TMP_1, MCUCR
    sbr     R_TMP_1, 1 << SE
    out     MCUCR, R_TMP_1

    rcall   LOAD_FROM_EE
    rcall   USI_I2C_INIT

    ; zapis identyfikatora i wersji urzadzenia
    ldi     R_TMP_1, DEVICE_ID_DEF
    sts     DEVICE_ID, R_TMP_1
    ldi     R_TMP_1, DEVICE_VERSION_DEF
    sts     DEVICE_VERSION, R_TMP_1

    clr     R_CONTROL

    ; pobranie ilosci czujnikow i ich romow do tabeli SENSORS w pamieci RAM
    rcall   SEARCH_SENSORS

    sbr     R_CONTROL, 1 << R_CONTROL_START_MEASURE_BIT     |  \
                       1 << R_CONTROL_RESET_TIMER_BIT

    /*
    ldi     R_TMP_1, 1 << STATE_CONTINUE_BIT        |  \
                     1 << STATE_SORT_BIT            |  \
                     1 << STATE_SORT_DESCENDING_BIT
    sts     STATE, R_TMP_1
    stsi    REPEAT_TIME, 2
    */

    ; wlaczenie przerwan
    sei

MAIN_LOOP:
    ; sprawdzenie czy przyszedl komunikat z timera
    sbrc    R_CONTROL, R_CONTROL_CHECK_TIMER_BIT
    rcall   CHECK_TIMER

    ; Rozpoczecie pomiaru
    sbrc    R_CONTROL, R_CONTROL_START_MEASURE_BIT
    rcall   BEGIN_MEASURE

    ; Pobranie pomiarow
    sbrs    R_CONTROL, R_CONTROL_READ_TEMPERATURE_BIT
    rjmp    _M_READ_TEMPERATURE_SKIP
    rcall   READ_TEMPERATURE_ALL_SENSORS
    rcall   CHECK_HEATERS
_M_READ_TEMPERATURE_SKIP:

    ; przetwarzainie zadania z I2C
    sbrc    R_CONTROL, R_CONTROL_I2C_READ_BYTE_BIT
    rcall   I2C_CHECK_REQUEST

    ; sleep gdy nie ma zadnego zadania
    mov     R_TMP_1, R_CONTROL
    andi    R_TMP_1, R_CONTROL_REQUEST_MASK
    brne    MAIN_LOOP

    sleep

    rjmp    MAIN_LOOP
;----------------------------------------------------------------------------
CHECK_TIMER:
    ; wykasowanie flagi timera
    cbr     R_CONTROL, 1 << R_CONTROL_CHECK_TIMER_BIT

    inc     R_TIMER_COUNTER

    ; sprawdzenie czy nalezy wykonac odczyt temperatury
    lds     R_TMP_1, STATE
    sbrc    R_TMP_1, STATE_MEASURING_BIT
    rjmp    _CT_WAIT_FOR_MEASURE
    ; liczenie czasu do kolejnego pomiaru
    sbrc    R_TMP_1, STATE_COMPLETE_BIT
    rjmp    _CT_WAIT_FOR_NEXT_MEASURE

    rjmp    _CT_TIMER_STOP

_CT_WAIT_FOR_MEASURE:
    ; zadanie pobrania temperatury
    cpi     R_TIMER_COUNTER, WAIT_MEASURE_TIME
    brlo    _CT_END
    sbr     R_CONTROL, 1 << R_CONTROL_READ_TEMPERATURE_BIT
    ;clr     R_TIMER_COUNTER
    ; zakonczenie pracy timera gdy nie ma okreslonego czasu do kolejnego pomiaru
    lds     R_TMP_1, REPEAT_TIME
    tst     R_TMP_1
    breq    _CT_TIMER_STOP
    clr     R_TIMER_SEC
    rjmp    _CT_END

_CT_WAIT_FOR_NEXT_MEASURE:
    cpi     R_TIMER_COUNTER, TIMER_FREQUENCY
    brlo    _CT_END
    ; minela kolejna sekunda
    clr     R_TIMER_COUNTER
    inc     R_TIMER_SEC
    ; sprawdzenie czy nalezy wznowic pomiar (przedawnic poprzedni pomiar)
    lds     R_TMP_1, REPEAT_TIME
    cp      R_TIMER_SEC, R_TMP_1
    brlo    _CT_END
    ; sprawdzenie przedawnienia
    lds     R_TMP_1, STATE
    sbrs    R_TMP_1, STATE_CONTINUE_BIT
    rjmp    _CT_OBSOLETE
    ; wznowienie pomiaru albo ustawienie flagi przedawnienia
    sbr     R_CONTROL, 1 << R_CONTROL_START_MEASURE_BIT     |  \
                       1 << R_CONTROL_RESET_TIMER_BIT
    brlo    _CT_END

_CT_OBSOLETE:
    lds     R_TMP_1, STATE
    sbr     R_TMP_1, 1 << STATE_OBSOLETE_BIT
    sts     STATE, R_TMP_1

_CT_TIMER_STOP:
    ; zatrzymanie timera
    clr     R_TIMER_COUNTER
    ldi     R_TMP_1, TIMER_CONTROL_1_OFF_DEF
    out     TIMER_CONTROL_1, R_TMP_1

_CT_END:
    reti
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
    ; wykonanie pomiaru
    mov     R_TMP_1, R_DATA
    sbr     R_TMP_1, I2C_REQUEST_MEASURE_MASK
    cpi     R_TMP_1, I2C_REQUEST_MEASURE
    breq    _I2C_CR_REQUEST_MEASURE

    ; Reset
    cpi     R_DATA, I2C_REQUEST_RESET
    breq    _I2C_CR_REQUEST_RESET

    rjmp    _I2C_CR_END

_I2C_CR_1_ARG:
    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    breq    _I2C_CR_SET_SLAVE_ADDRES

    cpi     R_DATA, I2C_REQUEST_REPEAT_TIME
    breq    _I2C_CR_SET_REPEAT_TIME

_I2C_CR_2_ARGS:
    ; konfiguracja grza³ki 0
    cpi     R_DATA, I2C_REQUEST_HEAT_CONFIGURE_0
    breq    _I2C_CR_SET_HEAT_CONFIGURE_0
    
    ; temperatury on/off dla grza³ki 0
    cpi     R_DATA, I2C_REQUEST_HEAT_TEMPERATURES_0
    breq    _I2C_CR_SET_HEAT_TEMPERATURES_0

    ; konfiguracja grza³ki 1
    cpi     R_DATA, I2C_REQUEST_HEAT_CONFIGURE_1
    breq    _I2C_CR_SET_HEAT_CONFIGURE_1
    
    ; temperatury on/off dla grza³ki 1
    cpi     R_DATA, I2C_REQUEST_HEAT_TEMPERATURES_1
    breq    _I2C_CR_SET_HEAT_TEMPERATURES_1

    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_MEASURE:
    ; przeniesienie flag sterujacych pomiarem
    lds     R_TMP_1, STATE
    bst     R_DATA, I2C_REQUEST_MEASURE_STEEL_BIT
    bld     R_TMP_1, STATE_CONTINUE_BIT
    bst     R_DATA, I2C_REQUEST_MEASURE_SORT_BIT
    bld     R_TMP_1, STATE_SORT_BIT
    bst     R_DATA, I2C_REQUEST_MEASURE_SORT_DESCENDING_BIT
    bld     R_TMP_1, STATE_SORT_DESCENDING_BIT
    sts     STATE, R_TMP_1
    ; rozpoczecie pomiaru gdy sa ustawione bity wykonania pomiaru
    mov     R_TMP_1, R_DATA
    andi    R_TMP_1, 1 << I2C_REQUEST_MEASURE_BIT |  \
                     1 << I2C_REQUEST_MEASURE_STEEL_BIT
    breq    PC + 2
    sbr     R_CONTROL, 1 << R_CONTROL_START_MEASURE_BIT
    ; zachowanie w eepromie wartosci jako domyslnej 
    sbrc    R_DATA, I2C_REQUEST_MEASURE_STORE_DEFAULT_BIT
    rcall   SAVE_DEFAULT_STATE_TO_EE

    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_RESET:
    ; Rozkaz RESET
    cli
    rjmp    RESET_SOFT

_I2C_CR_SET_SLAVE_ADDRES:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    cbr     R_TMP_1, 0x01
    mov     R_I2C_MY_ADDRESS, R_TMP_1
    rcall   SAVE_MY_I2C_ADDRESS_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_SET_REPEAT_TIME:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     REPEAT_TIME, R_TMP_1
    rcall   SAVE_REPEAT_TIME_TO_EE

_I2C_CR_SET_HEAT_CONFIGURE_0:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     HEAT_0_CONFIG_H, R_TMP_1
    lds     R_TMP_1, I2C_RECV_DATA_ARG_1
    sts     HEAT_0_CONFIG_L, R_TMP_1
    rcall   SAVE_HEAT_0_CONFIG_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_SET_HEAT_TEMPERATURES_0:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     HEAT_0_TEMPERATURE_ON, R_TMP_1
    lds     R_TMP_1, I2C_RECV_DATA_ARG_1
    sts     HEAT_0_TEMPERATURE_OFF, R_TMP_1
    rcall   SAVE_HEAT_0_TEMPERATURES_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_SET_HEAT_CONFIGURE_1:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     HEAT_1_CONFIG_H, R_TMP_1
    lds     R_TMP_1, I2C_RECV_DATA_ARG_1
    sts     HEAT_1_CONFIG_L, R_TMP_1
    rcall   SAVE_HEAT_1_CONFIG_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_SET_HEAT_TEMPERATURES_1:
    lds     R_TMP_1, I2C_RECV_DATA_ARG_0
    sts     HEAT_1_TEMPERATURE_ON, R_TMP_1
    lds     R_TMP_1, I2C_RECV_DATA_ARG_1
    sts     HEAT_1_TEMPERATURE_OFF, R_TMP_1
    rcall   SAVE_HEAT_1_TEMPERATURES_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_END:
    ret
;----------------------------------------------------------------------------
TIMER_START:
    ; zatrzymanie timera i kasowanie licznika
    ldi     R_TMP_1, TIMER_CONTROL_1_OFF_DEF
    out     TIMER_CONTROL_1, R_TMP_1
    clr     R_TMP_1
    out     TIMER_CNT,  R_TMP_1

    ; kasowanie preskalera
    in      R_TMP_1, GTCCR
    sbr     R_TMP_1, 1 << PSR1
    out     GTCCR, R_TMP_1

    ; uruchomienie timera
    ldi     R_TMP_1, TIMER_CONTROL_1_ON_DEF
    out     TIMER_CONTROL_1, R_TMP_1

    clr     R_TIMER_COUNTER

    ret
;----------------------------------------------------------------------------
TIMER_STOP:
    ldi     R_TMP_1, TIMER_CONTROL_1_OFF_DEF
    out     TIMER_CONTROL_1, R_TMP_1
    ret
;----------------------------------------------------------------------------
; szuka czujnikow temperatury
SEARCH_SENSORS:
    ; wyszukanie wszystkich czujnikow na magistrali
    ; dla znalezionego czujnika bedzie wywolana funkcja OWIRE_FOUND_ROM
    clr     R_SENSOR_NR
    ldi     R_POINTER_L, low(SENSOR_ROMS)
    ldi     R_POINTER_H, high(SENSOR_ROMS)
    sts     SENSOR_COUNT, R_SENSOR_NR
    rcall   OWIRE_MASTER_SEARCH_ROM
    sts     SENSOR_COUNT, R_SENSOR_NR
    clr     R_SENSOR_NR
    ret
;----------------------------------------------------------------------------
; Funkcja wywaolywana z poziomu OWIRE_SEARCH_ROM gdy zostalo odnalezione 
; kolejne urzadzenie
OWIRE_ROM_FOUND:
    ; Sprawdzenie czy podlaczony jest wlasciwy czujnik
    lds     R_TMP_1, OWIRE_ROM_FAMILY_CODE
    cpi     R_TMP_1, DS18B20_ROM_FAMILY_CODE
    brne    _ORF_END

    ; sprawdzenie skonczylo sie miejsce w tablicy czujnikow.
    cpi     R_SENSOR_NR, SENSOR_COUNT_MAX
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

    inc     R_SENSOR_NR

_ORF_END:

    ret
;----------------------------------------------------------------------------
; Wysyla do czujnikow konfiguracje precyzji temperatury.
CONFIGURE_SENSORS:
    clr R_TMP_1
    sts DS18B20_SCRATCHPAD_BYTE_1, R_TMP_1
    sts DS18B20_SCRATCHPAD_BYTE_2, R_TMP_1
    ldi R_TMP_1, DS18B20_SCRATCHPAD_CONFIG_9_BIT
    sts DS18B20_SCRATCHPAD_CONFIG, R_TMP_1
    rcall OWIRE_MASTER_DETECT_PRESENCE
    rcall OWIRE_MASTER_SKIP_ROM
    rcall DS18B20_WRITE_SCRATCHPAD
    ret
;----------------------------------------------------------------------------
; Wysyla zadanie do wszystkich czujnikow
BEGIN_MEASURE:
    ; wykasowanie flag pomiaru
    cbr     R_CONTROL, 1 << R_CONTROL_START_MEASURE_BIT     | \
                       1 << R_CONTROL_READ_TEMPERATURE_BIT

    ; stan I2C
    lds     R_TMP_1, STATE
    sbr     R_TMP_1, 1 << STATE_MEASURING_BIT
    sts     STATE, R_TMP_1

    ; zatrzymanie timera. jak jest wymog
    sbrc    R_CONTROL, R_CONTROL_RESET_TIMER_BIT
    rcall   TIMER_STOP

    ; konfiguracja czujnikow zawsze jest potrzebna
    rcall   CONFIGURE_SENSORS

    ; zlecenie pomiaru
    rcall OWIRE_MASTER_DETECT_PRESENCE

    ; przeskoczenie adresu, rozkaz wysylany jest do wszystkich
    rcall OWIRE_MASTER_SKIP_ROM

    ; rozkaz konwersji
    ldi R_OWIRE_DATA, DS18B20_OP_CONVERT_T
    rcall OWIRE_M_SEND_BYTE

    ;rcall OWIRE_M_READ_BYTE

    ; odczekanie na pomiar - uruchomienie timera
    sbrc    R_CONTROL, R_CONTROL_RESET_TIMER_BIT
    rcall   TIMER_START

    cbr     R_CONTROL, 1 << R_CONTROL_RESET_TIMER_BIT

    ret
;----------------------------------------------------------------------------
READ_TEMPERATURE_ALL_SENSORS:
    ; kasowanie flagi nakazujacej pobranie temperatury
    cbr     R_CONTROL, 1 << R_CONTROL_READ_TEMPERATURE_BIT

    ; pobranie wartosci wszystkich przetwornikow
    ldi     XH, high(SENSOR_ROMS)
    ldi     XL, low(SENSOR_ROMS)
    clr     R_SENSOR_NR
MAIN_READ_SENSOR_LOOP:
    rcall   READ_TEMPERATURE

    inc     R_SENSOR_NR
    lds     R_TMP_1, SENSOR_COUNT
    cp      R_SENSOR_NR, R_TMP_1
    brlo    MAIN_READ_SENSOR_LOOP

    ; posortowanie gdy byl ustawiony bit sortowania
    lds     R_TMP_1, STATE
    sbrc    R_TMP_1, STATE_SORT_BIT
    rcall   SORT_TEMPERATURE

    ; stan I2C
    lds     R_TMP_1, STATE
    cbr     R_TMP_1, 1 << STATE_MEASURING_BIT
    sbr     R_TMP_1, 1 << STATE_COMPLETE_BIT
    sts     STATE, R_TMP_1

    ret
;----------------------------------------------------------------------------
; Odczytuje temperature czujnika o numerze R_SENSOR_NR.
; Temperature koryguje o wartosc zapisana w DS18B20_SCRATCHPAD_BYTE_1.
; Organizacja DS18B20_SCRATCHPAD_BYTE jest taka sama 
; jak DS18B20_SCRATCHPAD_TEMPERATURE
; odczytana wartosc zapisuje pod odpowiedni indeks 
; w tablicy SENSORS_TEMPERATURE:
READ_TEMPERATURE:
    ; przepisanie ROM czujnika z tablicy RAM do OWIRE_ROM
    ; Zwraca adres ROMu czujnika o indeksie R_SENSOR_NR do rejestru Z
    // dupa rcall   GET_SENSOR_ROM_ADDRESS_X

    ; inicjacja transmisji
    rcall   OWIRE_MASTER_DETECT_PRESENCE

    ; zaadresowanie wlasciwego czujnika, 
    ; ID_ROM czujnika jest wskazany przez adres rejestru X
    ldi     R_OWIRE_DATA, DS18B20_ROM_FAMILY_CODE
    rcall   OWIRE_MASTER_MATCH_ROM_FC_ID_POINTER

    ; odczyt pamieci czujnika
    rcall   DS18B20_READ_SCRATCHPAD

    ; przekopiowanie do pamieci (tablica SENSORS_TEMPERATURE:)
    ; wartosci temperatury zaokraglonej do 1 stopnia.
    lds     R_TMP_1, DS18B20_SCRATCHPAD_TEMPERATURE_L
    lds     R_TMP_2, DS18B20_SCRATCHPAD_TEMPERATURE_H
    ; korekta
    lds     R_DATA, DS18B20_SCRATCHPAD_BYTE_1
    add     R_TMP_1, R_DATA
    lds     R_DATA, DS18B20_SCRATCHPAD_BYTE_2
    adc     R_TMP_2, R_DATA
    ; reorganizacja by R_TMP_2 zawieral caly baj czesci calkowitej
    andi    R_TMP_1, 0xF0
    or      R_TMP_2, R_TMP_1
    swap    R_TMP_2

    ; zapis temperatury w komorce pamieci
    push    XL
    push    XH
    ldi     XL, low(SENSORS_TEMPERATURE)
    ldi     XH, high(SENSORS_TEMPERATURE)
    ; przesuniecie na wlasciwy indeks
    clr     R_TMP_1
    add     XL, R_SENSOR_NR
    adc     XH, R_TMP_1

    st      X, R_TMP_2

    pop     XH
    pop     XL

    ret
;----------------------------------------------------------------------------
; sortuje tablice SENSORS_TEMPERATURE odczytanych temperatur,
; na poczatku wieksze.
; Nastepnie przekopiowuje posortowane temperatury do tablicy
; SENSORS_TEMPERATURE_SORTED
SORT_TEMPERATURE:
    ; sprawdzenie czy sa jakiekolwiek czujniki
    ;cpi R_SENSOR_COUNT, 0
    ;breq _ST_END

    ; sprawdzenie czy jest wiecej niz 1 czujnik
    lds     R_LOOP, SENSOR_COUNT
    cpi     R_LOOP, 2
    brlo    _ST_END
    dec     R_LOOP

    ; pomocnicza flaga przy sortowaniu okreslajaca kierunek sortowania
    ; w bicie T-SREG
    lds     R_TMP_1, STATE
    bst     R_TMP_1, STATE_SORT_DESCENDING_BIT

_ST_LOOP:
    cbr     R_CONTROL, 1 << R_CONTROL_SORT_SWAPED_BIT
    ldi     XL, low(SENSORS_TEMPERATURE)
    ldi     XH, high(SENSORS_TEMPERATURE)
    ; ilosc przejsc jest o 1 mniejsza od ilosci czujnikow
    ; R_DATA jest licznikiem dla iteracji pojedynczego przejscia
    mov     R_DATA, R_LOOP
_ST_PASS_LOOP:
    ld      R_TMP_1, X+
    ld      R_TMP_2, X
    ; porownanie
    brts    _ST_PASS_LOOP_COMPARE_DESCENDING
_ST_PASS_LOOP_COMPARE_ASCENDING:
    cp      R_TMP_2, R_TMP_1
    rjmp    _ST_PASS_LOOP_COMPARE
_ST_PASS_LOOP_COMPARE_DESCENDING:
    cp      R_TMP_1, R_TMP_2
_ST_PASS_LOOP_COMPARE:
    brge    _ST_PASS_LOOP_NO_SWAP

    ; zamiana 
    st     -X, R_TMP_2
    adiw    X, 1
    st      X, R_TMP_1
    sbr     R_CONTROL, 1 << R_CONTROL_SORT_SWAPED_BIT
_ST_PASS_LOOP_NO_SWAP:

    dec     R_DATA
    brne    _ST_PASS_LOOP
    ; koniec petli _ST_PASS_LOOP

    ; koniec gdy nic nie zosalo zmienione
    sbrs    R_CONTROL, R_CONTROL_SORT_SWAPED_BIT
    rjmp    _ST_END

    dec     R_LOOP
    brne    _ST_LOOP
    ; koniec petli _ST_LOOP
_ST_END:

    ret

;----------------------------------------------------------------------------
CHECK_HEATERS:
    lds R_TMP_1, STATE

_CH_CHECK:
    ; grza³ka 0
_CH_0:
    ldi     R_POINTER_H, high(HEAT_0)
    ldi     R_POINTER_L, low(HEAT_0)
    rcall   CHECK_HEATER_POINTER
    sts     HEAT_0_CONFIG_H, R_DATA
    lds     R_TMP_1, STATE
    ; w³¹czenie grza³ki 0
    brtc    PC + 3
    sbi     HEATER_0_PORT, HEATER_0_BIT
    sbr     R_TMP_1, 1 << STATE_HEAT_0_BIT
    ; wy³¹czenie grza³ki 0
    brts    PC + 3
    cbi     HEATER_0_PORT, HEATER_0_BIT
    cbr     R_TMP_1, 1 << STATE_HEAT_0_BIT
    sts     STATE, R_TMP_1

    ; grza³ka 1
    ; sprawdzenie czy grzalka 1 mo¿e byc wylaczona grzalka 0
    sbrs    R_TMP_1, STATE_HEAT_0_BIT
    rjmp    _CH_1
    ; sprawdzenie czy grza³ka 1 mo¿e grzaæ jednoczeœnie z grza³k¹ 0
    lds     R_TMP_1, HEAT_1_CONFIG_H
    sbrs    R_TMP_1, 6
    rjmp    _CH_1_OFF

    ; obsluga grzalki 1
_CH_1:
    ldi     R_POINTER_H, high(HEAT_1)
    ldi     R_POINTER_L, low(HEAT_1)
    rcall   CHECK_HEATER_POINTER
    sts     HEAT_1_CONFIG_H, R_DATA
    lds     R_TMP_1, STATE
    ; w³¹czenie grza³ki 0
    brtc    PC + 3
    sbi     HEATER_1_PORT, HEATER_1_BIT
    sbr     R_TMP_1, 1 << STATE_HEAT_1_BIT
    ; wy³¹czenie grza³ki 0
    brts    PC + 3
_CH_1_OFF:
    cbi     HEATER_1_PORT, HEATER_1_BIT
    cbr     R_TMP_1, 1 << STATE_HEAT_1_BIT
    sts     STATE, R_TMP_1

    rjmp    _CH_END


_CH_OFF:
    lds     R_TMP_1, STATE
    cbi     HEATER_0_PORT, HEATER_0_BIT
    cbi     HEATER_1_PORT, HEATER_1_BIT
    cbr     R_TMP_1, 1 << STATE_HEAT_0_BIT || 1 << STATE_HEAT_1_BIT
    sts     STATE, R_TMP_1

_CH_END:

    ret
;----------------------------------------------------------------------------
; Czyta ustawienia parametrów grzania z adresu R_POINTER i jezeli grzalka ma 
; Koniecznoœæ w³¹czenia grza³ki jest zwracana przez flagê SREG-T.
; Starszy bajt konfiguracji HEAT_(n)_CONFIG_H z uwzglednieniem bitu ¿¹dania
; w³¹czenia grza³ki (odpowiednik SREG-T) jest zwracany przez R_DATA
; U¿ywane rejestry:
;   R_HEAT_CONFIG_L, R_HEAT_CONFIG_H, 
;   R_HEAT_TEMPERATURE_ON, R_HEAT_TEMPERATURE_OFF,
;   R_HEAT_TEMPERATURE_ON_L, R_HEAT_TEMPERATURE_ON_H,
;   R_HEAT_TEMPERATURE_ON_CALC_L, R_HEAT_TEMPERATURE_ON_CALC_H,
;   R_HEAT_TEMPERATURE_OFF_L, R_HEAT_TEMPERATURE_OFF_H,
;   R_HEAT_TEMPERATURE_OFF_CALC_L, R_HEAT_TEMPERATURE_OFF_CALC_H,
;   R_LOOP, R_TMP_1, R_TMP_2, R_DATA, R_DATA
CHECK_HEATER_POINTER:
    clt

    ld      R_HEAT_CONFIG_H, R_POINTER+
    ld      R_HEAT_CONFIG_L, R_POINTER+ 
    ld      R_HEAT_TEMPERATURE_ON, R_POINTER+
    ld      R_HEAT_TEMPERATURE_OFF, R_POINTER+
    ; ustawienie wskaznika na tablice temperatur
    ldi     R_POINTER_H, high(SENSORS_TEMPERATURE)
    ldi     R_POINTER_L, low(SENSORS_TEMPERATURE)
    lds     R_LOOP, SENSOR_COUNT
    clr     R_HEAT_TEMPERATURE_ON_L
    clr     R_HEAT_TEMPERATURE_ON_L
    movw    R_HEAT_TEMPERATURE_ON_CALC_L, R_HEAT_TEMPERATURE_ON_L
    movw    R_HEAT_TEMPERATURE_OFF_L, R_HEAT_TEMPERATURE_ON_L
    movw    R_HEAT_TEMPERATURE_OFF_CALC_L, R_HEAT_TEMPERATURE_ON_L
    ; Zawsze 0, u¿ywany do dodawania przy temperaturze œredniej
    clr     R_TMP_2
    ; R_DATA bêdzie potrzebny do okreœlenia czy w³¹czyæ/Wylaczyc poniewa¿
    ; R_HEAT_CONFIG_ulega zmianie przy wyliczaniu temperatur
    mov     R_DATA, R_HEAT_CONFIG_H

    ; sprawdzenie metody pomiaru, bity 5,4:
    ;   00-brak,
    ;   01-srednia,
    ;   10-minimalna dla dolnego progu, maksymalna dla górnego progu,
    ;   11-maksymalna dla dolnego progu, minimalna dla górnego progu,
    mov     R_TMP_1, R_HEAT_CONFIG_H
    andi    R_TMP_1, 0b00110000
    cpi     R_TMP_1, 0b00010000
    brlo    _CHP_DISABLED
    breq    _CHP_CALCULATE_T_AVG
    ; dla wyliczen min max temperatury progów musz¹ byæ przepisane 
    ; poniewa¿ nie sa wyliczane
    mov     R_HEAT_TEMPERATURE_ON_L, R_HEAT_TEMPERATURE_ON
    mov     R_HEAT_TEMPERATURE_OFF_L, R_HEAT_TEMPERATURE_OFF
    ; dalsze trybu rozdzielenie
    cpi     R_TMP_1, 0b00110000
    brlo    _CHP_CALCULATE_T_ON_MIN_OFF_MAX
    breq    _CHP_CALCULATE_T_ON_MAX_OFF_MIN

_CHP_DISABLED:
    rjmp    _CHP_OFF

_CHP_CALCULATE_T_AVG:
_CHP_CALCULATE_T_AVG_LOOP:
    ; dodanie temperatury czujnika
    ld      R_TMP_1, R_POINTER+

    ; Sprawdzenie czy czujnik jest uwzglêdniony w konfigu
    lsr     R_HEAT_CONFIG_H
    ror     R_HEAT_CONFIG_L
    brcc    _CHP_CALCULATE_T_AVG_LOOP_SKIP

    ; dodanie temperatury czujnika
    add     R_HEAT_TEMPERATURE_ON_CALC_L, R_TMP_1
    adc     R_HEAT_TEMPERATURE_ON_CALC_H, R_TMP_2
    ; dodanie temperatury On
    add     R_HEAT_TEMPERATURE_ON_L, R_HEAT_TEMPERATURE_ON
    adc     R_HEAT_TEMPERATURE_ON_H, R_TMP_2
    ; dodanie temperatury Off
    add     R_HEAT_TEMPERATURE_OFF_L, R_HEAT_TEMPERATURE_OFF
    adc     R_HEAT_TEMPERATURE_OFF_H, R_TMP_2

_CHP_CALCULATE_T_AVG_LOOP_SKIP:

    dec     R_LOOP
    brne    _CHP_CALCULATE_T_AVG_LOOP

    movw    R_HEAT_TEMPERATURE_OFF_CALC_L, R_HEAT_TEMPERATURE_ON_CALC_L
    rjmp    _CHP_CHECK

_CHP_CALCULATE_T_ON_MIN_OFF_MAX:
    set     ; flaga SREG-T mówi, ¿eby bezwzglêdnie ustawiæ 
            ; R_HEAT_TEMPERATURE_ON_0 i R_HEAT_TEMPERATURE_OFF_0
_CHP_CALCULATE_T_ON_MIN_OFF_MAX_LOOP:
    ld      R_TMP_1, R_POINTER+

    ; Sprawdzenie czy czujnik jest uwzglêdniony w konfigu
    lsr     R_HEAT_CONFIG_H
    ror     R_HEAT_CONFIG_L
    brcc    _CHP_CALCULATE_T_ON_MIN_OFF_MAX_LOOP_SKIP

    ; minimalna temperatura dla progu w³¹czania
    brts    PC + 3 ; dla pierwszego czujnika
    cp      R_TMP_1, R_HEAT_TEMPERATURE_ON_CALC_L
    brsh    PC + 2
    mov     R_HEAT_TEMPERATURE_ON_CALC_L, R_TMP_1
    ; maksymalna temperatura dla progu wy³¹czania
    brts    PC + 3 ; dla pierwszego czujnika
    cp      R_HEAT_TEMPERATURE_OFF_CALC_L, R_TMP_1
    brsh    PC + 2
    mov     R_HEAT_TEMPERATURE_OFF_CALC_L, R_TMP_1
    ; kasowanie flagi bezwzglêdnego ustawienia
    clt

_CHP_CALCULATE_T_ON_MIN_OFF_MAX_LOOP_SKIP:

    dec     R_LOOP
    brne    _CHP_CALCULATE_T_ON_MIN_OFF_MAX_LOOP

    rjmp    _CHP_CHECK

_CHP_CALCULATE_T_ON_MAX_OFF_MIN:
    set     ; flaga SREG-T mówi, ¿eby bezwzglêdnie ustawiæ 
            ; R_HEAT_TEMPERATURE_ON_0 i R_HEAT_TEMPERATURE_OFF_0
_CHP_CALCULATE_T_ON_MAX_OFF_MIN_LOOP:
    ld      R_TMP_1, R_POINTER+

    ; Sprawdzenie czy czujnik jest uwzglêdniony w konfigu
    lsr     R_HEAT_CONFIG_H
    ror     R_HEAT_CONFIG_L
    brcc    _CHP_CALCULATE_T_ON_MAX_OFF_MIN_LOOP_SKIP

    ; maksymalna temperatura dla progu w³¹czania
    brts    PC + 3 ; dla pierwszego czujnika
    cp      R_HEAT_TEMPERATURE_ON_CALC_L, R_TMP_1
    brsh    PC + 2
    mov     R_HEAT_TEMPERATURE_ON_CALC_L, R_TMP_1
    ; minimalna temperatura dla progu wy³¹czania
    brts    PC + 3 ; dla pierwszego czujnika
    cp      R_TMP_1, R_HEAT_TEMPERATURE_OFF_CALC_L
    brsh    PC + 2
    mov     R_HEAT_TEMPERATURE_OFF_CALC_L, R_TMP_1
    ; kasowanie flagi bezwzglêdnego ustawienia
    clt

_CHP_CALCULATE_T_ON_MAX_OFF_MIN_LOOP_SKIP:

    dec     R_LOOP
    brne    _CHP_CALCULATE_T_ON_MAX_OFF_MIN_LOOP

_CHP_CHECK:
    ; Sprawdzenie czy wlaczyc
    sbrc    R_DATA, 7
    rjmp    _CHP_CHECK_ON_SKIP
_CHP_CHECK_ON:
    cp      R_HEAT_TEMPERATURE_ON_L, R_HEAT_TEMPERATURE_ON_CALC_L
    cpc     R_HEAT_TEMPERATURE_ON_H, R_HEAT_TEMPERATURE_ON_CALC_H
    brlo    _CHP_CHECK_ON_SKIP
_CHP_ON:
    sbr     R_DATA, 1 << 7
_CHP_CHECK_ON_SKIP:

    ; sprawdzenie czy wylaczyc
    sbrs    R_DATA, 7
    rjmp    _CHP_CHECK_OFF_SKIP
_CHP_CHECK_OFF:
    cp      R_HEAT_TEMPERATURE_OFF_CALC_L, R_HEAT_TEMPERATURE_OFF_L
    cpc     R_HEAT_TEMPERATURE_OFF_CALC_H, R_HEAT_TEMPERATURE_OFF_H
    brlo    _CHP_CHECK_OFF_SKIP
_CHP_OFF:
    cbr     R_DATA, 1 << 7
_CHP_CHECK_OFF_SKIP:

    bst     R_DATA, 7

_CHP_END:

    ret
;----------------------------------------------------------------------------
.macro  EE_BYTE_TO_REG
    ldi     R_TMP_1, @1
    out     EEARL, R_TMP_1
    sbi     EECR, EERE
    in      @0, EEDR
.endmacro
;----------------------------------------------------------------------------
LOAD_FROM_EE:
    ; poczekanie na ewentualny poprzedni zapis
    sbic    EECR, EEPE
    rjmp    PC-1

    ; Adres I2C
    EE_BYTE_TO_REG      R_I2C_MY_ADDRESS, E_I2C_MY_ADDRESS
    ; korekta gdy adres nie jest zapisany
    ldi     R_TMP_1, I2C_MY_ADDRESS_DEFAULT
    sbrc    R_I2C_MY_ADDRESS, 0
    mov     R_I2C_MY_ADDRESS, R_TMP_1

    ; STATE
    EE_BYTE_TO_REG      R_TMP_1, E_DEFAULT_STATE
    ; korekta STATE
    cpi     R_TMP_1, 0xFF
    brne    PC + 2
    ldi     R_TMP_1, 0
    sts     STATE, R_TMP_1

    ; SENSOR_COUNT
    EE_BYTE_TO_REG      R_TMP_1, E_SENSOR_COUNT
    ; korekta
    cpi     R_TMP_1, SENSOR_COUNT_MAX + 1
    brlo    PC + 2
    ldi     R_TMP_1, 0
    sts     SENSOR_COUNT, R_TMP_1

    ; Przepisanie ca³ego bloku paiêci odzwierciedlonego w EE
    ldi     R_TMP_1, E_STORAGE_MEMORY_BEGIN
    ldi     R_TMP_2, E_STORAGE_MEMORY_END
    ldi     R_POINTER_H, high(STORAGE_IN_E_BEGIN)
    ldi     R_POINTER_L, low(STORAGE_IN_E_BEGIN)
_LFE_LOOP:

    out     EEARL, R_TMP_1
    sbi     EECR, EERE
    in      R_DATA, EEDR

    st      R_POINTER+, R_DATA
    inc     R_TMP_1
    cp      R_TMP_1, R_TMP_2
    brne    _LFE_LOOP

    ; korekta E_REPEAT_TIME
    lds     R_TMP_1, REPEAT_TIME
    andi    R_TMP_1, 1 << STATE_CONTINUE_BIT        |  \
                     1 << STATE_SORT_BIT            |  \
                     1 << STATE_SORT_DESCENDING_BIT
    sts     REPEAT_TIME, R_TMP_1

    ret
;----------------------------------------------------------------------------
SAVE_DEFAULT_STATE_TO_EE:
    ldi     R_LOOP, E_DEFAULT_STATE
    lds     R_DATA, STATE
    andi    R_DATA, 1 << STATE_CONTINUE_BIT         |  \
                    1 << STATE_SORT_BIT             |  \
                    1 << STATE_SORT_DESCENDING_BIT
    rjmp    SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_MY_I2C_ADDRESS_TO_EE:
    ldi     R_LOOP, E_I2C_MY_ADDRESS
    mov     R_DATA, R_I2C_MY_ADDRESS
    rjmp    SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_REPEAT_TIME_TO_EE:
    ldi     R_LOOP, REPEAT_TIME - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, REPEAT_TIME
    rjmp    SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_SENSORS_TO_EE:
    ; zapis iloœci czujników
    ldi     R_LOOP, E_SENSOR_COUNT
    lds     R_DATA, SENSOR_COUNT
    rcall   SAVE_DATA_TO_EE
    ; zapis ROMów czujników
    ldi     R_POINTER_H, high(SENSOR_ROMS)
    ldi     R_POINTER_L, low(SENSOR_ROMS)
    ldi     R_LOOP, E_STORAGE_MEMORY_BEGIN + SENSOR_ROMS - STORAGE_IN_E_BEGIN
    ; pêtla zapisu poszczególnych czujników
    lds     R_SENSOR_NR, SENSOR_COUNT
_SSTE_LOOP_1:
    ; pêtla zapisu pojedynczego czujnika
    ldi     R_TMP_2, O_WIRE_ROM_STORE_SIZE
_SSTE_LOOP_2:
    ; zapis
    ld      R_DATA, R_POINTER+
    inc     R_LOOP
    rcall   SAVE_DATA_TO_EE

    dec     R_TMP_2
    brne    _SSTE_LOOP_2

    dec     R_SENSOR_NR
    brne    _SSTE_LOOP_1

    ret
;----------------------------------------------------------------------------
SAVE_HEAT_0_CONFIG_TO_EE:
    ldi     R_LOOP, HEAT_0_CONFIG_H - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_0_CONFIG_H
    rcall   SAVE_DATA_TO_EE
    ldi     R_LOOP, HEAT_0_CONFIG_L - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_0_CONFIG_L
    rjmp   SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_HEAT_0_TEMPERATURES_TO_EE:
    ldi     R_LOOP, HEAT_0_TEMPERATURE_ON - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_0_TEMPERATURE_ON
    rcall   SAVE_DATA_TO_EE
    ldi     R_LOOP, HEAT_0_TEMPERATURE_OFF - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_0_TEMPERATURE_OFF
    rjmp   SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_HEAT_1_CONFIG_TO_EE:
    ldi     R_LOOP, HEAT_1_CONFIG_H - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_1_CONFIG_H
    rcall   SAVE_DATA_TO_EE
    ldi     R_LOOP, HEAT_1_CONFIG_L - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_1_CONFIG_L
    rjmp   SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_HEAT_1_TEMPERATURES_TO_EE:
    ldi     R_LOOP, HEAT_1_TEMPERATURE_ON - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_1_TEMPERATURE_ON
    rcall   SAVE_DATA_TO_EE
    ldi     R_LOOP, HEAT_1_TEMPERATURE_OFF - STORAGE_IN_E_BEGIN + E_STORAGE_MEMORY_BEGIN
    lds     R_DATA, HEAT_1_TEMPERATURE_OFF
    rjmp   SAVE_DATA_TO_EE
;----------------------------------------------------------------------------
SAVE_DATA_TO_EE:
    ; poczekanie na poprzedni zapis
    sbic    EECR, EEPE
    rjmp    PC-1

    out     EEARL, R_LOOP

    ; pobranie istniejacej wartosci
    sbi     EECR, EERE
    in      R_TMP_1, EEDR
    cp      R_DATA, R_TMP_1
    breq    _SDTE_END

    ; zapis
    out     EEDR, R_DATA

    cli
    sbi     EECR, EEMPE
    sbi     EECR, EEPE
    sei

_SDTE_END:

    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;       Obsluga I2C
;----------------------------------------------------------------------------
.macro  I2C_BYTE_RECEIVED
    sbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
.endmacro
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.include    "OWireMaster.asm"
.include    "DS18B20.asm"
.include    "I2CTinySlaveMacro1.inc"
.include    "I2CTinySlave.asm"
.include    "Wait_Tiny25_Timer0.asm"
