/*
 * SterownikOswietlenia.asm
 *
 *  Created: 2015-05-26 13:41:07
 *   Author: rafal
 */ 

.include    "SterownikOswietlenia.inc"


.macro  STSI8
    ldi     R_TMP_1, @1
    sts     @0, R_TMP_1
.endmacro

.macro  STSI16
    ldi     R_TMP_1, low( @1 )
    sts     @0, R_TMP_1
    ldi     R_TMP_1, high( @1 )
    sts     @0 + 1, R_TMP_1
.endmacro

.macro  LDI16
    ldi     @0H, high(@1)
    ldi     @0L, low(@1)
.endmacro

; Wait na timerze 0 8 bit - attiny24-44-84
.macro  START_TIMER_0_TICKS_T24_T44_T84
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
; Wait na timerze 0 8 bit - attiny26-46-86
.macro  START_TIMER_0_TICKS_T26_T46_T86
    .set    TICKS   = (@0) - 10
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
    ldi     R_TMP_1, 0
    out     TCCR0B, R_TMP_1  ; zatrzymanie timera
    out     TCNT0L, R_TMP_1  ; zerowanie licznika
    ldi     R_TMP_1, TICKS
    out     OCR0B, R_TMP_1  ; wartosc licznika
    ldi     R_TMP_1, 1 << OCF0B
    out     TIFR, R_TMP_1 ; kasownie flagi
    ldi     R_TMP_1, _TCCR0B
    out     TCCR0B, R_TMP_1 ; uruchomienie timera z resetem preskalera
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER_0_T26_T46_T86
    in      R_TMP_1, TIFR
    sbrs    R_TMP_1, OCF0B
    rjmp    PC - 2
.endmacro
;----------------------------------------------------------------------------
; Wait na timerze 0 8 bit - ATMEGA8
.macro  START_TIMER_2_TICKS_M8
    .set    TICKS   = (@0) - 10
    .set    _TCCR2      = 0 << CS22 | 0 << CS21 | 1 << CS20
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 8 - 1
        .set    _TCCR2      = 0 << CS22 | 1 << CS21 | 0 << CS20
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 32
        .set    _TCCR2      = 0 << CS22 | 1 << CS21 | 1 << CS20
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 64
        .set    _TCCR2      = 1 << CS22 | 0 << CS21 | 0 << CS20
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 128
        .set    _TCCR2      = 1 << CS22 | 0 << CS21 | 1 << CS20
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 256
        .set    _TCCR2      = 1 << CS22 | 1 << CS21 | 0 << CS20
    .endif
    .if ( TICKS > 0xFF )
        .set    TICKS   = (@0) / 1024
        .set    _TCCR2      = 1 << CS22 | 1 << CS21 | 1 << CS20
    .endif
    .if ( TICKS < 1 )
        .set    TICKS = 1
        .set    _TCCR2      = 0 << CS22 | 0 << CS21 | 1 << CS20
    .endif    
    ldi     R_TMP_1, 0
    out     TCCR2, R_TMP_1  ; zatrzymanie timera
    out     TCNT2, R_TMP_1  ; zerowanie licznika
    ldi     R_TMP_1, TICKS
    out     OCR2, R_TMP_1  ; wartosc licznika
    ldi     R_TMP_1, 1 << OCF2
    out     TIFR, R_TMP_1 ; kasownie flagi
    ldi     R_TMP_1, _TCCR2
    out     TCCR2, R_TMP_1 ; uruchomienie timera
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER_2_M8
    in      R_TMP_1, TIFR
    sbrs    R_TMP_1, OCF2
    rjmp    PC - 2
.endmacro
;----------------------------------------------------------------------------
.macro  START_TIMER_TICKS
    START_TIMER_2_TICKS_M8     (@0)
.endmacro
;----------------------------------------------------------------------------
.macro  START_TIMER_MICROSEC
    START_TIMER_TICKS   (((@0) * FREQUENCY) / 1000000)
.endmacro
;----------------------------------------------------------------------------
.macro  WAIT_TIMER
    WAIT_TIMER_2_M8
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

.cseg

.org        0               rjmp    RESET
.org        OC1Aaddr        sbr     R_CONTROL, 1 << R_CONTROL_TIMER_BIT
                            reti
.org        TWIaddr         rjmp    TWI_ITERRUPT
;.org        USI_STRaddr     rjmp    USI_I2C_START
;.org        USI_OVFaddr     rjmp    USI_I2C_OV

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

    ; ustawienie zegara na 16 MHz
 ;   ldi     R_TMP_1, OSCCAL_DEFAULT
 ;   out     OSCCAL, R_TMP_1
 ;   sts     OSCCAL_VALUE, R_TMP_1
 ;   ldi     r_tmp_1, 1<<plle
 ;   out     pllcsr, r_tmp_1
 ;   
    ; inicjowanie zmiennych - rejestry
    clr     R_CONTROL
    clr     R_ZERO
    ldi     R_TMP_1, 0xFF
    mov     R_FF, R_TMP_1

    ; inicjacja IO
    out     PORTB, R_ZERO
    out     DDRB, R_ZERO
    out     PORTC, R_ZERO
    out     DDRC, R_ZERO
    out     PORTD, R_ZERO
    ldi     R_TMP_1, 0xFF
    out     DDRD, R_ZERO
    ;sbi     LED_CLK_DDR, LED_CLK_BIT
    ;sbi     LED_DATA_DDR, LED_DATA_BIT
    ;cbi     LED_CLK_PORT, LED_CLK_BIT
    ;cbi     LED_DATA_PORT, LED_DATA_BIT
    sbi     LED_SPI_MOSI_DDR, LED_SPI_MOSI_BIT
    sbi     LED_SPI_SCK_DDR, LED_SPI_SCK_BIT
    sbi     LED_POWER_DDR, LED_POWER_BIT
    sbi     BUTTON_H_0_DDR, BUTTON_H_0_BIT
    sbi     BUTTON_H_1_DDR, BUTTON_H_1_BIT
    sbi     BUTTON_H_2_DDR, BUTTON_H_2_BIT
    cbi     BUTTON_H_0_PORT, BUTTON_H_0_BIT
    cbi     BUTTON_H_1_PORT, BUTTON_H_1_BIT
    cbi     BUTTON_H_2_PORT, BUTTON_H_2_BIT

    ; Inicjowanie SPI dla LED - jest wyzej
    ;ldi     R_TMP_1, (1 << LED_SPI_MOSI_BIT) | (1 << LED_SPI_SCK_BIT)
    ;out     LED_SPI_SCK_DDR, R_TMP_1
    ; Wlaczenie mastera SPI dla LED
    ldi     R_TMP_1, (1 << SPE) | (1 << MSTR) | (0 << CPHA) | (0 << SPR1) | (1 << SPR0)
    out     SPCR, R_TMP_1
    
    ; Zerowanie wszystkich komórek pamiêci
    LDI16   R_POINTER_A, SRAM_START
    LDI16   R_POINTER_B, SRAM_SIZE
    ldi     R_TMP_1, 0
