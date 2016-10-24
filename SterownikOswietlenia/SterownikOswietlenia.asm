/*
 * SterownikOswietlenia.asm
 *
 *  Created: 2015-05-26 13:41:07
 *   Author: rafal
 */ 


.include    "SterownikOswietlenia.inc"

.include    "SterownikOswietlenia.DSEG.asm"
.include    "SterownikOswietlenia.ESEG.asm"


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

.macro  STI
    ldi     R_TMP_1, @1
    st      @0, R_TMP_1
.endmacro

.macro  LDI16
    ldi     @0H, high(@1)
    ldi     @0L, low(@1)
.endmacro

.macro  CPI16
    ldi     R_TMP_1, high(@1)
    cpi     @0L, low(@1)
    cpc     @0H, R_TMP_1
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
    out     DDRD, R_FF
    ;sbi     LED_CLK_DDR, LED_CLK_BIT
    sbi     LED_DATA_DDR, LED_DATA_BIT
    ;cbi     LED_CLK_PORT, LED_CLK_BIT
    cbi     LED_DATA_PORT, LED_DATA_BIT
    ;sbi     LED_SPI_MOSI_DDR, LED_SPI_MOSI_BIT
    ;sbi     LED_SPI_SCK_DDR, LED_SPI_SCK_BIT
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
  ;  LDI16   R_POINTER_A, LED_SECTION_0
  ;  rcall   CLEARLED_SECTION_POINTER_A
  ;  LDI16   R_POINTER_A, LED_SECTION_1
  ;  rcall   CLEARLED_SECTION_POINTER_A
  ;  LDI16   R_POINTER_A, LED_SECTION_2
  ;  rcall   CLEARLED_SECTION_POINTER_A
    
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
    

    ; inicjowanie I2C
    rcall   TWI_M_SLAVE_INIT

    ; wczytanie konfiguracji
    rcall   LOAD_FROM_EE

    ; Testowe dane
    rcall   SET_TEST_DATA
    rcall   SEND_LED_DATA
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
    mov     R_LOOP, R_I2C_BUF_POINTER_L
    mov     R_TMP_2, R_I2C_BUF_POINTER_H
    ldi     R_TMP_3, high(I2C_RECV_DATA_ARGS)
    subi    R_LOOP, low(I2C_RECV_DATA_ARGS)
    sbc     R_TMP_2, R_TMP_3
    cpi     R_LOOP, 1
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
    
    cpi     R_DATA, I2C_REQUEST_ADD_SECTION
    brne    PC + 2
    rjmp    _I2C_CR_ADD_SECTION

    rjmp    _I2C_CR_END

_I2C_CR_1_ARG:
    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS, 7 lub 10 bit
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    breq    _I2C_CR_SET_SLAVE_ADDRES_H

    rjmp    _I2C_CR_END

_I2C_CR_N_ARGS:
    ; rozmiar grupy
    cpi     R_DATA, I2C_REQUEST_SET_GROUP_SIZE
    breq    _I2C_CR_I2C_REQUEST_SET_GROUP_SIZE

    ; nowy adres I2C - I2C_REQUEST_SLAVE_ADDRESS, 10 bit
    cpi     R_DATA, I2C_REQUEST_SLAVE_ADDRESS
    brne    PC + 2
    rjmp    _I2C_CR_SET_SLAVE_ADDRES_L

    cpi     R_DATA, I2C_REQUEST_SET_SECTION_CONTROL
    brne    PC + 2
    rjmp    _I2C_CR_SET_SECTION_CONTROL

    cpi     R_DATA, I2C_REQUEST_SET_SECTION_DATA
    brne    PC + 2    
    rjmp    _I2C_CR_SET_SECTION_DATA

    cpi     R_DATA, I2C_REQUEST_DELETE_SECTION
    brne    PC + 2    
    rjmp    _I2C_CR_DELETE_SECTION
    
    cpi     R_DATA, I2C_REQUEST_CLEAR_SECTIONS
    brne    PC + 2    
    rjmp    _I2C_CR_CLEAR_SECTIONS


    rjmp    _I2C_CR_END


_I2C_CR_REQUEST_SAVE_EE:
    mov     R_TMP_3, R_DATA
    andi    R_TMP_3, ~I2C_REQUEST_SAVE_EE_MASK
    rcall   SAVE_TO_EE
    brcc    _I2C_CR_REQUEST_SAVE_EE_CORRECT
    ; jakiœ b³¹d
    rjmp    _I2C_CR_ERROR
_I2C_CR_REQUEST_SAVE_EE_CORRECT:
    rjmp    _I2C_CR_END

_I2C_CR_REQUEST_RESET:
    ; Rozkaz RESET
    cli
    rjmp    RESET_SOFT


_I2C_CR_I2C_REQUEST_SET_GROUP_SIZE:
    ; sprawdzenie iloœci argumentów - musz¹ byæ 2
    cpi     R_LOOP, 2
    breq    PC + 2
    rjmp    _I2C_CR_END
    ; 2 argumenty: 0 - numer grupy, 1 rozmiar grupy
    lds     R_DATA, I2C_RECV_DATA_ARGS + 0 ; Numer grupy
    ; kontrola numeru grupy
    cpi     R_DATA, 8
    brlo    _I2C_CR_I2C_REQUEST_SET_GROUP_SIZE_GROUP_CORRECT
    ; b³êdna grupa
    ldi     R_DATA, 0x1 << 1 ; b³êdny umer grupy
    rjmp    _I2C_CR_ERROR
_I2C_CR_I2C_REQUEST_SET_GROUP_SIZE_GROUP_CORRECT:
    ; poprawny numer grupy, Ustawienie adresu w tablicy LED_GROUP_LEN_TAB
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB ; adres idetacji po ca³ej tablicy
    movw    R_POINTER_A, R_POINTER_B ; adres wskazanej grupy
    add     R_POINTER_A_L, R_DATA
    adc     R_POINTER_A_H, R_ZERO
    ; zachowanie aktualnego rozmiaru grupy w R_TMP_2
    ld      R_TMP_2, R_POINTER_A
    ; rozmiar grupy
    lds     R_DATA, I2C_RECV_DATA_ARGS + 1
    ; wstawienie nowego rozmiaru grupy
    st      R_POINTER_A, R_DATA
    ; sprawdzenie wielkosci wszystkich grup
    ldi     R_TMP_1, LED_DATA_COUNT_MAX
    ldi     R_LOOP, 8
_I2C_CR_I2C_REQUEST_SET_GROUP_SIZE_CHECK_SIZE_LOOP:
    ld      R_DATA, R_POINTER_B+
    sub     R_TMP_1, R_DATA
    ; sprawdzenie czy odejmowanie spowodowa³o przepe³ienie
    ; wtedy suma iloœci LED w grupach jest za du¿a
    brcc    _I2C_CR_I2C_REQUEST_SET_GROUP_SIZE_SIZE_CORRECT
    ; rozmiar jest za du¿y - b³¹d
    ; przywrócenie poprzedniej wartoœci
    st      R_POINTER_A, R_TMP_2
    ; b³êdny rozmiar sumaryczny grupy
    ldi     R_DATA, 0x2 << 1 ; b³êdna suma grup
    rjmp    _I2C_CR_ERROR