CLEAR_RAM_LOOP:
    st      R_POINTER_A+, R_TMP_1
    inc     R_TMP_1
    sbiw    R_POINTER_B, 1
    brne    CLEAR_RAM_LOOP

    ; inicjowanie zmiennych - pamiec
    STSI8   DEVICE_TYPE, DEVICE_TYPE_DEF
    STSI8   DEVICE_VERSION, DEVICE_VERSION_DEF
    clr     R_TIMER_CHECK_BUTTONS_COUNTER
    STSI8   TIMER_CHECK_BUTTONS_COUNT, 5
    clr     R_TIMER_SEND_LED_DATA_COUNTER
    STSI8   TIMER_SEND_LED_DATA_COUNT, 4
    ; czyszczenie obszaru LED
    LDI16   R_POINTER_A, LED_SECTION_0
    rcall   CLEAR_LED_SECTION_POINTER_A
    LDI16   R_POINTER_A, LED_SECTION_1
    rcall   CLEAR_LED_SECTION_POINTER_A
    LDI16   R_POINTER_A, LED_SECTION_2
    rcall   CLEAR_LED_SECTION_POINTER_A
    
    ; konfiguracja timera zmian wartosci
    .equ    T_PRESCALER = 8
    .equ    T_FREQUENCY = 100
    .equ    T_VALUE = FREQUENCY / T_FREQUENCY / T_PRESCALER - 1
    ldi     R_TMP_1, T_VALUE >> 8
    out     OCR1AH, R_TMP_1
    ldi     R_TMP_1, T_VALUE & 0xFF
    out     OCR1AL, R_TMP_1
    ldi     R_TMP_1, 0 << WGM13 | 1 << WGM12 | 0 << CS12 | 1 << CS11 | 0 << CS10
    out     TCCR1B, R_TMP_1
    ldi     R_TMP_1, 1 << OCIE1A
    out     TIMSK, R_TMP_1
    
;    TEST_X:
;    LDI16   R_POINTER_A, LED_SECTION_2
;    rcall   CLEAR_LED_SECTION_POINTER_A
;    rjmp    TEST_X

    ; DUPA out     OCR1AH, R_TMP_2
    ; DUPA out     OCR1AL, R_TMP_1
    ; DUPA ldi     R_TMP_1, 1 << WGM12 | 1 << CS11
    ; DUPA out     TCCR1B, R_TMP_1
    ; DUPA sbi     TIMSK1, OCIE1A

    ; inicjowanie I2C
;    rcall   USI_I2C_INIT
    rcall   TWI_M_SLAVE_INIT

    ; wczytanie konfiguracji
    rcall   LOAD_FROM_EE

    ; Testowe dane sekcji 0
    STSI8   LED_DATA_COUNT, 9
    STSI8   LED_SECTION_0_STATE_L, 0b00000101
    STSI8   LED_SECTION_0_STATE_H, 0b00000001
    STSI8   LED_SECTION_0_DATA_SKIP, 3
    STSI16  LED_SECTION_0_COUNTER, 0
    STSI8   LED_SECTION_0_DATA + 0, 0x1
    STSI8   LED_SECTION_0_DATA + 1, 0x11
    STSI8   LED_SECTION_0_DATA + 2, 0x21
    STSI8   LED_SECTION_0_DATA + 3, 0x51
    STSI8   LED_SECTION_0_DATA + 4, 0x61
    STSI8   LED_SECTION_0_DATA + 5, 0x71
    STSI8   LED_SECTION_0_DATA + 6, 0x91
    STSI8   LED_SECTION_0_DATA + 7, 0xA1
    STSI8   LED_SECTION_0_DATA + 8, 0xB1

    /*
_TEST_:
    ldi     R_POINTER_B_H, high(LED_SECTION_0)
    ldi     R_POINTER_B_L, low(LED_SECTION_0)
    rcall   _CSLPB_INCREMENT
    rcall   CALCULATE_LED_DATA_0
    rjmp _TEST_
    */

    ;STSI8   LED_R, 200
    ;STSI8   LED_g, 190
    ;STSI8   LED_b, 80

    ; ldi     R_MUL_A_0, 11
    ; ldi     R_MUL_A_1, 22
    ; ldi     R_MUL_A_2, 55
    ; ldi     R_MUL_B_0, 77
    ; rcall   MUL_U8_U8_3_F
    ; rcall   MUL_U8_U8_3_F
    ; rcall   MUL_U8_U8_3_F

    ; nop
    ; rcall   SEND_LED_DATA
    ; nop

    sei

MAIN_LOOP:
    ; przetwarzainie zadania z I2C
    sbrc    R_CONTROL, R_CONTROL_I2C_READ_BYTE_BIT
    rcall   I2C_CHECK_REQUEST

    sbrc    R_CONTROL, R_CONTROL_TIMER_BIT
    rcall   TIMER

    rjmp    MAIN_LOOP
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
I2C_CHECK_REQUEST:
    cbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
    
    ; Identyfikator rozkazu
    lds     R_DATA, I2C_RECV_DATA_REQUEST

    ; sprawdzenie ilosci argumentow
    mov     R_TMP_1, R_I2C_BUF_POINTER_L
    mov     R_TMP_2, R_I2C_BUF_POINTER_H
    ldi     R_TMP_3, high(I2C_RECV_DATA_ARGS)
    subi    R_TMP_1, low(I2C_RECV_DATA_ARGS)
    sbc     R_TMP_2, R_TMP_3
    cpi     R_TMP_1, 1
    brlo    _I2C_CR_0_ARG
    breq    _I2C_CR_1_ARG
    rjmp    _I2C_CR_N_ARGS

_I2C_CR_0_ARG:
    ; Zapis danych do EE
    mov     R_TMP_2, R_DATA
    andi    R_TMP_2, I2C_REQUEST_SAVE_EE_MASK
    cpi     R_TMP_2, I2C_REQUEST_SAVE_EE
    breq    _I2C_CR_REQUEST_SAVE_EE

    ; Rozkaz resetu
    cpi     R_DATA, I2C_REQUEST_RESET
    breq    _I2C_CR_REQUEST_RESET
    
    rjmp    _I2C_CR_END