_I2C_CR_I2C_REQUEST_SET_GROUP_SIZE_SIZE_CORRECT:
    dec     R_LOOP
    brne    _I2C_CR_I2C_REQUEST_SET_GROUP_SIZE_CHECK_SIZE_LOOP
    ; poprzwne zakoczenie
    rjmp    _I2C_CR_END


_I2C_CR_SET_SLAVE_ADDRES_H:
    lds     R_TMP_1, I2C_RECV_DATA_ARGS + 0
    cpi     R_TMP_1, 0b1111000
    brsh    _I2C_CR_SET_SLAVE_ADDRES_H_END ; koniec gdy adres jest za wysoki - zarezerwowany
    cpi     R_TMP_1, 0b1000
    brlo    _I2C_CR_SET_SLAVE_ADDRES_H_END ; koniec gdy adres jest za niski - zarezerwowany
    ; adres jest poprawny jak na 7 bitowy
    lsl     R_TMP_1
    out     TWAR, R_TMP_1
_I2C_CR_SET_SLAVE_ADDRES_H_END:
    rjmp    _I2C_CR_END

_I2C_CR_SET_SLAVE_ADDRES_L:
    lds     R_TMP_1, I2C_RECV_DATA_ARGS + 0
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 1
    cpi     R_TMP_1, high(1024)
    brsh    _I2C_CR_SET_SLAVE_ADDRES_L_END ; koniec gdy niepoprawny adres
    ; sformatowanie adresu do bezposredniego porównania
    lsl     R_TMP_1
    sbr     R_TMP_1, 0b11110000
    out     TWAR, R_TMP_1
    mov     R_I2C_MY_ADDRESS_L, R_TMP_2
_I2C_CR_SET_SLAVE_ADDRES_L_END:
    rjmp    _I2C_CR_END


_I2C_CR_ADD_SECTION:
    ; sprawdzenie czy jest miejsce do wstawienia
    lds     R_DATA, LED_SECTION_COUNT
    cpi     R_DATA, LED_SECTION_COUNT_MAX
    brlo    _I2C_CR_ADD_SECTION_ADD
    ; bl³d - nie ma miejsca do wstawienia sekcji
    ldi     R_DATA, 0x5 << 1 ; przekroczenie maksymalnej ilosci sekcji
    rjmp    _I2C_CR_ERROR
_I2C_CR_ADD_SECTION_ADD:
    ; zwiêkszenie iloœci sekcji
    inc     R_DATA
    sts     LED_SECTION_COUNT, R_DATA
    ; pobranie wskaŸnika sekcji
    dec     R_DATA
    rcall   GET_SECTION_POINTER_A
    brcs    _I2C_CR_ADD_SECTION_ERROR
    ; zainicjowanie sekcji pustymi danymi
    std     R_POINTER_A + LED_SECTION_0_GROUP - LED_SECTION_0, R_FF
    std     R_POINTER_A + LED_SECTION_0_STATE_3 - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_STATE_2 - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_STATE_1 - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_STATE_0 - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_DATA_SKIP - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_COUNTER_H - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_COUNTER_L - LED_SECTION_0, R_ZERO
    std     R_POINTER_A + LED_SECTION_0_RESERVED_3 - LED_SECTION_0, R_FF
    std     R_POINTER_A + LED_SECTION_0_RESERVED_2 - LED_SECTION_0, R_FF
    std     R_POINTER_A + LED_SECTION_0_RESERVED_1 - LED_SECTION_0, R_FF
    std     R_POINTER_A + LED_SECTION_0_RESERVED_0 - LED_SECTION_0, R_FF
    ; koniec
    rjmp    _I2C_CR_END
_I2C_CR_ADD_SECTION_ERROR:
    ; przywrocenie poprzednij iloœci sekcji
    lds     R_DATA, LED_SECTION_COUNT
    dec     R_DATA
    sts     LED_SECTION_COUNT, R_DATA
    ; sygnalizacja b³êdu
    ldi     R_DATA, 0x9 << 1 ; Nie ma miejsca w buorze
    rjmp    _I2C_CR_ERROR
        
_I2C_CR_SET_SECTION_CONTROL:
    ; Indeks sekcji
    lds     R_DATA, I2C_RECV_DATA_ARGS + 0
    rcall   GET_SECTION_POINTER_A
    brcc    _I2C_CR_SET_SECTION_CONTROL_SECTION_CORRECT
    ; b³êdny indeks sekcji
    ldi     R_DATA, 0x3 << 1 ; b³êdny indeks sekcji
    rjmp    _I2C_CR_ERROR
_I2C_CR_SET_SECTION_CONTROL_SECTION_CORRECT:
    ; zapis 1 bajtu grupy
    cpi     R_LOOP, 2
    brsh    PC + 2
    rjmp    _I2C_CR_END
    ; 
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 1
    ; sprawdzenie czy indeks grupy jest poprawy
    cpi     R_TMP_2, 8
    brlo    _I2C_CR_SET_SECTION_CONTROL_GROUP_CORRECT
    ; b³¹d, niepoprawny indeks grupy
    ldi     R_DATA, 0x7 << 1 ; b³êdny indeks sekcji
    rjmp    _I2C_CR_ERROR
_I2C_CR_SET_SECTION_CONTROL_GROUP_CORRECT:
    std     R_POINTER_A + LED_SECTION_0_GROUP - LED_SECTION_0, R_TMP_2
    ; zapis 3 bajtów konfiguracji
    cpi     R_LOOP, 6
    brsh    PC + 2
    rjmp    _I2C_CR_END
    ;
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 2
    std     R_POINTER_A + LED_SECTION_0_STATE_3 - LED_SECTION_0, R_TMP_2
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 3
    std     R_POINTER_A + LED_SECTION_0_STATE_2 - LED_SECTION_0, R_TMP_2
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 4
    std     R_POINTER_A + LED_SECTION_0_STATE_1 - LED_SECTION_0, R_TMP_2
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 5
    std     R_POINTER_A + LED_SECTION_0_STATE_0 - LED_SECTION_0, R_TMP_2
    ; zapis 1 bajtu skoku licznika
    cpi     R_LOOP, 7
    brsh    PC + 2
    rjmp    _I2C_CR_END
    lds     R_TMP_2, I2C_RECV_DATA_ARGS + 6
    std     R_POINTER_A + LED_SECTION_0_DATA_SKIP - LED_SECTION_0, R_TMP_2    
    ; poprzwne zakoczenie
    rjmp    _I2C_CR_END


_I2C_CR_SET_SECTION_DATA:
    ; Indeks grupy -> Wskaznik na grupê
    lds     R_DATA, I2C_RECV_DATA_ARGS + 0
    rcall   GET_SECTION_POINTER_A
    ; sprawdzenie czy iloœæ odebranych danych jest równa
    ; ilosci led przypisanych do grupy
    ; pobranie lisci led w grupie
    ldd     R_DATA, R_POINTER_A + LED_SECTION_0_GROUP - LED_SECTION_0
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    add     R_POINTER_B_L, R_DATA
    adc     R_POINTER_B_H, R_ZERO
    ; ilosc LED w grupie
    ld      R_TMP_1, R_POINTER_B
    ; sprawdzenie czy ilosc LED w grupie odpowiada ilosci odebranych bajtów
    dec     R_LOOP  ; ilosc odebranych danych powinna byæ o jeden bajt wiêksza
                    ; przez bajt indeksu sekcji.
    cp      R_LOOP, R_TMP_1
    brne    _I2C_CR_END
    ; przesuniecie wskaznika na obszar danych LED
    adiw    R_POINTER_A, LED_SECTION_0_DATA - LED_SECTION_0
    ; ustawieie wskaznika B na obszarodebranych danych I2C
    LDI16   R_POINTER_B, (I2C_RECV_DATA_ARGS + 1)
_I2C_CR_SET_SECTION_DATA_LOOP:
    tst     R_LOOP
    breq    _I2C_CR_END
    dec     R_LOOP
    ld      R_TMP_1, R_POINTER_B+
    st      R_POINTER_A+, R_TMP_1
    rjmp    _I2C_CR_SET_SECTION_DATA_LOOP

_I2C_CR_DELETE_SECTION:
    ; Indeks sekcji
    lds     R_DATA, I2C_RECV_DATA_ARGS + 0
    rcall   GET_SECTION_POINTER_A
    brcc    _I2C_CR_SET_SECTION_CONTROL_SECTION_CORRECT
    ; b³êdny indeks sekcji
    ldi     R_DATA, 0x3 << 1 ; b³êdny indeks sekcji
    rjmp    _I2C_CR_ERROR
    ; poprawny indeks sekcji
        ; pobranie nsatêpnej sekcji do indeksu B
    ; grupa w sekcji
    ldd     R_TMP_1, R_POINTER_A + LED_SECTION_0_GROUP - LED_SECTION_0
    cpi     R_TMP_1, 8
    brsh    _I2C_CR_DELETE_SECTION_MOVE_LOOP_END
    ; poprawny indeks grupy
    ; pobranie ilosci ledow w sekcji
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    add     R_POINTER_B_L, R_TMP_1
    adc     R_POINTER_B_H, R_ZERO
    ld      R_TMP_1, R_POINTER_B
    ; przesuniêcie wskaŸnika na nastêp¹ sekcjê
    movw    R_POINTER_B, R_POINTER_A
    adiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0
    add     R_POINTER_B_L, R_TMP_1
    adc     R_POINTER_B_H, R_ZERO
    ; przesuniêcie kolejnych sekcji w miejsce usuniêtej
    ldi     R_TMP_2, high(LED_SECTIONS_END) ; starszy bajt adresu
                                            ; do porównania koñca obszaru
_I2C_CR_DELETE_SECTION_MOVE_LOOP:
    ; sprzewdzenie koñca wskaŸnika B
    cpi     R_POINTER_B_L, low(LED_SECTIONS_END)
    cpc     R_POINTER_B_H, R_TMP_2
    brsh    _I2C_CR_DELETE_SECTION_MOVE_LOOP_END
    ; skopiowanie
    ld      R_TMP_1, R_POINTER_B +
    st      R_POINTER_A +, R_TMP_1
    rjmp    _I2C_CR_DELETE_SECTION_MOVE_LOOP
_I2C_CR_DELETE_SECTION_MOVE_LOOP_END:
    ; kasowanie obszaru na koñcu
_I2C_CR_DELETE_SECTION_CLEAR_LOOP:
    ; sprzewdzenie koñca wskaŸnika A
    cpi     R_POINTER_A_L, low(LED_SECTIONS_END)
    cpc     R_POINTER_A_H, R_TMP_2
    brsh    _I2C_CR_DELETE_SECTION_CLEAR_LOOP_END
    ; kasowanie
    st      R_POINTER_A +, R_FF
    rjmp    _I2C_CR_DELETE_SECTION_CLEAR_LOOP
_I2C_CR_DELETE_SECTION_CLEAR_LOOP_END:
    ; zmniejszenie iloœci sekcji
    lds     R_TMP_1, LED_SECTION_COUNT
    dec     R_TMP_1
    sts     LED_SECTION_COUNT, R_TMP_1
    ; koniec _I2C_CR_DELETE_SECTION
    rjmp    _I2C_CR_END
    
    
_I2C_CR_CLEAR_SECTIONS:
    LDI16   R_POINTER_A, LED_SECTION_0
    ldi     R_TMP_2, high(LED_SECTIONS_END) ; starszy bajt adresu
                                            ; do porównania koñca obszaru
_I2C_CR_CLEAR_SECTIONS_LOOP:
    ; sprzewdzenie koñca wskaŸnika A
    cpi     R_POINTER_A_L, low(LED_SECTIONS_END)
    cpc     R_POINTER_A_H, R_TMP_2
    brsh    _I2C_CR_CLEAR_SECTIONS_LOOP_END
    ; kasowanie
    st      R_POINTER_A +, R_FF
    rjmp    _I2C_CR_CLEAR_SECTIONS_LOOP
_I2C_CR_CLEAR_SECTIONS_LOOP_END:
    ; wyzerowanie iloœci sekcji
    sts     LED_SECTION_COUNT, R_ZERO
    ; koniec _I2C_CR_CLEAR_SECTIONS
    rjmp    _I2C_CR_END

_I2C_CR_END:
    ldi     R_DATA, 0
_I2C_CR_ERROR:
    sts     I2C_REQUEST_RESULT, R_DATA
    
    ret
;----------------------------------------------------------------------------
; R_DATA - indeks sekcji
; Ustawiona flaga TFLAGS-C oznacza b³¹d
GET_SECTION_POINTER_A:
    LDI16   R_POINTER_A, LED_SECTION_0
    ; sprawdzenie czy indeks jest wiêkszy od zapisanych iloœci sekcji
    lds     R_TMP_1, LED_SECTION_COUNT
    cp      R_DATA, R_TMP_1
    brsh    _SNTPA_ERROR
    ; indeks sekcji jest poprawny