_I2C_CR_1_ARG:
    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS, 7 lub 10 bit
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    breq    _I2C_CR_SET_SLAVE_ADDRES_H

    cpi     R_DATA, I2C_REQUEST_SET_POINT_COUNT
    breq    _I2C_CR_SET_POINT_COUNT

    rjmp    _I2C_CR_END

_I2C_CR_N_ARGS:
    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS, 10 bit
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    breq    _I2C_CR_SET_SLAVE_ADDRES_L

    mov     R_TMP_2, R_DATA
    andi    R_TMP_2, I2C_REQUEST_SET_SECTION_CONTROL_MASK
    cpi     R_TMP_2, I2C_REQUEST_SET_SECTION_CONTROL
    breq    _I2C_CR_SET_SECTION_CONTROL

    mov     R_TMP_2, R_DATA
    andi    R_TMP_2, I2C_REQUEST_SET_SECTION_DATA_MASK
    cpi     R_TMP_2, I2C_REQUEST_SET_SECTION_DATA
    breq    _I2C_CR_SET_SECTION_DATA

    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_SAVE_EE:
    mov     R_TMP_3, R_DATA
    andi    R_TMP_3, ~I2C_REQUEST_SAVE_EE_MASK
    rcall   SAVE_TO_EE
    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_RESET:
    ; Rozkaz RESET
    cli
    rjmp    RESET_SOFT

_I2C_CR_SET_SLAVE_ADDRES_H:
    lds     R_TMP_1, I2C_RECV_DATA_ARGS + 0
    cpi     R_TMP_1, 0b1111000
    brsh    _I2C_CR_END ; koniec gdy adres jest za wysoki - zarezerwowany
    cpi     R_TMP_1, 0b1000
    brlo    _I2C_CR_END ; koniec gdy adres jest za niski - zarezerwowany
    lsl     R_TMP_1
    ; adres jest poprawny jak na 7 bitowy
    lsl     R_TMP_1
    out     TWAR, R_TMP_1
    rjmp    _I2C_CR_END

_I2C_CR_SET_SLAVE_ADDRES_L:
    lds     R_TMP_1, I2C_RECV_DATA_ARGS + 0
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 1
    cpi     R_TMP_1, high(1024)
    brsh    _I2C_CR_END ; koniec gdy niepoprawny adres
    ; sformatowanie adresu do bezposredniego porównania
    lsl     R_TMP_1
    sbr     R_TMP_1, 0b11110000
    out     TWAR, R_TMP_1
    mov     R_I2C_MY_ADDRESS_L, R_TMP_2
    rjmp    _I2C_CR_END

_I2C_CR_SET_POINT_COUNT:
    lds     R_TMP_1, I2C_RECV_DATA_ARGS + 0
    ; sprawdzenie poprawnosci argumentu, wartosc z przedzia³u <0;LED_DATA_COUNT_MAX>
    cpi     R_TMP_1, LED_DATA_COUNT_MAX + 1
    brsh    _I2C_CR_END
    sts     LED_DATA_COUNT, R_TMP_1
    rjmp    _I2C_CR_END

_I2C_CR_SET_SECTION_CONTROL:
    andi    R_DATA, 0x03
    rcall   SECTION_NR_TO_RPOINT_A
    cpi     R_TMP_1, 2
    brlo    _I2C_CR_END
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 0
    std     R_POINTER_A + LED_SECTION_0_STATE_H - LED_SECTION_0, R_TMP_2
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 1
    std     R_POINTER_A + LED_SECTION_0_STATE_l - LED_SECTION_0, R_TMP_2
    cpi     R_TMP_1, 3
    brlo    _I2C_CR_END
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 2
    std     R_POINTER_A + LED_SECTION_0_DATA_SKIP - LED_SECTION_0, R_TMP_2    
    rjmp    _I2C_CR_END

_I2C_CR_SET_SECTION_DATA:
    lds     R_LOOP, LED_DATA_COUNT
    cp      R_TMP_1, R_LOOP
    brlo    _I2C_CR_END
    andi    R_DATA, 0x03
    rcall   SECTION_NR_TO_RPOINT_A
    adiw    R_POINTER_A, LED_SECTION_0_DATA - LED_SECTION_0
    LDI16   R_POINTER_B, I2C_RECV_DATA_ARGS
_I2C_CR_SET_SECTION_DATA_LOOP:
    dec     R_LOOP
    brmi   _I2C_CR_END
    ld      R_TMP_2, R_POINTER_B+
    st      R_POINTER_A+, R_TMP_2
    rjmp    _I2C_CR_SET_SECTION_DATA_LOOP

_I2C_CR_END:
    ret
;----------------------------------------------------------------------------
SECTION_NR_TO_RPOINT_A:
    LDI16   R_POINTER_A, LED_SECTION_0
_SNTPA_LOOP:
    dec     R_DATA
    sbrc    R_DATA, 7
    ret
    adiw    R_POINTER_A, LED_SECTION_1 - LED_SECTION_0
    rjmp    _SNTPA_LOOP
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
TIMER:
    cbr     R_CONTROL, 1 << R_CONTROL_TIMER_BIT

    ; Sprawdzenie klawiatury
    inc     R_TIMER_CHECK_BUTTONS_COUNTER
    lds     R_TMP_1, TIMER_CHECK_BUTTONS_COUNT
    cp      R_TMP_1, R_TIMER_CHECK_BUTTONS_COUNTER
    brne    _T_SKIP_SEND_CHECK_BUTTONS
    clr     R_TIMER_CHECK_BUTTONS_COUNTER
    rcall   CHECK_BUTTONS