_SNTPA_LOOP:
    ; sprawdzenie czy adres nie wykracza poza przydzielony obszar
    ldi     R_TMP_1, high(LED_SECTIONS_END - LED_SECTION_HEADER_SIZE)
    cpi     R_POINTER_A_L, low(LED_SECTIONS_END - LED_SECTION_HEADER_SIZE)
    cpc     R_POINTER_A_H, R_TMP_1
    brsh    _SNTPA_ERROR
    ; poprawny adres
    ; warunek
    tst     R_DATA
    breq    _SNTPA_LOOP_END
    ; Przejscie na nastêpn¹ sekcjê
    ; grupa w sekcji
    ldd     R_TMP_1, R_POINTER_A + LED_SECTION_0_GROUP - LED_SECTION_0
    cpi     R_TMP_1, 8
    brsh    _SNTPA_ERROR
    ; poprawny indeks grupy
    ; pobranie ilosci ledow w sekcji
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    add     R_POINTER_B_L, R_TMP_1
    adc     R_POINTER_B_H, R_ZERO
    ld      R_TMP_1, R_POINTER_B
    ; przesuniêcie wskaŸnika na nastêp¹ sekcjê
    adiw    R_POINTER_A, LED_SECTION_0_DATA - LED_SECTION_0
    add     R_POINTER_A_L, R_TMP_1
    adc     R_POINTER_A_H, R_ZERO
    ; koniec pêtli
    dec     R_DATA
    rjmp    _SNTPA_LOOP
_SNTPA_LOOP_END:

    clc
    ret
_SNTPA_ERROR:
    sec
    ret
;----------------------------------------------------------------------------
; Ustawia wska¿nik A na grupupê LED okreœlon¹ przez R_DATA, dodatkowo
; dodatkowow w R_DATA zapisuje iloœæ LED w grupie
; R_DATA - indeks grupy
; Ustawiona flaga TFLAGS-C oznacza b³¹d
GET_GROUP_POINTER_A:
    cpi     R_DATA, 8
    brsh    _GNTPA_ERROR

    clr     R_TMP_2 ; przesuniecie wskaznika danych LED
    LDI16   R_POINTER_A, LED_GROUP_LEN_TAB
_GNTPA_LOOP:
    ; pobranie ilosci LED w grupie
    ld      R_TMP_1, R_POINTER_A +
    ; warunek na koniec pêtli
    tst     R_DATA
    breq    _GNTPA_LOOP_END
    ; przesuniêce wskaŸnika danych LED na kolejn¹ sekcjê
    add     R_TMP_2, R_TMP_1
    ; warunek przy przepe³nieniu - b³¹d
    brcs    _GNTPA_ERROR
    ; Koniec pêtli
    dec     R_DATA
    rjmp    _GNTPA_LOOP
_GNTPA_LOOP_END:

    ; ustawienie wskaŸnika A na w³aœciwym miejscu
    LDI16   R_POINTER_A, LED_DATA_OUT
    add     R_POINTER_A_L, R_TMP_2
    adc     R_POINTER_A_H, R_ZERO
    
    ; ilosc LED w grupie
    mov     R_DATA, R_TMP_1
    ; wyjœcie z brakiem b³êdu
    clc
    ret

_GNTPA_ERROR:
    ; wyjœcie z b³êdem
    sec
    ret
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
    rcall   CHECK_SECTIONS
    
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
CHECK_SECTIONS:
    LDI16   R_POINTER_B, LED_SECTION_0
    lds     R_LOOP, LED_SECTION_COUNT
_CS_LOOP:
    ; pobranie numeru sekcji
    ldd     R_TMP_1, R_POINTER_B + LED_SECTION_0_GROUP - LED_SECTION_0
    cpi     R_TMP_1, 8
    brsh    _CS_END
    ; sprawdzenie sekcji
    rcall   CHECK_SECTION_LED_POINTER_B
    ; pobranie ilosci ledów w grupie
    ldd     R_TMP_1, R_POINTER_B + LED_SECTION_0_GROUP - LED_SECTION_0
    LDI16   R_POINTER_A, LED_GROUP_LEN_TAB
    add     R_POINTER_A_L, R_TMP_1
    adc     R_POINTER_A_H, R_ZERO
    ld      R_TMP_1, R_POINTER_A
    ; przesuniêcie wskaŸnika B na kolejn¹ sekcjê
    adiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0 ; nag³ówek sekcji
    add     R_POINTER_B_L, R_TMP_1 ; iloœæ LED
    adc     R_POINTER_B_H, R_ZERO
    ; dodatkowy warunek pêtli
    dec     R_LOOP
    brne    _CS_LOOP

_CS_END:
    ret
;----------------------------------------------------------------------------
CHECK_SECTION_LED_POINTER_B:
    push    R_LOOP
    ; Sprawdzenie stanu przycisków przydzielonych do sekcji
    clr     R_DATA
    ; r3:r0: konfiguracja przycisków w sekcji
    ldd     r0, R_POINTER_B + (LED_SECTION_0_STATE_0 - LED_SECTION_0)
    ldd     r1, R_POINTER_B + (LED_SECTION_0_STATE_1 - LED_SECTION_0)
    ldd     r2, R_POINTER_B + (LED_SECTION_0_STATE_1 - LED_SECTION_0)
    ldd     r3, R_POINTER_B + (LED_SECTION_0_STATE_1 - LED_SECTION_0)
    ldi     R_TMP_1, 0x01 ; maska dla r3 zachowuj¹ca tylko bity przycisków
    and     r3, R_TMP_1
    ; R_POINTER_A: adres tablicy przycisków
    ldi     R_POINTER_A_H, high(BUTTON_STATE_COUNTER)
    ldi     R_POINTER_A_L, low(BUTTON_STATE_COUNTER)
    ldi     R_LOOP, BUTTON_COUNT_MAX
_CSLPB_CHECK_BUTTON_LOOP:
    ; sprawdzenie czy przycisk jest przydzielony
    lsr     r3
    ror     r2
    ror     r1
    ror     r0
    ; zakonczenie pêtli gdy nie ma wiêcej przydzielonych przycisków
    brne    PC + 2
    ldi     R_LOOP, 1
    ; sprawdzeie czy przycisk jest przydzielony
    brcc    _CSLPB_CHECK_BUTTON_LOOP_SKIP
    ; przycisk jest przydzielony, sprawdzenie jego stanu
    ld      R_TMP_1, R_POINTER_A
    eor     R_DATA, R_TMP_1
_CSLPB_CHECK_BUTTON_LOOP_SKIP:
    adiw    R_POINTER_A_L, 2
    dec     R_LOOP
    brne    _CSLPB_CHECK_BUTTON_LOOP
_CSLPB_CHECK_BUTTON_LOOP_END:

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
    ; bit 7 z LED_SECTION_(N)_STATE_3
    ldd     R_TMP_1, R_POINTER_B + (LED_SECTION_0_STATE_3 - LED_SECTION_0)
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
    pop     R_LOOP
    ret
;----------------------------------------------------------------------------
SEND_LED_DATA:
    rcall   CLEAR_LED_DATA_OUT
    rcall   CALCULATE_LED_SECTIONS

    ; Pêtla grup
    LDI16   R_POINTER_A, LED_GROUP_LEN_TAB ; wskaŸnik iloœci LED w grupie
    LDI16   R_POINTER_B, LED_DATA_OUT ; wskaŸnik danych LED
    ldi     R_TMP_1, 1 << 0 ; bit wyjscia zegarowego