_T_SKIP_SEND_CHECK_BUTTONS:

    ; Wyslanie danych LED
    inc     R_TIMER_SEND_LED_DATA_COUNTER
    lds     R_TMP_1, TIMER_SEND_LED_DATA_COUNT
    cp      R_TMP_1, R_TIMER_SEND_LED_DATA_COUNTER
    brne    _T_SKIP_SEND_LED_DATA
    ; wyliczenie i wyslanie danych
    clr     R_TIMER_SEND_LED_DATA_COUNTER
    ; obsluga wszystkich sekcji LED
    ; kasowanie flagi wlaczenia zasilania LED, flaga bêdzie ustawiana
    ; gdy któraœ sekcja bêdzie w³¹czona
    cbr     R_CONTROL, 1 << R_LED_POWER_BIT
    ; sekcla 0
    ldi     R_POINTER_B_H, high(LED_SECTION_0)
    ldi     R_POINTER_B_L, low(LED_SECTION_0)
    rcall   CHECK_SECTION_LED_POINTER_B

    ; sekcja 1
    ldi     R_POINTER_B_H, high(LED_SECTION_1)
    ldi     R_POINTER_B_L, low(LED_SECTION_1)
    rcall   CHECK_SECTION_LED_POINTER_B

    ; sekcja 2
    ldi     R_POINTER_B_H, high(LED_SECTION_2)
    ldi     R_POINTER_B_L, low(LED_SECTION_2)
    rcall   CHECK_SECTION_LED_POINTER_B
    
    ; wlaczenie/wylaczenie zasilania LED
    sbrc    R_CONTROL, R_LED_POWER_BIT
    sbi     LED_POWER_PORT, LED_POWER_BIT
    sbrs    R_CONTROL, R_LED_POWER_BIT
    cbi     LED_POWER_PORT, LED_POWER_BIT

    rcall   SEND_LED_DATA
_T_SKIP_SEND_LED_DATA:

    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.macro  CHECK_BUTTON_MACRO
    lds     R_DATA, BUTTON_STATE_COUNTER + (@0 * 2)
    ; zachowanie poprzedniego stanu
    bst     R_DATA, 0
    bld     R_DATA, 1
    ; pobranie stanu pinu
    cbr     R_DATA, 1
    sbic    BUTTON_V_@1_PIN, BUTTON_V_@1_BIT
    sbr     R_DATA, 1
    sts     BUTTON_STATE_COUNTER + (@0 * 2), R_DATA
.endmacro
;----------------------------------------------------------------------------
CHECK_BUTTONS:
    sbi     BUTTON_H_0_PORT, BUTTON_H_0_BIT
    WAIT_TIMER_MICROSEC     100
    CHECK_BUTTON_MACRO  0, 0
    CHECK_BUTTON_MACRO  1, 1
    CHECK_BUTTON_MACRO  2, 2
    cbi     BUTTON_H_0_PORT, BUTTON_H_0_BIT
    WAIT_TIMER_MICROSEC     100
    sbi     BUTTON_H_1_PORT, BUTTON_H_1_BIT
    WAIT_TIMER_MICROSEC     100
    CHECK_BUTTON_MACRO  3, 0
    CHECK_BUTTON_MACRO  4, 1
    CHECK_BUTTON_MACRO  5, 2
    cbi     BUTTON_H_1_PORT, BUTTON_H_1_BIT
    WAIT_TIMER_MICROSEC     100
    sbi     BUTTON_H_1_PORT, BUTTON_H_2_BIT
    WAIT_TIMER_MICROSEC     100
    CHECK_BUTTON_MACRO  6, 0
    CHECK_BUTTON_MACRO  7, 1
    CHECK_BUTTON_MACRO  8, 2
    cbi     BUTTON_H_1_PORT, BUTTON_H_2_BIT
    /*
    lds     R_DATA, BUTTON_STATE + 0
    ; pobranie stanu pinu
    cbr     R_CONTROL, 1 << R_CONTROL_BUTTON_PIN_BIT
    sbic    BUTTON_V_0_PIN, BUTTON_V_0_BIT
    sbr     R_CONTROL, 1 << R_CONTROL_BUTTON_PIN_BIT
    rcall   CHECK_BUTTON
    sts     BUTTON_STATE + 0, R_DATA
    */

    ; kontrola przyciskow
    ldi     ZH, high(CHECK_BUTTON_CONTROL_MONO)
    ldi     ZL, low(CHECK_BUTTON_CONTROL_MONO)
    ldi     R_POINTER_A_H, high(BUTTON_STATE_COUNTER)
    ldi     R_POINTER_A_L, low(BUTTON_STATE_COUNTER)
    ldi     R_LOOP, BUTTON_COUNT_MAX
_CB_LOOP:
    ldd     R_DATA, R_POINTER_A + 0
    ldd     R_COUNTER, R_POINTER_A + 1
    icall
    st      R_POINTER_A+, R_DATA
    st      R_POINTER_A+, R_COUNTER
    dec     R_LOOP
    brne    _CB_LOOP

    ret
;----------------------------------------------------------------------------
CHECK_BUTTON_CONTROL_MONO:
    ; trwale przycisniety
    mov     R_TMP_1, R_DATA
    andi    R_TMP_1, 1 << 1 | 1 << 0
    cpi     R_TMP_1, 1 << 1 | 1 << 0
    brne    _CBCM_NO_PRESSED
        ; inkrementacja licznika czasu nacisniecia jeszcze gdy nie osiagnal maks
        sbrs    R_DATA, 2
            rjmp    _CBCM_NO_INCREMENT_COUNTER
        ; inkrementacja do zdefiniowanej maksymalnej wartosci
        cpi     R_COUNTER, 100
        brsh    _CBCM_NO_INCREMENT_COUNTER
            inc    R_COUNTER
_CBCM_NO_INCREMENT_COUNTER:
        ; zmiana stanu aktywnosci przycisku
        ldi     R_TMP_2, 1 << 3
        sbrs    R_DATA, 2
            eor     R_DATA, R_TMP_2
        sbr     R_DATA, 1 << 2
_CBCM_NO_PRESSED:
    ; trwale zwolniony
    cpi     R_TMP_1, 0x00
    brne    _CBCM_NO_RELEASED
        cbr     R_DATA, (1 << 2)
        clr     R_COUNTER
_CBCM_NO_RELEASED:

    ret
;----------------------------------------------------------------------------
CHECK_SECTION_LED_POINTER_B:
    
    ; Sprawdzenie stanu przycisków przydzielonych do sekcji
    clr     R_DATA
    ; R_TMP_2-R_TMP_1: konfiguracja przycisków w sekcji
    ldd     R_TMP_1, R_POINTER_B + (LED_SECTION_0_STATE_L - LED_SECTION_0)
    ldd     R_TMP_2, R_POINTER_B + (LED_SECTION_0_STATE_H - LED_SECTION_0)
    ; R_POINTER_A: adres tablicy przycisków
    ldi     R_POINTER_A_H, high(BUTTON_STATE_COUNTER)
    ldi     R_POINTER_A_L, low(BUTTON_STATE_COUNTER)
    ldi     R_LOOP, BUTTON_COUNT_MAX