_SLD_GROUP_TAB_LOOP:
    ; Petla dla led w grupie
    ld      R_LOOP, R_POINTER_A + ; iloœæ led w grupie
_SLD_GROUP_LOOP:
    ; warunek pêtli wysy³ania pojedyñczej grupy
    tst     R_LOOP
    breq    _SLD_GROUP_LOOP_END
    dec     R_LOOP
    ; licznik bitów wysy³anego bajtu
    ldi     R_TMP_2, 8
    ; wysy³any bajt
    ld      R_DATA, R_POINTER_B +
_SLD_BYTE_LOOP:
    ; zegar 0
    out     PORTD, R_ZERO
    ; dane
    sbrs    R_DATA, 7
    cbi     LED_DATA_PORT, LED_DATA_BIT
    sbrc    R_DATA, 7
    sbi     LED_DATA_PORT, LED_DATA_BIT
    ; zegar 1
    out     PORTD, R_TMP_1
    ; nastêpy bit
    lsl     R_DATA
    ; warunek pêtli wysy³ania bajtu
    dec     R_TMP_2
    brne    _SLD_BYTE_LOOP
    
    ; koniec pêtli wysy³ania grupy
    rjmp    _SLD_GROUP_LOOP
_SLD_GROUP_LOOP_END:
    
    ; warunek pêtli wysy³ania grup
    lsl     R_TMP_1
    brcc    _SLD_GROUP_TAB_LOOP

    ; Koniec zegar 0
    out     PORTD, R_ZERO

    ret
;----------------------------------------------------------------------------
CLEAR_LED_DATA_OUT:
    ; adres tablicy danych LED do wyslania
    LDI16   R_POINTER_A, LED_DATA_OUT
    ldi     R_LOOP, LED_DATA_COUNT_MAX
_CLDO_LOOP:
    st      R_POINTER_A+, R_ZERO
    dec     R_LOOP
    brne    _CLDO_LOOP
    ret
;----------------------------------------------------------------------------
CALCULATE_LED_SECTIONS:
    LDI16   R_POINTER_B, LED_SECTION_0

    ;lds     R_LOOP, LED_SECTION_COUNT
    ldi     R_LOOP, LED_DATA_COUNT_MAX
_CLS_LOOP:
    ; warunek pêtli
    tst     R_LOOP
    breq    _CLS_LOOP_END
    ; wyliczenie sekcji
    rcall   CALCULATE_LED_DATA_POINTER_B
    ; zakoñczenie w przypadku b³êdu
    brcs    _CLS_LOOP_END
    ; koiec pêtli
    dec     R_LOOP
    rjmp    _CLS_LOOP
_CLS_LOOP_END:

    ret
;----------------------------------------------------------------------------
CALCULATE_LED_DATA_POINTER_B:
    ; numer grupy
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_GROUP - LED_SECTION_0
    ; pobranie wskaznika grupy i ilosci LED w grupie
    rcall   GET_GROUP_POINTER_A
    brcs    _CLDP_ERROR ; Niepoprawny numer grupy
        
    ; w R_TMP_3, jest zapisana flaga konczaca inkrementacje licznika
    ; gdy wszystkie oczka z sekcji ju¿ siê œwiec¹.
    ; Flaga jest ustawiana na po czatku i kasowana gdy oczko nie 
    ; osiagnê³o pe³nej mocy
    ldi     R_TMP_3, 1 << LED_SECTION_STATE_H_STOP_INCREMENT_BIT

    ; pobranie licznika sekcji
    ldd     r3, R_POINTER_B + (LED_SECTION_0_COUNTER_H - LED_SECTION_0)
    ldd     r2, R_POINTER_B + (LED_SECTION_0_COUNTER_L - LED_SECTION_0)

    ; przesuniecie wskaznika na tablice danych LED
    adiw    R_POINTER_B_L, LED_SECTION_0_DATA - LED_SECTION_0
    
    ; Zachowaie na stosie ilosci LED w grupi, bêdzie potrzebna do 
    ; zachowania flagi koñca wyliczenia.
    push    R_DATA
    ; petla sprawdzania LED
_CLDP_LOOP:
    ; sprawdzenie czy wskaŸnik B mieœci siê w dozwolonym obszarze
    ldi     R_TMP_1, high(LED_SECTIONS_END)
    cpi     R_POINTER_B_L, low(LED_SECTIONS_END)
    cpc     R_POINTER_B_H, R_TMP_1
    brsh    _CLDP_ERROR_POP_R_DATA
    ; sprawdzenie czy wskaŸnik B mieœci siê w dozwolonym obszarze
    ldi     R_TMP_1, high(LED_DATA_OUT_END)
    cpi     R_POINTER_A_L, low(LED_DATA_OUT_END)
    cpc     R_POINTER_A_H, R_TMP_1
    brsh    _CLDP_ERROR_POP_R_DATA
    ; kalkulacja intensywnosci swiecenia
    ; wartosc porownania biezacego oczka
    ld      R_TMP_1, R_POINTER_B+
    ; sprawdzenie czy LEDa ma swiecic: <0;254> - swieci, 255 - nie swieci.
    cpi     R_TMP_1, 255
    breq    _CLDP_LOOP_EXCLUDE
    ; swieci
    ; pomno¿enie wartosci przez wspó³czynnik opoznienia zaswiecenia
    ldi     R_TMP_2, 8
    mul     R_TMP_1, R_TMP_2
    ; porownanie pomnozonej wartosci diody z licznikiem
    movw    R_TMP_1, r2
    sub     R_TMP_1, r0
    sbc     R_TMP_2, r1
    brmi    _CLDP_LOOP_0
    tst     R_TMP_2
    brne    _CLDP_LOOP_255
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
    ; koniec pêtli
    dec     R_DATA
    brne    _CLDP_LOOP

    ; Przywrócenie ze stosu iloœci LED w grupie
    pop     R_DATA

    ; Zapis flagi zatrzymania inkremenytacji licznika
    ; cofniêcie R_POINTER_B do LED_SECTION_(N)_DATA
    sub     R_POINTER_B_L, R_DATA
    sbc     R_POINTER_B_H, R_ZERO
    sbiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0_STATE_3
    ; pobranie aktualnego stanu
    ld      R_TMP_1, R_POINTER_B
    cbr     R_TMP_1, 1 << LED_SECTION_STATE_H_STOP_INCREMENT_BIT
    or      R_TMP_1, R_TMP_3
    st      R_POINTER_B, R_TMP_1
    ; powrót wskaŸnika na koniec danych LED sekcji
    adiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0_STATE_3
    add     R_POINTER_B_L, R_DATA
    adc     R_POINTER_B_H, R_ZERO
    
    ; wyjœcie bez b³êdu
    clc
    ret

    ; Wyjœcie z b³êdem
_CLDP_ERROR_POP_R_DATA:
    ; Przywrócenie ze stosu iloœci LED w grupie
    pop     R_DATA