_CSLPB_CHECK_BUTTON_LOOP:
    ; sprawdzenie czy przycisk jest przydzielony
    lsr     R_TMP_2
    ror     R_TMP_1
    brcc    _CSLPB_CHECK_BUTTON_LOOP_SKIP
    ; przycisk jest przydzielony, sprawdzenie jego stanu
    ld      R_TMP_3, R_POINTER_A
    eor     R_DATA, R_TMP_3
          
_CSLPB_CHECK_BUTTON_LOOP_SKIP:
    adiw    R_POINTER_A_L, 2
    dec     R_LOOP
    brne    _CSLPB_CHECK_BUTTON_LOOP

    ; sprawdzenie czy wlaczyc czy wylaczyc sekcje
    sbrs    R_DATA, BUTTON_STATE_ON_BIT
    rjmp    _CSLPB_DECREMENT

_CSLPB_INCREMENT:
    ; Ustawienie flagi w³¹czaj¹cej zasilanie LED
    sbr     R_CONTROL, 1 << R_LED_POWER_BIT
    ; inkrementacja licznika
    ; inkrementacja mozliwa o ile licznik nie doszedl do pozycji w której
    ; wszystkie diody s¹ zaœwiecone.
    ; Œwiecenie wszystkich diod w sekcji okreœla 
    ; bit 7 z LED_SECTION_(N)_STATE_H
    ldd     R_TMP_1, R_POINTER_B + (LED_SECTION_0_STATE_H - LED_SECTION_0)
    sbrc    R_TMP_1, LED_SECTION_STATE_H_STOP_INCREMENT_BIT
    rjmp    _CSLPB_END
    ; inkrementacja
    ldd     R_TMP_1, R_POINTER_B + (LED_SECTION_0_COUNTER_L - LED_SECTION_0)
    ldd     R_TMP_2, R_POINTER_B + (LED_SECTION_0_COUNTER_H - LED_SECTION_0)
    ldd     R_TMP_3, R_POINTER_B + (LED_SECTION_0_DATA_SKIP - LED_SECTION_0)
    add     R_TMP_1, R_TMP_3
    adc     R_TMP_2, R_ZERO
    std     R_POINTER_B + (LED_SECTION_0_COUNTER_L - LED_SECTION_0), R_TMP_1
    std     R_POINTER_B + (LED_SECTION_0_COUNTER_H - LED_SECTION_0), R_TMP_2
    rjmp    _CSLPB_END

_CSLPB_DECREMENT:
    ldd     R_TMP_1,  R_POINTER_B + (LED_SECTION_0_COUNTER_L - LED_SECTION_0)
    ldd     R_TMP_2,  R_POINTER_B + (LED_SECTION_0_COUNTER_H - LED_SECTION_0)
    ; dekrementacja gdy licznik nie osiagnal 0
    cp      R_TMP_1, R_ZERO
    cpc     R_TMP_2, R_ZERO
    breq    _CSLPB_END
    ; Ustawienie flagi w³¹czaj¹cej zasilanie LED
    sbr     R_CONTROL, 1 << R_LED_POWER_BIT
    ; dekrementacja licznika
    ldd     R_TMP_3, R_POINTER_B + (LED_SECTION_0_DATA_SKIP - LED_SECTION_0)
    sub     R_TMP_1, R_TMP_3
    sbc     R_TMP_2, R_ZERO
    ; wyzerowanie przy przepelnieniu
    brcc    PC + 3
    clr     R_TMP_1
    clr     R_TMP_2
    std     R_POINTER_B + (LED_SECTION_0_COUNTER_L - LED_SECTION_0), R_TMP_1
    std     R_POINTER_B + (LED_SECTION_0_COUNTER_H - LED_SECTION_0), R_TMP_2
    rjmp    _CSLPB_END

_CSLPB_END:
    ret
;----------------------------------------------------------------------------
SEND_LED_DATA:
    rcall   CLEAR_LED_DATA_OUT
    rcall   CALCULATE_LED_DATA_0
    rcall   CALCULATE_LED_DATA_1
    rcall   CALCULATE_LED_DATA_2
    ;rcall   CALCULATE_LED_RGB
    
    sbi     SPSR, SPIF    
    
    ; Adres tablicy danych LED do wyslania
    LDI16   R_POINTER_A, LED_DATA_OUT
    lds     R_LOOP, LED_DATA_COUNT
    ld      R_TMP_1, R_POINTER_A+
    rjmp    _SLD_LOOP_ENTER
_SLD_LOOP:
    ld      R_TMP_1, R_POINTER_A+
    ; poczekanie na koniec transmisji
    sbis    SPSR, SPIF
    rjmp    PC - 1
_SLD_LOOP_ENTER:
    out     SPDR, R_TMP_1
    
    ; R
    ;rcall   SEND_LED_BYTE_POINTER_A
    ; G
    ;rcall   SEND_LED_BYTE_POINTER_A
    ; B
   ; rcall   SEND_LED_BYTE_POINTER_A

    dec     R_LOOP
    brne    _SLD_LOOP

;    cbi     LED_CLK_PORT, LED_CLK_BIT

    ret
;----------------------------------------------------------------------------
CLEAR_LED_DATA_OUT:
    ; adres tablicy danych LED do wyslania
    ldi     R_POINTER_A_H, high(LED_DATA_OUT)
    ldi     R_POINTER_A_L, low(LED_DATA_OUT)

    lds     R_LOOP, LED_DATA_COUNT
_CLDO_LOOP:
    st      R_POINTER_A+, R_ZERO
    ;st      R_POINTER_A+, R_ZERO
    ;st      R_POINTER_A+, R_ZERO

    dec     R_LOOP
    brne    _CLDO_LOOP

    ret
;----------------------------------------------------------------------------
CALCULATE_LED_DATA_0:
    ; adres tablicy definicji rozjasnienia w funkcji czasu
    ldi     R_POINTER_B_H, high(LED_SECTION_0)
    ldi     R_POINTER_B_L, low(LED_SECTION_0)
    rjmp    CALCULATE_LED_DATA_POINTER_B
;----------------------------------------------------------------------------
CALCULATE_LED_DATA_1:
    ; adres tablicy definicji rozjasnienia w funkcji czasu
    ldi     R_POINTER_B_H, high(LED_SECTION_1)
    ldi     R_POINTER_B_L, low(LED_SECTION_1)
    rjmp    CALCULATE_LED_DATA_POINTER_B
;----------------------------------------------------------------------------
CALCULATE_LED_DATA_2:
    ; adres tablicy definicji rozjasnienia w funkcji czasu
    ldi     R_POINTER_B_H, high(LED_SECTION_2)
    ldi     R_POINTER_B_L, low(LED_SECTION_2)
    rjmp    CALCULATE_LED_DATA_POINTER_B
;----------------------------------------------------------------------------
CALCULATE_LED_DATA_POINTER_B:
    ; adres tablicy danych LED do wyslania
    ldi     R_POINTER_A_H, high(LED_DATA_OUT)
    ldi     R_POINTER_A_L, low(LED_DATA_OUT)

    ; w R_TMP_3, jest zapisana flaga konczaca inkrementacje licznika
    ; gdy wszystkie oczka z sekcji ju¿ siê œwiec¹.
    ; Flaga jest ustawiana na po czatku i kasowana gdy oczko nie 
    ; osiagnê³o pe³nej mocy
    ldi     R_TMP_3, 1 << LED_SECTION_STATE_H_STOP_INCREMENT_BIT

    ; pobranie licznika sekcji
    ldd     r1, R_POINTER_B + (LED_SECTION_0_COUNTER_H - LED_SECTION_0)
    ldd     r0, R_POINTER_B + (LED_SECTION_0_COUNTER_L - LED_SECTION_0)

    ; przesuniecie wskaznika na tablice danych LED
    adiw    R_POINTER_B_L, LED_SECTION_0_DATA - LED_SECTION_0
    
    ; petla sprawdzania LED
    lds     R_LOOP, LED_DATA_COUNT
_CLDP_LOOP:
    ; kalkulacja intensywnosci swiecenia
    ; wartosc porownania biezacego oczka
    ld      R_TMP_1, R_POINTER_B+
    ; sprawdzenie czy LEDa ma swiecic: <0;254> - swieci, 255 - nie swieci.
    cpi     R_TMP_1, 255
    breq    _CLDP_LOOP_EXCLUDE
    ; swieci
    ; pomno¿enie wartosci przez 8, wydluza to opoznienie w zaswieceniu
    clr     R_TMP_2
    lsl     R_TMP_1
    rol     R_TMP_2
    lsl     R_TMP_1
    rol     R_TMP_2
    lsl     R_TMP_1
    rol     R_TMP_2
    ; porownanie pomnozonej wartosci diody z licznikiem
    movw    r2, r0
    sub     r2, R_TMP_1
    sbc     r3, R_TMP_2
    brmi    _CLDP_LOOP_0
    tst     r3
    brne    _CLDP_LOOP_255
    mov     R_TMP_1, r2
    clr     R_TMP_3  ; Kasowanie flagi zatrzymania inkrementacji licznika
    rjmp    _CLDP_LOOP_STORE_VALUE
_CLDP_LOOP_0:
    clr     R_TMP_3  ; Kasowanie flagi zatrzymania inkrementacji licznika
_CLDP_LOOP_EXCLUDE:
    ldi     R_TMP_1, 0
    rjmp    _CLDP_LOOP_STORE_VALUE
_CLDP_LOOP_255:
    ldi     R_TMP_1, 0xFF

_CLDP_LOOP_STORE_VALUE:
    ; zapis wartosci tylko gdy wieksza od juz zapisanej
    ld      R_TMP_2, R_POINTER_A
    cp      R_TMP_2, R_TMP_1
    brsh    PC + 2
    st      R_POINTER_A, R_TMP_1
    adiw    R_POINTER_A, 1

    dec     R_LOOP
    brne    _CLDP_LOOP

    ; Zapis flagi zatrzymania inkremenytacji licznika
    ; cofniêcie RPOINTER_B do LED_SECTION_(N)_DATA
    lds     R_TMP_1, LED_DATA_COUNT
    sub     R_POINTER_B_L, R_TMP_1
    sbc     R_POINTER_B_H, R_ZERO
    sbiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0_STATE_H
    ; pobranie aktualnego stanu
    ld      R_TMP_1, R_POINTER_B
    cbr     R_TMP_1, 1 << LED_SECTION_STATE_H_STOP_INCREMENT_BIT
    or      R_TMP_1, R_TMP_3
    st      R_POINTER_B, R_TMP_1

    ret
;----------------------------------------------------------------------------
CLEAR_LED_SECTION_POINTER_A:
    std     R_POINTER_A + (LED_SECTION_0_STATE_L - LED_SECTION_0), R_ZERO
    std     R_POINTER_A + (LED_SECTION_0_STATE_H - LED_SECTION_0), R_ZERO
    std     R_POINTER_A + (LED_SECTION_0_DATA_SKIP - LED_SECTION_0), R_ZERO
    std     R_POINTER_A + (LED_SECTION_0_COUNTER - LED_SECTION_0), R_ZERO
    std     R_POINTER_A + (LED_SECTION_0_COUNTER_H - LED_SECTION_0), R_ZERO
    std     R_POINTER_A + (LED_SECTION_0_COUNTER_L - LED_SECTION_0), R_ZERO
    adiw    R_POINTER_A, (LED_SECTION_0_DATA - LED_SECTION_0) 
    ldi     R_TMP_1, 0xFF
    ldi     R_LOOP, LED_DATA_COUNT_MAX
_CLSPA_CLEAR_LED_DATA_LOOP:
    st      R_POINTER_A+, R_TMP_1
    dec     R_LOOP
    brne    _CLSPA_CLEAR_LED_DATA_LOOP
    ret
;----------------------------------------------------------------------------
/*
CALCULATE_LED_RGB:
    ; adres tablicy danych LED do wyslania
    ldi     R_POINTER_A_H, high(LED_DATA_OUT)
    ldi     R_POINTER_A_L, low(LED_DATA_OUT)

    ; mno¿niki RGB
    lds     R_MUL_A_0, LED_R
    lds     R_MUL_A_1, LED_G
    lds     R_MUL_A_2, LED_B

    lds     R_LOOP, LED_DATA_COUNT
_CLRGB_LOOP:

    ld      R_MUL_B_0, R_POINTER_A
    rcall   MUL_U8_U8_3_F
    lsl     r0
    adc     r1, R_ZERO
    lsl     r2
    adc     r3, R_ZERO
    lsl     r4
    adc     r5, R_ZERO

    st      R_POINTER_A+, r1
    st      R_POINTER_A+, r3
    st      R_POINTER_A+, r5

    dec     R_LOOP
    brne    _CLRGB_LOOP

    ret
*/
;----------------------------------------------------------------------------
/*
SEND_LED_BYTE_POINTER_A:
;----------------------------------------------------------------------------
SEND_WS2801_BYTE_POINTER_A:
    ldi     R_TMP_1, 8
    ld      R_TMP_2, R_POINTER_A+
_SLBP_LOOP:
    cbi     LED_CLK_PORT, LED_CLK_BIT

    sbrs    R_TMP_2, 7
    cbi     LED_DATA_PORT, LED_DATA_BIT
    sbrc    R_TMP_2, 7
    sbi     LED_DATA_PORT, LED_DATA_BIT
    
    lsl     R_TMP_2
    
    sbi     LED_CLK_PORT, LED_CLK_BIT
    
    dec     R_TMP_1
    brne    _SLBP_LOOP
    ret
*/
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
LOAD_BYTE_FROM_EE_POINTER_A:
    ; adres
    out     EEARH, R_POINTER_A_H
    out     EEARL, R_POINTER_A_L
    sbi     EECR, EERE
    in      R_DATA, EEDR
    ret