_CLDP_ERROR:
    sec
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
.macro  LOAD_BYTE_FROM_EE_POINTER_A_OFFSET
    adiw    R_POINTER_A, (@0)
    rcall   LOAD_BYTE_FROM_EE_POINTER_A
    sbiw    R_POINTER_A, (@0)
.endmacro
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

    ; Iloœæ LED w grupach
    LDI16   R_POINTER_A, E_LED_GROUP_LEN_TAB
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    ldi     R_LOOP, 8
_LFE_LED_GROUP_LEN_TAB_LOOP:
    rcall   LOAD_BYTE_FROM_EE_POINTER_A
    adiw    R_POINTER_A, 1
    ; spradzenie poprawnoœci wpisu
    cpi     R_DATA, LED_DATA_COUNT_MAX + 1
    brlo    PC + 2
    ; korekta
    ldi     R_DATA, 0
    ; zapis do pamiêci
    st      R_POINTER_B +, R_DATA
    ; warunek pêtli
    dec     R_LOOP
    brne    _LFE_LED_GROUP_LEN_TAB_LOOP

    ; Iloœæ sekcji
    LOAD_BYTE_FROM_EE   E_LED_SECTION_COUNT
    ; korekta ilosci sekcji, gdy za du¿o to 0
    cpi     R_DATA, LED_SECTION_COUNT_MAX
    brlo    PC + 2
    ldi     R_DATA, 0
    sts     LED_SECTION_COUNT, R_DATA
    
    ; Sekcje
    ; wskaŸnik EEPROM
    LDI16   R_POINTER_A, E_LED_SECTION_0
    ; wskaŸnik RAM
    LDI16   R_POINTER_B, LED_SECTION_0
    ; pêtla wczytywania sekcji
    lds     R_COUNTER, LED_SECTION_COUNT
_LFE_SECTION_LOOP:
    ; warunek
    tst     R_COUNTER
    brne    PC + 2
    rjmp    _LFE_SECTION_LOOP_END
    dec     R_COUNTER
    ; domyœlne wartoœci nag³ówka nie przechowywane w EE
    std     R_POINTER_B + LED_SECTION_0_COUNTER_H - LED_SECTION_0, R_ZERO
    std     R_POINTER_B + LED_SECTION_0_COUNTER_L - LED_SECTION_0, R_ZERO
    std     R_POINTER_B + LED_SECTION_0_RESERVED_3 - LED_SECTION_0, R_FF
    std     R_POINTER_B + LED_SECTION_0_RESERVED_2 - LED_SECTION_0, R_FF
    std     R_POINTER_B + LED_SECTION_0_RESERVED_1 - LED_SECTION_0, R_FF
    std     R_POINTER_B + LED_SECTION_0_RESERVED_0 - LED_SECTION_0, R_FF
    ; odczyt nag³ówka
    LOAD_BYTE_FROM_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_3 - E_LED_SECTION_0
    std     R_POINTER_B + LED_SECTION_0_STATE_3 - LED_SECTION_0, R_DATA
    LOAD_BYTE_FROM_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_2 - E_LED_SECTION_0
    std     R_POINTER_B + LED_SECTION_0_STATE_2 - LED_SECTION_0, R_DATA
    LOAD_BYTE_FROM_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_1 - E_LED_SECTION_0
    std     R_POINTER_B + LED_SECTION_0_STATE_1 - LED_SECTION_0, R_DATA
    LOAD_BYTE_FROM_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_0 - E_LED_SECTION_0
    std     R_POINTER_B + LED_SECTION_0_STATE_0 - LED_SECTION_0, R_DATA
    LOAD_BYTE_FROM_EE_POINTER_A_OFFSET    E_LED_SECTION_0_DATA_SKIP - E_LED_SECTION_0
    std     R_POINTER_B + LED_SECTION_0_DATA_SKIP - LED_SECTION_0, R_DATA
    ; grupa na koñcu bo pos³u¿y do pobrania iloœci led
    LOAD_BYTE_FROM_EE_POINTER_A_OFFSET    E_LED_SECTION_0_GROUP - E_LED_SECTION_0
    std     R_POINTER_B + LED_SECTION_0_GROUP - LED_SECTION_0, R_DATA
    ; sprawdzenie czy numer grupy jest poprawny, je¿eli nie to koniec odczytu
    cpi     R_DATA, 8
    brlo    _LFE_SECTIONS_LOOP_GROUP_CORRENT
    ldi     R_DATA, 0x9 << 1 ; niew³aœciwa grupa
    rjmp    _LFE_DATA_ERROR
_LFE_SECTIONS_LOOP_GROUP_CORRENT:
    ; przesuniêcie wskaŸnika B na adres RAM danych sekcji
    adiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0
    ; zachowaie wskaŸnika B
    movw    R_TMP_1, R_POINTER_B
    ; pobranie iloœci LED w grupie
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    add     R_POINTER_B_L, R_DATA
    adc     R_POINTER_B_H, R_ZERO
    ; iloœæ danych w grupie
    ld      R_LOOP, R_POINTER_B
    ; przywrocenie wskaŸnika B
    movw    R_POINTER_B, R_TMP_1
    ; przesuniêcie wskaŸnika A a dares danych EE
    adiw    R_POINTER_A, E_LED_SECTION_0_DATA - E_LED_SECTION_0
    
_LFE_SECTION_DATA_LOOP:
    ; warunek pêtli danych
    tst     R_LOOP
    breq    _LFE_SECTION_DATA_LOOP_END
    dec     R_LOOP
    
    ; porownanie dla sprawdzenia czy koniec danych EE
    CPI16   R_POINTER_A, E_LED_SECTIONS_END
    brlo    _LFE_SECTIONS_LOOP_EE_ADDRESS_CORRENT
    ; przekroczony adres EE
    ldi     R_DATA, 0xB << 1 ; przekroczony adres
    rjmp    _LFE_DATA_ERROR
_LFE_SECTIONS_LOOP_EE_ADDRESS_CORRENT:

    ; porownanie dla sprawdzenia czy koniec danych RAM
    CPI16   R_POINTER_B, LED_SECTIONS_END
    brlo    _LFE_SECTIONS_LOOP_RAM_ADDRESS_CORRENT
    ; przekroczony adres EE
    ldi     R_DATA, 0xC << 1 ; przekroczony adres
    rjmp    _LFE_DATA_ERROR
_LFE_SECTIONS_LOOP_RAM_ADDRESS_CORRENT:

    ; przepisanie bajtu danych
    rcall   LOAD_BYTE_FROM_EE_POINTER_A
    adiw    R_POINTER_A, 1
    st      R_POINTER_B+, R_DATA
    
    ;koniec pêtli danych
    rjmp    _LFE_SECTION_DATA_LOOP
_LFE_SECTION_DATA_LOOP_END:

    ; koniec pêtli sekcji
    rjmp    _LFE_SECTION_LOOP

_LFE_SECTION_LOOP_END:

_LFE_DATA_ERROR:
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
.macro  SAVE_DATA_TO_EE_POINTER_A_OFFSET
    adiw    R_POINTER_A, @0
    rcall   SAVE_BYTE_TO_EE_POINTER_A
    sbiw    R_POINTER_A, @0
.endmacro
;----------------------------------------------------------------------------
SAVE_TO_EE:
    ; Zapis adresu I2C
    sbrs    R_TMP_3, I2C_REQUEST_SAVE_EE_I2C_ADDRESS_BIT
    rjmp    _STE_I2C_ADDRESS_SKIP
    ; zapis
    in      R_TMP_1, TWAR
    SAVE_REG_TO_EE  E_I2C_MY_ADDRESS, R_TMP_1
    SAVE_REG_TO_EE  E_I2C_MY_ADDRESS_L, R_I2C_MY_ADDRESS_L
_STE_I2C_ADDRESS_SKIP:

    ; zapis danych
    sbrs    R_TMP_3, I2C_REQUEST_SAVE_EE_DATA_BIT
    rjmp    _STE_DATA_SKIP
    ; zapis iloœci LED w grupach
    LDI16   R_POINTER_A, E_LED_GROUP_LEN_TAB
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    ldi     R_LOOP, 8
_STE_GROUP_COUNT_LOOP:
    ld      R_DATA, R_POINTER_B +
    rcall   SAVE_BYTE_TO_EE_POINTER_A
    adiw    R_POINTER_A, 1
    dec     R_LOOP
    brne    _STE_GROUP_COUNT_LOOP

    ; Zapis sekcji
    ; iloœæ sekcji
    lds     R_COUNTER, LED_SECTION_COUNT
    SAVE_REG_TO_EE  E_LED_SECTION_COUNT, R_COUNTER
    ; dane wszystkich sekcji
    LDI16   R_POINTER_B, LED_SECTION_0
    LDI16   R_POINTER_A, E_LED_SECTION_0
    ldi     R_LOOP, high(LED_SECTIONS_END)
_STE_SECTIONS_LOOP:
    ; warunek pêtli
    tst     R_COUNTER
    breq    _STE_DATA_CORRECT
    dec     R_COUNTER
    ; zapis nag³ówka
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_STATE_3 - LED_SECTION_0
    SAVE_DATA_TO_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_3 - E_LED_SECTION_0
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_STATE_2 - LED_SECTION_0
    SAVE_DATA_TO_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_2 - E_LED_SECTION_0
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_STATE_1 - LED_SECTION_0
    SAVE_DATA_TO_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_1 - E_LED_SECTION_0
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_STATE_0 - LED_SECTION_0
    SAVE_DATA_TO_EE_POINTER_A_OFFSET    E_LED_SECTION_0_STATE_0 - E_LED_SECTION_0
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_DATA_SKIP - LED_SECTION_0
    SAVE_DATA_TO_EE_POINTER_A_OFFSET    E_LED_SECTION_0_DATA_SKIP - E_LED_SECTION_0
    ; grupa na koñcu bo pos³u¿y do pobrania iloœci led
    ldd     R_DATA, R_POINTER_B + LED_SECTION_0_GROUP - LED_SECTION_0
    SAVE_DATA_TO_EE_POINTER_A_OFFSET    E_LED_SECTION_0_GROUP - E_LED_SECTION_0
    ; sprawdzenie czy numer grupy jest poprawny, je¿eli nie to koniec zapisu
    cpi     R_DATA, 8
    brlo    _STE_SECTIONS_LOOP_GROUP_CORRENT
    ldi     R_DATA, 0x9 << 1 ; nieogreœlona grupa
    rjmp    _STE_DATA_ERROR
_STE_SECTIONS_LOOP_GROUP_CORRENT:
    ; przesuniêcie wskaŸnika B na adres danych sekcji
    adiw    R_POINTER_B, LED_SECTION_0_DATA - LED_SECTION_0
    ; zachowaie wskaŸnika B
    movw    R_TMP_1, R_POINTER_B
    ; pobranie iloœci LED w grupie
    LDI16   R_POINTER_B, LED_GROUP_LEN_TAB
    add     R_POINTER_B_L, R_DATA
    adc     R_POINTER_B_H, R_ZERO
    ; iloœæ danych w grupie
    ld      R_LOOP, R_POINTER_B
    ; przywrocenie wskaŸnika B
    movw    R_POINTER_B, R_TMP_1
    ; przesuniêcie wskaŸnika A a dares danych
    adiw    R_POINTER_A, E_LED_SECTION_0_DATA - E_LED_SECTION_0
    ; pêtla danych
_STE_SECTION_DATA_LOOP:
    ; warunek pêtli danych
    tst     R_LOOP
    breq    _STE_SECTION_DATA_LOOP_END
    dec     R_LOOP
    
    ; porownanie dla sprawdzenia czy koniec danych EE
    CPI16   R_POINTER_A, E_LED_SECTIONS_END
    brlo    _STE_SECTIONS_LOOP_EE_ADDRESS_CORRENT
    ; przekroczony adres EE
    ldi     R_DATA, 0xA << 1 ; przekroczony adres
    rjmp    _STE_DATA_ERROR
_STE_SECTIONS_LOOP_EE_ADDRESS_CORRENT:

; porownanie dla sprawdzenia czy koniec danych RAM
    CPI16   R_POINTER_B, LED_SECTIONS_END
    brlo    _STE_SECTIONS_LOOP_RAM_ADDRESS_CORRENT
    ; przekroczony adres RAM
    ldi     R_DATA, 0xD << 1 ; przekroczony adres
    rjmp    _STE_DATA_ERROR
_STE_SECTIONS_LOOP_RAM_ADDRESS_CORRENT:

    ; zapisaie bajtu danych
    ld      R_DATA, R_POINTER_B +
    rcall   SAVE_BYTE_TO_EE_POINTER_A
    adiw    R_POINTER_A, 1

    ;koniec pêtli danych
    rjmp    _STE_SECTION_DATA_LOOP
_STE_SECTION_DATA_LOOP_END:

    ; koniec pêtli sekcji 
    rjmp    _STE_SECTIONS_LOOP
    
_STE_DATA_CORRECT:
    clc
    rjmp     _STE_DATA_SKIP
_STE_DATA_ERROR:
    sec
    rjmp     _STE_DATA_SKIP

_STE_DATA_SKIP:

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
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
SET_TEST_DATA:
    rcall    TEST_I2C_REQUEST_SET_GROUP_SIZE
    rcall    TEST_I2C_REQUEST_ADD_SECTIONS
    ret