;----------------------------------------------------------------------------
.macro  LOAD_BYTE_FROM_EE
    ldi     R_POINTER_A_H, high(@0)
    ldi     R_POINTER_A_L, low(@0)
    rcall   LOAD_BYTE_FROM_EE_POINTER_A
.endmacro
;----------------------------------------------------------------------------
LOAD_FROM_EE:
    ; poczekanie na ewentualny poprzedni zapis
    sbic    EECR, EEWE
    rjmp    PC-1

    ; Adres I2C
    LOAD_BYTE_FROM_EE   E_I2C_MY_ADDRESS
    ; korekta gdy adres nie jest zapisany
    sbrc    R_DATA, 0
    ldi     R_DATA, I2C_MY_ADDRESS_DEFAULT
    out     TWAR, R_DATA
    
    ; ilosc oczek
    LOAD_BYTE_FROM_EE   E_LED_DATA_COUNT
    cpi     R_DATA, 4
    brlo    PC + 1
    ldi     R_DATA, 0
    sts     LED_DATA_COUNT, R_DATA

    ; definicje sekcji
    LDI16   R_POINTER_B, LED_SECTIONS
    LDI16   R_POINTER_A, E_LED_SECTIONS
    ldi     R_LOOP, LED_SECTIONS_SIZE
_LFE_SECTIONS_LOOP:
    rcall   LOAD_BYTE_FROM_EE_POINTER_A
    st      R_POINTER_B+, R_DATA
    adiw    R_POINTER_A, 1
    dec     R_LOOP
    brne    _LFE_SECTIONS_LOOP

    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
.macro  SAVE_BYTE_TO_EE
    ldi     R_POINTER_A_H, high(E_@0)
    ldi     R_POINTER_A_L, low(E_@0)
    lds     R_DATA, @0
    rcall   SAVE_BYTE_TO_EE_POINTER_A
.endmacro
;----------------------------------------------------------------------------
.macro  SAVE_REG_TO_EE
    ldi     R_POINTER_A_H, high(@0)
    ldi     R_POINTER_A_L, low(@0)
    mov     R_DATA, @1
    rcall   SAVE_BYTE_TO_EE_POINTER_A
.endmacro
;----------------------------------------------------------------------------
SAVE_TO_EE:   
    sbrs    R_TMP_3, I2C_REQUEST_SAVE_EE_I2C_ADDRESS_BIT
    rjmp    _STE_I2C_ADDRESS_SKIP
    in      R_TMP_1, TWAR
    SAVE_REG_TO_EE  E_I2C_MY_ADDRESS, R_TMP_1
    SAVE_REG_TO_EE  E_I2C_MY_ADDRESS_L, R_I2C_MY_ADDRESS_L
_STE_I2C_ADDRESS_SKIP:

/*
    sbrs    R_TMP_3, I2C_REQUEST_SAVE_EE_OSCCAL_VALUE_BIT
    rjmp    _STE_OSCCAL_VALUE_SKIP
    SAVE_BYTE_TO_EE OSCCAL_VALUE
_STE_OSCCAL_VALUE_SKIP:
*/
    sbrs    R_TMP_3, I2C_REQUEST_SAVE_EE_POINT_COUNT_BIT
    rjmp    _STE_POINT_COUNT_SKIP
    SAVE_BYTE_TO_EE LED_DATA_COUNT
_STE_POINT_COUNT_SKIP:

    sbrs    R_TMP_3, I2C_REQUEST_SAVE_EE_SECTIONS_BIT
    rjmp    _STE_SECTIONS_SKIP
    LDI16   R_POINTER_B, LED_SECTIONS
    LDI16   R_POINTER_A, E_LED_SECTIONS
    ldi     R_LOOP, LED_SECTIONS_SIZE
_STE_SECTIONS_LOOP:
    ld      R_DATA, R_POINTER_B+
    rcall   SAVE_BYTE_TO_EE_POINTER_A
    adiw    R_POINTER_A, 1
    dec     R_LOOP
    brne    _STE_SECTIONS_LOOP

_STE_SECTIONS_SKIP:
    
    ret
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
SAVE_BYTE_TO_EE_POINTER_A:
    ; poczekanie na poprzedni zapis
    sbic    EECR, EEWE
    rjmp    PC-1

    ; adres
    out     EEARH, R_POINTER_A_H
    out     EEARL, R_POINTER_A_L

    ; pobranie istniejacej wartosci
    sbi     EECR, EERE
    in      R_TMP_1, EEDR
    cp      R_DATA, R_TMP_1
    breq    _STEF_END

    ; zapis
    out     EEDR, R_DATA
    cli
    sbi     EECR, EEMWE
    sbi     EECR, EEWE
    sei

_STEF_END:
    ret

; Mno¿y równolegle 3 liczby 8-bitowe R_MUL_A_0, R_MUL_A_1, R_MUL_A_2 przez
; R_MUL_B_0, wyniki s¹ zapisywane odpowiadio w rejestrach r0-r1, r2-r3, r4-r5
/*
MUL_U8_U8_3_F:
    push    R_LOOP

    clr     r0
    clr     r1
    movw    r2, r0
    movw    r4, r0

    ldi     R_LOOP, 8
    rjmp    _MUL_U8_3_U8_START_LOOP
_MUL_U8_3_U8_LOOP:
    lsl     r0
    rol     r1
    lsl     r2
    rol     r3
    lsl     r4
    rol     r5
_MUL_U8_3_U8_START_LOOP:

    lsl     R_MUL_A_0
    brcc    _MUL_U8_3_U8_END_0
_MUL_U8_3_U8_ADD_0:
    inc     R_MUL_A_0
    add     r0, R_MUL_B_0
    adc     r1, R_ZERO
_MUL_U8_3_U8_END_0:

    lsl     R_MUL_A_1
    brcc    _MUL_U8_3_U8_END_1
_MUL_U8_3_U8_ADD_1:
    inc     R_MUL_A_1
    add     r2, R_MUL_B_0
    adc     r3, R_ZERO
_MUL_U8_3_U8_END_1:

    lsl     R_MUL_A_2
    brcc    _MUL_U8_3_U8_END_2
_MUL_U8_3_U8_ADD_2:
    inc     R_MUL_A_2
    add     r4, R_MUL_B_0
    adc     r5, R_ZERO
_MUL_U8_3_U8_END_2:

    dec     R_LOOP
    brne    _MUL_U8_3_U8_LOOP

    pop     R_LOOP

    ret
*/
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;       Obsluga I2C
.macro  I2C_BYTE_RECEIVED
    sbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