;----------------------------------------------------------------------------
TEST_I2C_REQUEST_SET_GROUP_SIZE:
    ; zerowanie ilosci w grupach
    LDI16   R_POINTER_A, LED_GROUP_LEN_TAB
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO
    st      R_POINTER_A+, R_ZERO

    ; rozmiar grupy 10 - 30 LED - b³¹d grupy
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER +, I2C_REQUEST_SET_GROUP_SIZE
    STI     R_I2C_BUF_POINTER +, 10
    STI     R_I2C_BUF_POINTER +, 30
    rcall   I2C_CHECK_REQUEST
    
    ; rozmiar grupy 0 - 50 LED
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_GROUP_SIZE
    STI     R_I2C_BUF_POINTER+, 0
    STI     R_I2C_BUF_POINTER+, 51
    rcall   I2C_CHECK_REQUEST

    ; rozmiar grupy 1 - 51 LED
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_GROUP_SIZE
    STI     R_I2C_BUF_POINTER+, 1
    STI     R_I2C_BUF_POINTER+, 51
    rcall   I2C_CHECK_REQUEST
    
    ; rozmiar grupy 2 - 30 LED
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_GROUP_SIZE
    STI     R_I2C_BUF_POINTER+, 2
    STI     R_I2C_BUF_POINTER+, 30
    rcall   I2C_CHECK_REQUEST
    
    ; rozmiar grupy 1 - 100 LED
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_GROUP_SIZE
    STI     R_I2C_BUF_POINTER+, 1
    STI     R_I2C_BUF_POINTER+, 100
    rcall   I2C_CHECK_REQUEST
    
    ; rozmiar grupy 4 - 4 LED
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_GROUP_SIZE
    STI     R_I2C_BUF_POINTER+, 4
    STI     R_I2C_BUF_POINTER+, 4
    rcall   I2C_CHECK_REQUEST

    ret
;----------------------------------------------------------------------------
TEST_I2C_REQUEST_ADD_SECTIONS:
    STSI8   LED_SECTION_COUNT, 0

    ; sekcja 0
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_ADD_SECTION
    rcall   I2C_CHECK_REQUEST
    
    ; naglowek sekcji 0
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_SECTION_CONTROL
    STI     R_I2C_BUF_POINTER+, 0 ; sekcja
    STI     R_I2C_BUF_POINTER+, 4 ; grupa
    STI     R_I2C_BUF_POINTER+, 0 ; state3
    STI     R_I2C_BUF_POINTER+, 0 ; state2
    STI     R_I2C_BUF_POINTER+, 0 ; state1
    STI     R_I2C_BUF_POINTER+, 1 ; state0
    STI     R_I2C_BUF_POINTER+, 3 ; counter
    rcall   I2C_CHECK_REQUEST
    
    ; dane sekcji 0
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SET_SECTION_DATA
    STI     R_I2C_BUF_POINTER+, 0 ; sekcja
    STI     R_I2C_BUF_POINTER+, 1 ; 1
    STI     R_I2C_BUF_POINTER+, 3 ; 3
    STI     R_I2C_BUF_POINTER+, 5 ; 5
    STI     R_I2C_BUF_POINTER+, 7 ; 7
    rcall   I2C_CHECK_REQUEST
 
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_ADD_SECTION
    rcall   I2C_CHECK_REQUEST

; zapis do EE
    LDI16   R_I2C_BUF_POINTER, I2C_RECV_DATA_REQUEST
    STI     R_I2C_BUF_POINTER+, I2C_REQUEST_SAVE_EE + (1 << I2C_REQUEST_SAVE_EE_DATA_BIT)
    rcall   I2C_CHECK_REQUEST
    
; odczyt z EE
    rcall   LOAD_FROM_EE

    ret
;----------------------------------------------------------------------------
SET_TEST_DATA_MEM:
    ; WskaŸnik sekcji
    LDI16   R_POINTER_A, LED_SECTION_0

    ; Grupa 0
    STSI8   LED_GROUP_LEN_TAB + 0, 2
    ; Sekcja 0 grupa 0
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_GROUP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_1
    STI     R_POINTER_A+, 0b00000001  ; LED_SECTION_0_STATE_0
    STI     R_POINTER_A+, 2  ; LED_SECTION_0_DATA_SKIP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_H
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_L
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_1
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_0
    STI     R_POINTER_A+, 1  ; LED_SECTION_0_DATA - 0
    STI     R_POINTER_A+, 8  ; LED_SECTION_0_DATA - 1

    ; Grupa 1
    STSI8   LED_GROUP_LEN_TAB + 1, 4
    ; Sekcja 1, grupa 1
    STI     R_POINTER_A+, 1  ; LED_SECTION_0_GROUP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_1
    STI     R_POINTER_A+, 0b00000010  ; LED_SECTION_0_STATE_0
    STI     R_POINTER_A+, 3  ; LED_SECTION_0_DATA_SKIP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_H
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_L
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_1
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_0
    STI     R_POINTER_A+, 1  ; LED_SECTION_0_DATA - 0
    STI     R_POINTER_A+, 5  ; LED_SECTION_0_DATA - 1
    STI     R_POINTER_A+, 9  ; LED_SECTION_0_DATA - 2
    STI     R_POINTER_A+, 0xFF  ; LED_SECTION_0_DATA - 3
    ; Sekcja 2, grupa 1
    STI     R_POINTER_A+, 1  ; LED_SECTION_0_GROUP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_1
    STI     R_POINTER_A+, 0b00000100  ; LED_SECTION_0_STATE_0
    STI     R_POINTER_A+, 3  ; LED_SECTION_0_DATA_SKIP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_H
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_L
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_1
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_0
    STI     R_POINTER_A+, 0xFF  ; LED_SECTION_0_DATA - 0
    STI     R_POINTER_A+, 12  ; LED_SECTION_0_DATA - 1
    STI     R_POINTER_A+, 6  ; LED_SECTION_0_DATA - 2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_DATA - 3

    ; Grupa 2
    STSI8   LED_GROUP_LEN_TAB + 2, 0
    
    ; Grupa 3
    STSI8   LED_GROUP_LEN_TAB + 3, 0
    
    ; Grupa 4
    STSI8   LED_GROUP_LEN_TAB + 4, 0
    
    ; Grupa 5
    STSI8   LED_GROUP_LEN_TAB + 5, 0
    
    ; Grupa 6
    STSI8   LED_GROUP_LEN_TAB + 6, 0
    
    ; Grupa 7
    STSI8   LED_GROUP_LEN_TAB + 7, 3
    ; Sekcja 3, grupa 7
    STI     R_POINTER_A+, 7  ; LED_SECTION_0_GROUP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_STATE_1
    STI     R_POINTER_A+, 0b00000100  ; LED_SECTION_0_STATE_0
    STI     R_POINTER_A+, 3  ; LED_SECTION_0_DATA_SKIP
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_H
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_COUNTER_L
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_3
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_2
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_1
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_RESERVED_0
    STI     R_POINTER_A+, 8  ; LED_SECTION_0_DATA - 0
    STI     R_POINTER_A+, 0  ; LED_SECTION_0_DATA - 1
    STI     R_POINTER_A+, 8  ; LED_SECTION_0_DATA - 2
    
    STSI8   LED_SECTION_COUNT, 4

    ret