.endmacro
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;.include    "I2CTinySlaveMacro1.inc"
;.include    "I2CTinySlave.asm"

;----------------------------------------------------------------------------
TWI_M_SLAVE_INIT:
    ldi     R_TMP_1, 1 << TWIE | 1 << TWEN | 1 << TWINT | 0 << TWEA
    mov     R_I2C_TWCR_EA0, R_TMP_1 
    ldi     R_TMP_1, 1 << TWIE | 1 << TWEN | 1 << TWINT | 1 << TWEA
    mov     R_I2C_TWCR_EA1, R_TMP_1 

    ldi     R_TMP_1, 0
    out     TWDR, R_TMP_1
    out     TWBR, R_TMP_1
    ldi     R_TMP_1, 1 << TWIE | 1 << TWEN | 1 << TWEA
    out     TWCR, R_TMP_1
    ret
;----------------------------------------------------------------------------
TWI_ITERRUPT:
    in      R_SREG_INTERRUPT_STORE, SREG

    in      R_I2C_TMP, TWSR
    cpi     R_I2C_TMP, 0x60
    breq    _TI_ADDRESS_ACK_RECEIVED_W
    
    ;cpi     R_I2C_TMP, 0x80
    ;breq    _TI_RECEIVED_W
    
    cpi     R_I2C_TMP, 0xA0
    brlo    _TI_RECEIVED_W ; 0x80
    breq    _TI_STOP_RSTART
    
    ;cpi     R_I2C_TMP, 0xA8
    ;breq    _TI_GET_DATA_0

    cpi     R_I2C_TMP, 0xB8
    brlo    _TI_GET_DATA_0 ; 0xA8
    breq    _TI_GET_DATA

    cpi     R_I2C_TMP, 0xC0
    breq    _TI_GET_DATA

    out     TWCR, R_I2C_TWCR_EA1
    rjmp    _TI_TWCR

_TI_ADDRESS_ACK_RECEIVED_W:
    ; u stawienie wskaznika zapisu na poczatek
    ldi     R_I2C_BUF_POINTER_H, high(I2C_RECV_DATA_REQUEST)
    ldi     R_I2C_BUF_POINTER_L, low(I2C_RECV_DATA_REQUEST)
    out     TWCR, R_I2C_TWCR_EA1
    rjmp    _TI_TWCR    

_TI_RECEIVED_W:
    ; sprawdzenie czy koniec danych
    cpi     R_I2C_BUF_POINTER_L, low(I2C_RECV_DATA_END)
.if (I2C_RECV_DATA_END) > 0xFF
    ldi     R_I2C_TMP, high(I2C_RECV_DATA_END)
    cpc     R_I2C_BUF_POINTER_H, R_I2C_TMP
.endif
    brlo    _TI_RECEIVED_W_STORE
    out     TWCR, R_I2C_TWCR_EA0
    rjmp    _TI_TWCR
_TI_RECEIVED_W_STORE:
    ; zapis do komorki pamieci tego co przyszlo
    in      R_I2C_TMP, TWDR
    st      R_I2C_BUF_POINTER+, R_I2C_TMP
    out     TWCR, R_I2C_TWCR_EA1
    sbr     R_CONTROL, 1 << R_CONTROL_I2C_READ_BYTE_BIT
    rjmp    _TI_TWCR

_TI_STOP_RSTART:
    out     TWCR, R_I2C_TWCR_EA1
    rjmp    _TI_TWCR

_TI_GET_DATA_0:
    ; ustawienie adresu na poczatek bufora odczytu lub
    ; zadany adres w poprzednim zapisie
.if I2C_SEND_DATA_SIZE <= 0xFF
    ; 8bit
    ; sprawdzenie czy poprzednio przyszedl 1 bajt
    cpi     R_I2C_BUF_POINTER_L, low(I2C_RECV_DATA + 1)
    .if (I2C_RECV_DATA_END) > 0xFF
        ldi     R_I2C_TMP, high(I2C_RECV_DATA + 1)
        cpc     R_I2C_BUF_POINTER_H, R_I2C_TMP
    .endif
    ldi     R_I2C_BUF_POINTER_H, high(I2C_SEND_DATA)
    ldi     R_I2C_BUF_POINTER_L, low(I2C_SEND_DATA)
    brne    _TI_GET_DATA
    ; sprawdzenie czy bajt adresu nie nie ma za wielkiej wartosci
    lds     R_I2C_TMP, I2C_RECV_DATA
    cpi     R_I2C_TMP, I2C_SEND_DATA_SIZE
    brsh    _TI_GET_DATA
    ; zwiekszenie
    add     R_I2C_BUF_POINTER_L, R_I2C_TMP
    adc     R_I2C_BUF_POINTER_L, R_ZERO
.else
    ; 16bit
.endif

_TI_GET_DATA:
    ; sprawdzenie czy koniec danych
    cpi     R_I2C_BUF_POINTER_L, low(I2C_SEND_DATA_END)
.if (I2C_SEND_DATA_END) > 0xFF
    ldi     R_I2C_TMP, high(I2C_SEND_DATA_END)
    cpc     R_I2C_BUF_POINTER_H, R_I2C_TMP
.endif
    brlo    _TI_W_STORE
    out     TWDR, R_FF
    out     TWCR, R_I2C_TWCR_EA1
    rjmp    _TI_TWCR    
_TI_W_STORE:
    ld      R_I2C_TMP, R_I2C_BUF_POINTER+
    out     TWDR, R_I2C_TMP
    out     TWCR, R_I2C_TWCR_EA1
    rjmp    _TI_TWCR    

_TI_TWCR:
    out     SREG, R_SREG_INTERRUPT_STORE
        
    reti
;----------------------------------------------------------------------------
