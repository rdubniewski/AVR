/*
 * TwiTestMegaMaster.asm
 *
 *  Created: 2013-10-11 01:54:13
 *   Author: rafal
 */ 


 .equ   FREQUENCY   = 8000000

.include <m32def.inc>

.dseg
; kontrast wyswietlacza
DISPLAY_CONTRAST:           .byte   1
; czas dzialania wyswietlacza bez aktywnosci uzytkownika
DISPLAY_ON_TIME_INDEX:      .byte   1

DISPLAY_OFF_COUNTER:
DISPLAY_OFF_COUNTER_L:      .byte   1
DISPLAY_OFF_COUNTER_H:      .byte   1

I2C_DATA_SIZE:          .byte 1
I2C_PUT_DATA:
I2C_PUT_DATA_L:         .byte 1
I2C_PUT_DATA_H:         .byte 1

CONVERSION_BUF:         .byte   10

.equ    PCF_TIME_SIZE   = 100
PCF_TIME:               .byte PCF_TIME_SIZE


.def    R_TMP_1             = r16
.def    R_TMP_2             = r17
.def    R_DATA              = r18
.def    R_LOOP              = r19
.def    R_PRECISION         = r20
.def    R_DIV_DIVIDEND_0    = r21
.def    R_DIV_DIVIDEND_1    = r22

.def    R_WAIT_0            = r30
.def    R_WAIT_1            = r31
.def    R_WAIT_2            = r29


#define R_HD44780_DATA       R_DATA


.equ    DISPLAY_COLUMN_COUNT                = 20
#define DISPLAY_SET_POS                     HD44780_20_SET_POS

.include "Wait.inc"
.include "HD44780.inc"


;********** Konfiguracja IO **************************************************

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

; IO wyswietlacza LCD
DEFINE_IO   HD44780_RS,         A, 1
DEFINE_IO   HD44780_RW,         A, 2
DEFINE_IO   HD44780_E,          A, 3
DEFINE_IO   HD44780_4,          A, 4
DEFINE_IO   HD44780_5,          A, 5
DEFINE_IO   HD44780_6,          A, 6
DEFINE_IO   HD44780_7,          A, 7
; Zasilanie wyswietlacza
DEFINE_IO   DISPLAY_POWER,      B, 7
; Kontrast wyswietlacza
DEFINE_IO   DISPLAY_CONTRAST,   C, 2


DEFINE_IO   L_1_MILIHENR,       B, 0



.macro DISPLAY_POWER_ON
	sbi     DISPLAY_POWER_PORT, DISPLAY_POWER_BIT
.endmacro

.macro DISPLAY_POWER_OFF
	cbi     DISPLAY_POWER_PORT, DISPLAY_POWER_BIT
.endmacro

.macro SKIP_IF_DISPLAY_POWER_ON
	sbic    DISPLAY_POWER_PORT, DISPLAY_POWER_BIT
.endmacro

.macro SKIP_IF_DISPLAY_POWER_OFF
	sbis    DISPLAY_POWER_PORT, DISPLAY_POWER_BIT
.endmacro


.macro PUSH_16
	push    @0L
	push    @0H
.endmacro

.macro POP_16
	pop     @0H
	pop     @0L
.endmacro


.macro LDI_16
	ldi     @0L, low(@1)
	ldi     @0H, high(@1)
.endmacro

.macro  STI
    ldi     R_TMP_1, @1
    sts     @0, R_TMP_1
.endmacro


.cseg
.org 0x0        rjmp    RESET
.org TWIaddr    rjmp    I2C
.org ACIaddr    rjmp    ANALOG_COMPARATOR_INTERRUPT
;.org USI_STARTaddr
;	reti

;.org USI_OVFaddr	
;	reti
.org INT_VECTORS_SIZE

.equ    CONTROL_FREQUENCY                   = 50


;----------------------------------------------------------------------------
; Definicja czasow aktywnosci wyswietlacza.
.equ    DISPLAY_ON_TIME_TIMES_10_SEC_VAL    = 10 * CONTROL_FREQUENCY
        DISPLAY_ON_TIME_TIMES_10_SEC_STR:   .db "10 sekund", 0
.equ    DISPLAY_ON_TIME_TIMES_30_SEC_VAL    = 30 * CONTROL_FREQUENCY
        DISPLAY_ON_TIME_TIMES_30_SEC_STR:   .db "30 sekund", 0
.equ    DISPLAY_ON_TIME_TIMES_1_MIN_VAL     = 1 * 60 * CONTROL_FREQUENCY
        DISPLAY_ON_TIME_TIMES_1_MIN_STR:    .db "1 minuta", 0, 0
.equ    DISPLAY_ON_TIME_TIMES_2_MIN_VAL     = 2 * 60 * CONTROL_FREQUENCY
        DISPLAY_ON_TIME_TIMES_2_MIN_STR:    .db "2 minuty", 0, 0
.equ    DISPLAY_ON_TIME_TIMES_5_MIN_VAL     = 5 * 60 * CONTROL_FREQUENCY
        DISPLAY_ON_TIME_TIMES_5_MIN_STR:    .db "5 minut", 0
.equ    DISPLAY_ON_TIME_TIMES_10_MIN_VAL    = 10 * 60 * CONTROL_FREQUENCY
        DISPLAY_ON_TIME_TIMES_10_MIN_STR:   .db "10 minut", 0, 0
.equ    DISPLAY_ON_TIME_TIMES_STILL_VAL     = 0
        DISPLAY_ON_TIME_TIMES_STILL_STR:   .db "stale", 0

DISPLAY_ON_TIME_TIMES:
    .dw DISPLAY_ON_TIME_TIMES_10_SEC_VAL, DISPLAY_ON_TIME_TIMES_10_SEC_STR * 2
    .dw DISPLAY_ON_TIME_TIMES_30_SEC_VAL, DISPLAY_ON_TIME_TIMES_30_SEC_STR * 2
    .dw DISPLAY_ON_TIME_TIMES_1_MIN_VAL, DISPLAY_ON_TIME_TIMES_1_MIN_STR * 2
    .dw DISPLAY_ON_TIME_TIMES_2_MIN_VAL, DISPLAY_ON_TIME_TIMES_2_MIN_STR * 2
    .dw DISPLAY_ON_TIME_TIMES_5_MIN_VAL, DISPLAY_ON_TIME_TIMES_5_MIN_STR * 2
    .dw DISPLAY_ON_TIME_TIMES_10_MIN_VAL, DISPLAY_ON_TIME_TIMES_10_MIN_STR * 2
    .dw DISPLAY_ON_TIME_TIMES_STILL_VAL, DISPLAY_ON_TIME_TIMES_STILL_STR * 2
DISPLAY_ON_TIME_TIMES_END:
.equ    DISPLAY_ON_TIME_TIMES_COUNT = (DISPLAY_ON_TIME_TIMES_END - DISPLAY_ON_TIME_TIMES) / 2
;----------------------------------------------------------------------------


RESET:
    ; zainicjowanie stosu
	ldi r31, high(RAMEND)
	out SPH, r31
    ldi r31, low(RAMEND)
	out SPL, r31

	; zainicjowanie portow
;	clr r31
;	out DDRB, r31
;	out PORTB, r31
	
    WAIT_MILISEC 1000
	
	; wlaczenie przerwan
	sei

;	rcall I2C_INIT

    //rcall   CONFIGURE_DISPLAY
    //rcall   DISPLAY_ON

    // rcall   TEST_MEGA
    rcall   TEST_SOFT
    ; rcall   TEST_COIL
    
	ldi r30, 10
MAIN_LOOP:

	;rjmp MAIN_LOOP

	; adres rejestru			
    /*
    rcall I2C_START
	
	ldi R_I2C_DATA, 0xA6
	rcall I2C_SEND_BYTE
	ldi R_I2C_DATA, 69
	rcall I2C_SEND_BYTE	
    ldi R_I2C_DATA, 37
	rcall I2C_SEND_BYTE	
    rcall I2C_STOP

	; odczyt 
	rcall I2C_START
	ldi R_I2C_DATA, 0xA6 + 1
	rcall I2C_SEND_BYTE
	
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_ACK
	rcall I2C_RECV_BYTE_NAK

	rcall I2C_STOP
	*/
	;rjmp MAIN_LOOP
	;reti
;----------------------------------------------------------------------------
I2C_START_TRANSMISSION:
    // adres slave
    out     TWDR, R_DATA
    ; adres bufora
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16    
    ; wystartowanie
    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16

    ret
;----------------------------------------------------------------------------
.equ    MY_DEVICE_I2C_PROGRAMMING_ADDRESS                       = 0x04

.equ    I2C_SOFT_SCL_PORT   = PORTD
.equ    I2C_SOFT_SCL_DDR    = DDRD
.equ    I2C_SOFT_SCL_BIT    = 0
.equ    I2C_SOFT_SDA_PORT   = PORTD
.equ    I2C_SOFT_SDA_PIN    = PIND
.equ    I2C_SOFT_SDA_DDR    = DDRD
.equ    I2C_SOFT_SDA_BIT    = 1

I2C_SOFT_INIT:
    cbi     I2C_SOFT_SCL_PORT, I2C_SOFT_SCL_BIT
    cbi     I2C_SOFT_SCL_DDR, I2C_SOFT_SCL_BIT
    cbi     I2C_SOFT_SDA_PORT, I2C_SOFT_SDA_BIT
    cbi     I2C_SOFT_SDA_DDR, I2C_SOFT_SDA_BIT
    ret

.macro   I2C_SOFT_SCL_0
    sbi     I2C_SOFT_SCL_DDR, I2C_SOFT_SCL_BIT
.endmacro

.macro   I2C_SOFT_SCL_1
    cbi     I2C_SOFT_SCL_DDR, I2C_SOFT_SCL_BIT
.endmacro

.macro   I2C_SOFT_SDA_0
    sbi     I2C_SOFT_SDA_DDR, I2C_SOFT_SDA_BIT
.endmacro

.macro   I2C_SOFT_SDA_1
    cbi     I2C_SOFT_SDA_DDR, I2C_SOFT_SDA_BIT
.endmacro

.macro  I2C_SOFT_WAIT
    WAIT_MICROSEC   3
.endmacro

I2C_SOFT_START:
    I2C_SOFT_SDA_1
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_1
    I2C_SOFT_WAIT
    I2C_SOFT_SDA_0
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_0
    I2C_SOFT_WAIT
    ret

I2C_SOFT_STOP:
    I2C_SOFT_SDA_0
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_1
    I2C_SOFT_WAIT
    I2C_SOFT_SDA_1
    I2C_SOFT_WAIT
    ret

I2C_SOFT_WRITE:
    ldi     R_LOOP, 8
I2C_SOFT_WRITE_LOOP:
    lsl     R_DATA
    brcs    I2C_SOFT_WRITE_LOOP_1
I2C_SOFT_WRITE_LOOP_0:
    I2C_SOFT_SDA_0
    rjmp    I2C_SOFT_WRITE_LOOP_END
I2C_SOFT_WRITE_LOOP_1:
    I2C_SOFT_SDA_1
I2C_SOFT_WRITE_LOOP_END:
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_1
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_0
    I2C_SOFT_WAIT
    dec     R_LOOP
    brne    I2C_SOFT_WRITE_LOOP
    ; Ack/Nak
    I2C_SOFT_SDA_1
    I2C_SOFT_SCL_1
    I2C_SOFT_WAIT
    sbic    I2C_SOFT_SDA_PIN, I2C_SOFT_SDA_BIT
    sbr     R_DATA, 0xFF
    I2C_SOFT_SCL_0
    I2C_SOFT_WAIT
    ret

I2C_SOFT_READ_ACK:
    clt
    rjmp    I2C_SOFT_READ
I2C_SOFT_READ_NAK:
    set
I2C_SOFT_READ:
    I2C_SOFT_SDA_1
    ldi     R_LOOP, 8
I2C_SOFT_READ_LOOP:
    I2C_SOFT_SCL_1
    I2C_SOFT_WAIT
    clc
    sbic    I2C_SOFT_SDA_PIN, I2C_SOFT_SDA_BIT
    sec
    rol R_DATA
    I2C_SOFT_SCL_0
    I2C_SOFT_WAIT
    dec     R_LOOP
    brne    I2C_SOFT_READ_LOOP
    ; wyslanie Ack/Nak
    brts    I2C_SOFT_READ_SEND_NAK
I2C_SOFT_READ_SEND_ACK:
    I2C_SOFT_SDA_0
    rjmp    I2C_SOFT_READ_SEND_END
I2C_SOFT_READ_SEND_NAK:
    I2C_SOFT_SDA_1
I2C_SOFT_READ_SEND_END:
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_1
    I2C_SOFT_WAIT
    I2C_SOFT_SCL_0
    ret

TEST_SOFT:
    rcall   I2C_SOFT_INIT
TEST_SOFT_LOOP:
    WAIT_MILISEC    100

    rcall   I2C_SOFT_START
    ldi     R_DATA, 0b11110000 + (high(567) << 1) + 0
    rcall   I2C_SOFT_WRITE
    ldi     R_DATA, low(567)
    rcall   I2C_SOFT_WRITE
    ldi     R_DATA, 0
    rcall   I2C_SOFT_WRITE

    rcall   I2C_SOFT_START
    ldi     R_DATA, 0b11110000 + (high(567) << 1) + 1
    rcall   I2C_SOFT_WRITE
    ldi     R_DATA, low(567)
    rcall   I2C_SOFT_WRITE
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_NAK
    rcall   I2C_SOFT_STOP


    rcall   I2C_SOFT_START
    ldi     R_DATA, 0x32 + 0
    rcall   I2C_SOFT_WRITE
;    ldi     R_DATA, low(567)
;    rcall   I2C_SOFT_WRITE
    ldi     R_DATA, 0
    rcall   I2C_SOFT_WRITE

    rcall   I2C_SOFT_START
    ldi     R_DATA, 0x32 + 1
;    rcall   I2C_SOFT_WRITE
;    ldi     R_DATA, low(567)
    rcall   I2C_SOFT_WRITE
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_ACK
    rcall   I2C_SOFT_READ_NAK
    rcall   I2C_SOFT_STOP


    rjmp    TEST_SOFT_LOOP
    ret

TEST_MEGA:

;    WAIT_MILISEC 20

    ; bitrate wg wzoru CPU Clock frequency / (16 + 2(TWBR) · 4^TWPS)
    ; TWPS = 0 -> 4^TWPS = 1 , wiec pomijane.
    ;     
    ldi     r16, ((FREQUENCY / 100000) - 16) / 2;
    out     TWBR, r16

    WAIT_MILISEC 100

    rcall    TEST_MEGA_STEROWNIK_ZAWORU
    ; rcall    TEST_MEGA_CZUJNIK_MURU
    ; rcall    TEST_MEGA_TERMOMETR_PIECA
    ret
;----------------------------------------------------------------------------

TEST_MEGA_CZUJNIK_MURU:

.equ    CZUJNIK_MURU_I2C_SLAVE_ADDRES                           = 0xB6
.equ    CZUJNIK_MURU_I2C_REQUEST_MEASURE                        = 0b00
.equ    CZUJNIK_MURU_I2C_REQUEST_RESET                          = 0x01

    
    ; pobranie adresu czujnika
    STI     I2C_DATA_SIZE, 1
    ldi     R_DATA, MY_DEVICE_I2C_PROGRAMMING_ADDRESS + 1
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 999
    
    ; ustawienie nowego adresu czujnika
    STI     I2C_DATA_SIZE, 1
    STI     PCF_TIME + 0, CZUJNIK_MURU_I2C_SLAVE_ADDRES
    ldi     R_DATA, MY_DEVICE_I2C_PROGRAMMING_ADDRESS + 0
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 999
    

TEST_MEGA_CZUJNIK_MURU_LOOP:
    ; zadanie pomiaru parametrow
    STI     I2C_DATA_SIZE, 1
    STI     PCF_TIME + 0, CZUJNIK_MURU_I2C_REQUEST_MEASURE
    ldi     R_DATA, CZUJNIK_MURU_I2C_SLAVE_ADDRES + 0
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 50
    
    ; Pobranie parametrow stan + ilosc czujnikow
    STI     I2C_DATA_SIZE, 1
    ldi     R_DATA, CZUJNIK_MURU_I2C_SLAVE_ADDRES + 1
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1111
    
    ; Pobranie parametrow stan + ilosc czujnikow
    STI     I2C_DATA_SIZE, 1
    ldi     R_DATA, CZUJNIK_MURU_I2C_SLAVE_ADDRES + 1
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 666
    
    ; Pobranie wszystkich parametrow stan + ilosc czujnikow + aktywne czujniki + czujniki
    lds     R_TMP_1, PCF_TIME + 0
    andi    R_TMP_1, 0x0F
    lsl     R_TMP_1
    lsl     R_TMP_1
    subi    R_TMP_1, -2
    sts     I2C_DATA_SIZE, R_TMP_1
    ldi     R_DATA, CZUJNIK_MURU_I2C_SLAVE_ADDRES + 1
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1111
    

    ; Reset
    /*
    STI     I2C_DATA_SIZE, 1
    STI     PCF_TIME + 0, CZUJNIK_MURU_I2C_REQUEST_RESET
    ldi     R_DATA, CZUJNIK_MURU_I2C_SLAVE_ADDRES_DEFAULT + 0
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1000
    */

    rjmp    TEST_MEGA_CZUJNIK_MURU_LOOP

    ret
;----------------------------------------------------------------------------
TEST_MEGA_STEROWNIK_ZAWORU:

.equ    STEROWNIK_ZAWORU_I2C_SLAVE_ADDRES_DEFAULT                = 0x72
.equ    STEROWNIK_ZAWORU_I2C_REQUEST_SET_TEMPERATURE             = 0b01
.equ    STEROWNIK_ZAWORU_I2C_REQUEST_RESET                       = 0x80

TEST_MEGA_STEROWNIK_ZAWORU_LOOP:
    ; Ustawienie temperatury na 28 stopni
    STI     I2C_DATA_SIZE, 3
    ;ldi     R_DATA, STEROWNIK_ZAWORU_I2C_SLAVE_ADDRES_DEFAULT + 0
    ldi     R_DATA, 0b11110000 + (high(567) << 1)
    STI     PCF_TIME + 0, low(567)
    STI     PCF_TIME + 1, STEROWNIK_ZAWORU_I2C_REQUEST_SET_TEMPERATURE
    STI     PCF_TIME + 2, 28
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1111
    
    ; Pobranie temperatury
    STI     I2C_DATA_SIZE, 3
    ldi     R_DATA, STEROWNIK_ZAWORU_I2C_SLAVE_ADDRES_DEFAULT + 1
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1111
    
    ; Ustawienie temperatury na 41 stopni
    STI     I2C_DATA_SIZE, 2
    STI     PCF_TIME + 0, STEROWNIK_ZAWORU_I2C_REQUEST_SET_TEMPERATURE
    STI     PCF_TIME + 1, 41
    ldi     R_DATA, STEROWNIK_ZAWORU_I2C_SLAVE_ADDRES_DEFAULT + 0
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1111
    
    ; Pobranie temperatury
    STI     I2C_DATA_SIZE, 3
    ldi     R_DATA, STEROWNIK_ZAWORU_I2C_SLAVE_ADDRES_DEFAULT + 1
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1111

    ; Reset
    /*
    STI     I2C_DATA_SIZE, 1
    STI     PCF_TIME + 0, STEROWNIK_ZAWORU_I2C_REQUEST_RESET
    ldi     R_DATA, STEROWNIK_ZAWORU_I2C_SLAVE_ADDRES_DEFAULT + 0
    rcall   I2C_START_TRANSMISSION
    WAIT_MILISEC 1000
    */

    rjmp    TEST_MEGA_STEROWNIK_ZAWORU_LOOP

    ret
;----------------------------------------------------------------------------
TEST_MEGA_TERMOMETR_PIECA:
    
    // pobranie adresu SLAVE
    ldi     r16, 1
    sts     I2C_DATA_SIZE, r16    
    ; adres bufora
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16
    ; odczyt z adresu 0    
    ldi     r16, MY_DEVICE_I2C_PROGRAMMING_ADDRESS + 1
    out     TWDR, r16    
    ; wystartowanie
    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16
    
    WAIT_MILISEC 1000
            
    // Ustawienie nowego adresu
    ldi     r16, 1
    sts     I2C_DATA_SIZE, r16
    ; bajty w buforze
    ldi     r16, 0x66
    sts     PCF_TIME + 0, r16
    ; adres bufora
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16
    // adres slave
    ldi     r16, MY_DEVICE_I2C_PROGRAMMING_ADDRESS + 0
    out     TWDR, r16    
    ; wystartowanie
    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16
    
    WAIT_MILISEC 1000

    // wyslanie rozkazu wystartowania pomiaru
    ldi     r16, 1
    sts     I2C_DATA_SIZE, r16    
    ; bajty w buforze
    ldi     r16, 1
    sts     PCF_TIME + 0, r16
    ; adres bufora
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16    
    // adres slave
    ldi     r16, 0x66 + 0
    out     TWDR, r16    
    ; wystartowanie
    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16
    
    WAIT_MILISEC 1000
    ; pobranie wyniku pomiaru
    ldi     r16, 18
    sts     I2C_DATA_SIZE, r16    
    ; adres bufora
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16    
    // adres slave
    ldi     r16, 0x66 + 1
    out     TWDR, r16    
    ; wystartowanie
    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16
    

    WAIT_MILISEC 10000
    WAIT_MILISEC 5000

    
    ; pobranie wyniku pomiaru
    ldi     r16, 18
    sts     I2C_DATA_SIZE, r16    
    ; adres bufora
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16    
    // adres slave
    ldi     r16, 0x66 + 1
    out     TWDR, r16    
    ; wystartowanie
    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16
    
    WAIT_MILISEC 1000


    rjmp TEST_MEGA_TERMOMETR_PIECA
    



    

    ldi     r16, PCF_TIME_SIZE
    sts     I2C_DATA_SIZE, r16
    
    ldi     r16, high(PCF_TIME)
    sts     I2C_PUT_DATA_H, r16
    ldi     r16, low(PCF_TIME)
    sts     I2C_PUT_DATA_L, r16    

    ldi     r16, 0x44 + 1
    out     TWDR, r16    

    ldi     r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
    out     TWCR, r16
    
	WAIT_MILISEC 30
    
    ldi     R_PRECISION, 0
    ldi     R_LOOP, 2

    DISPLAY_SET_POS  0, 0
    ldi_16  X, PCF_TIME + 0
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '
    
    ldi_16  X, PCF_TIME + 1
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    ldi_16  X, PCF_TIME + 2
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    ldi_16  X, PCF_TIME + 3
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    ldi_16  X, PCF_TIME + 4
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    DISPLAY_SET_POS  1, 0
    ldi_16  X, PCF_TIME + 5
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '
    
    ldi_16  X, PCF_TIME + 6
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    ldi_16  X, PCF_TIME + 7
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    ldi_16  X, PCF_TIME + 8
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    ldi_16  X, PCF_TIME + 9
    ldi     R_LOOP, 2
    rcall   PRINT_BCD_X
    HD44780_PRINT_CHAR  ' '

    
    WAIT_MILISEC 500
    
    rjmp    TEST_MEGA_TERMOMETR_PIECA

ret

;----------------------------------------------------------------------------
I2C:
    push    ZH
    push    ZL
    push    r16
    in      r16, SREG
    push    r16

    ; czytanie
    sbic    TWSR, TWS6
    rjmp    I2C_RECV
    
    ; potwierdzenia adresu SLAVE
    sbis    TWSR, TWS3
    rjmp    I2C_ERROR

    ; pisanie
    sbic    TWSR, TWS4
    rjmp    I2C_SLAVE_ADDRESS_ACK

    sbic    TWSR, TWS5
    rjmp    I2C_SLAVE_DATA_ACK
;----------------------------------------------------------------------------
I2C_START:    
    ldi     r16, (1<<TWINT) | (1<<TWEN) | (1<<TWIE)
    rjmp    I2C_END_SET_TWCR
;----------------------------------------------------------------------------
I2C_SLAVE_ADDRESS_ACK:

I2C_SLAVE_DATA_ACK:
    ; sprawdzenie czy to ma byc koniec transmisji.
    lds     r16, I2C_DATA_SIZE
    tst     r16
    breq    I2C_STOP        
    dec     r16
    sts     I2C_DATA_SIZE, r16
    ; wyslanie danych do SLAVE
    ; pobranie kolejnego bajtu danych
    lds     ZH, high(I2C_PUT_DATA_H)
    lds     ZL, low(I2C_PUT_DATA_L)    
    ld      r16, Z+
    out     TWDR, r16
    sts     high(I2C_PUT_DATA_H), ZH
    sts     low(I2C_PUT_DATA_L), ZL
    ldi     r16, (1<<TWINT) | (1<<TWEN) | (1<<TWIE)
    rjmp    I2C_END_SET_TWCR
;----------------------------------------------------------------------------
I2C_RECV:
    ; potwierdzenie adresu SLAVE
    sbis    TWSR, TWS4
    rjmp    I2C_RECV_NEXT_BYTE

    ; zapis odebranego bajtu
    lds     ZH, high(I2C_PUT_DATA_H)
    lds     ZL, low(I2C_PUT_DATA_L)    
    in      r16, TWDR
    st      Z+, r16
    sts     high(I2C_PUT_DATA_H), ZH
    sts     low(I2C_PUT_DATA_L), ZL

    ; czy MASTER wyslal NAK?
    sbic    TWSR, TWS3
    rjmp    I2C_STOP
;----------------------------------------------------------------------------
    ; kontynuowanie czytania        
I2C_RECV_NEXT_BYTE:
    lds     r16, I2C_DATA_SIZE
    dec     r16
    sts     I2C_DATA_SIZE, r16
    brne    I2C_RECV_NEXT_ACK
;----------------------------------------------------------------------------    
I2C_RECV_NEXT_NAK:
    ldi     r16, (1<<TWINT) | (1<<TWEN) | (1<<TWIE)
    rjmp    I2C_END_SET_TWCR
;----------------------------------------------------------------------------
I2C_RECV_NEXT_ACK:
    ldi     r16, (1<<TWINT) | (1<<TWEN) | (1<<TWIE) | (1<<TWEA)
    rjmp    I2C_END_SET_TWCR
;----------------------------------------------------------------------------
I2C_RECV_END:
    ldi     r16, (1<<TWINT) | (1<<TWEN) | (1<<TWIE)
    rjmp    I2C_END_SET_TWCR
;----------------------------------------------------------------------------
I2C_STOP_ACK:
    ldi     r16, (1<<TWINT) | (1<<TWSTO) | (1<<TWEN) | (1<<TWIE) | (1<<TWEA)
    rjmp    I2C_END_SET_TWCR
I2C_ERROR:
I2C_STOP:
    ldi     r16, (1<<TWINT) | (1<<TWSTO) | (1<<TWEN) | (1<<TWIE)

I2C_END_SET_TWCR:
    out     TWCR, r16

    pop     r16
    out     SREG, r16
    pop     r16
    pop     ZL
    pop     ZH

    reti
;---------------


;----------------------------------------------------------------------------
CONFIGURE_DISPLAY:
	rcall   HD44780_CONFIGURE
	
	;ustawienie  2 linie, czcionka, kontynuowanie adresowania 4 bitowego
	ldi     R_HD44780_DATA, HD44780_FUNCTION_SET | HD44780_FS_FONT5x8 | HD44780_FS_TWO_LINES | HD44780_FS_4_BIT
	rcall   HD44780_SEND_INSTRUCTION
	
	; ustawienie kursora
	ldi     R_HD44780_DATA, HD44780_DISPLAY | HD44780_D_DISPLAY_ON | HD44780_D_CURSOR_OFF
	rcall   HD44780_SEND_INSTRUCTION

	; wykasowanie zawartosci 	
	ldi     R_HD44780_DATA, HD44780_CLEAR
	rcall   HD44780_SEND_INSTRUCTION

	; ustawienie kursora na poczatku
	ldi     R_HD44780_DATA, HD44780_HOME
	rcall   HD44780_SEND_INSTRUCTION

	ret
;----------------------------------------------------------------------------
; Wlacza zasilanie wyswietlacza jezeli jest wylaczone, 
; po wlaczeniu konfiguruje wyswietlacz. 
; Zawsze ustawia maksymalna wartosc licznika aktywnosci wyswietlacza
DISPLAY_ON:
	; jak wyswietlacz jest wlaczony to nie ma sensu wlacza 
	; tylko trzeba zresetowac licznik aktywnosci
	SKIP_IF_DISPLAY_POWER_ON
	rjmp    _DO_NO_ENABLE

	; ustawienie wyjsc sterujacych, przed wlaczeniem zasilania.
	cbi     HD44780_E_PORT,  HD44780_E_BIT
	sbi     HD44780_E_DDR,   HD44780_E_BIT
	cbi     HD44780_RW_PORT, HD44780_RW_BIT
	sbi     HD44780_RW_DDR,  HD44780_RW_BIT
	cbi     HD44780_RS_PORT, HD44780_RS_BIT
	sbi     HD44780_RS_DDR,  HD44780_RS_BIT
	
	; wlaczenie zasilania wyswietlacza i konfiguracja wyswietlacza
	DISPLAY_POWER_ON
    
	; wlaczenie PWM kontrastu
	rcall   DISPLAY_PWM_START
	cbi     DISPLAY_CONTRAST_PORT,  DISPLAY_CONTRAST_BIT
	sbi     DISPLAY_CONTRAST_DDR,   DISPLAY_CONTRAST_BIT
		
	rcall   CONFIGURE_DISPLAY
	
_DO_NO_ENABLE:

	; reset licznika aktywnosci wyswietlacza
	; obliczenie ile taktow timera klawiatury potrzeba 
	; do wygaszenia wyswietlacza
    PUSH_16 Z
    LDI_16  Z, DISPLAY_ON_TIME_TIMES * 2
    lds     R_TMP_1, DISPLAY_ON_TIME_INDEX
    ldi     R_TMP_2, 0
    lsl     R_TMP_1
    rol     R_TMP_2
    lsl     R_TMP_1
    rol     R_TMP_2
    add     ZL, R_TMP_1
    adc     ZH, R_TMP_2
    
    lpm     R_TMP_1, Z+
    sts     DISPLAY_OFF_COUNTER_L, R_TMP_1
    lpm     R_TMP_1, Z+    
	sts     DISPLAY_OFF_COUNTER_H, R_TMP_1

    POP_16  Z

	ret
;----------------------------------------------------------------------------
DISPLAY_PWM_START:
    ldi     R_TMP_1, 1 << CS00
    out     TCCR0, R_TMP_1

	ret
;----------------------------------------------------------------------------
PRINT_U16:
    push    R_DIV_DIVIDEND_1
    push    R_DIV_DIVIDEND_0
    push    R_LOOP
    push    XL
    push    XH
    
    LDI_16  X, CONVERSION_BUF
    rcall   U16_TO_BCD_X

    ldi     R_LOOP, 5
    rcall   PRINT_BCD_X
        
    pop     XH
    pop     XL
    pop     R_LOOP
    pop     R_DIV_DIVIDEND_0
    pop     R_DIV_DIVIDEND_1
    
    ret
;----------------------------------------------------------------------------
PRINT_BCD_X:
    push    ZH
    
    clr     ZH

    push    R_LOOP    
    ; przesuniecie na najstarsza cyfre
    dec     R_LOOP
    lsr     R_LOOP
    add     XL, R_LOOP
    clr     R_LOOP
    adc     XH, R_LOOP
    ; przywrocenie R_LOOP
    pop     R_LOOP
    
_PBCDX_LOOP:
    ; sprawdzenie czy nalezy rozpoczac wyswietlanie znakow 
    ; bo nastepna bedzie cyfra po kropce
    inc     R_PRECISION
    cp      R_PRECISION, R_LOOP
    brne    _PBCDX_LOOP_START_0
    sbr     ZH, 1
_PBCDX_LOOP_START_0:
    dec     R_PRECISION
    
    ; wyswietlenie kropki dziesietnej
    cp      R_LOOP, R_PRECISION
    brne    _PBCDX_LOOP_NO_PRINT_DOT    
    HD44780_PRINT_CHAR  '.'
    
    sbr     ZH, 1
_PBCDX_LOOP_NO_PRINT_DOT:
    
    ; pobranie jednej cyfry z bajtu
    ld      R_HD44780_DATA, X
    sbrs    R_LOOP, 0
    swap    R_HD44780_DATA
    sbrc    R_LOOP, 0
    sbiw    X, 1
    andi    R_HD44780_DATA, 0x0F

    ; nakazanie wyswietlania znaku wartosc > 0
    tst     R_HD44780_DATA
    breq    _PBCDX_LOOP_ZERO
    sbr     ZH, 1
_PBCDX_LOOP_ZERO:
    
    ; wyswietleni znaku gdy jest nakazanie wyswietlenia.
    sbrs    ZH, 0
    rjmp    _PBCDX_LOOP_NO_PRINT    
    
    subi    R_HD44780_DATA, -'0'
    rcall   HD44780_WRITE_DATA

_PBCDX_LOOP_NO_PRINT:

    dec     R_LOOP
    brne    _PBCDX_LOOP

    pop     ZH

    ret
;----------------------------------------------------------------------------
#define R_BCD_TMP     YH

; dodanie 3 gdy wieksze od 5        
.macro  UX_TO_BCD_CORRECT
    ; pobranie poczatkowego rejestru korekcji
    lpm     XL, Z+
    ; pominiecie gdy rejestr = 0
    tst     XL
    breq    _UX_TO_BCD_CORRECT_END

_UX_TO_BCD_CORRECT_LOOP:
    ld      R_BCD_TMP, -X
    subi    R_BCD_TMP, -3
    sbrc    R_BCD_TMP, 3
    st      X, R_BCD_TMP
    ld      R_BCD_TMP, X
    subi    R_BCD_TMP, -0x30
    sbrc    R_BCD_TMP, 7
    st      X, R_BCD_TMP
    
    cpi     XL, 2
    brne    _UX_TO_BCD_CORRECT_LOOP

_UX_TO_BCD_CORRECT_END:

.endmacro

U8_TO_BCD_X:
    push    R_DIV_DIVIDEND_0
    push    r2
    push    r3
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH
    
    eor     r2, r2
    eor     r3, r3

    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 8
    
    rjmp    _U8_TO_BCD_NO_CORRECT
    
_U8_TO_BCD_LOOP:
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
   
_U8_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo
    lsl     R_DIV_DIVIDEND_0
    rol     r2
    rol     r3
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U8_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL    
    st      X+, r2
    st      X+, r3
    st      X+, r4
    sbiw    X, 3
    
    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r3
    pop     r2
    pop     R_DIV_DIVIDEND_0

    ret


U16_TO_BCD_X:
    push    R_DIV_DIVIDEND_0
    push    R_DIV_DIVIDEND_1
    push    r2
    push    r3
    push    r4
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH
    
    eor     r2, r2
    eor     r3, r3
    eor     r4, r4

    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 16
    
    rjmp    _U16_TO_BCD_NO_CORRECT
    
_U16_TO_BCD_LOOP:
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
   
_U16_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo
    lsl     R_DIV_DIVIDEND_0
    rol     R_DIV_DIVIDEND_1    
    rol     r2
    rol     r3
    rol     r4
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U16_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL    
    st      X+, r2
    st      X+, r3
    st      X+, r4
    sbiw    X, 3
    
    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r4
    pop     r3
    pop     r2
    pop     R_DIV_DIVIDEND_1
    pop     R_DIV_DIVIDEND_0

    ret

/*
U24_TO_BCD_X:
    push    R_DIV_DIVIDEND_0
    push    R_DIV_DIVIDEND_1
    push    R_DIV_DIVIDEND_2
    push    r2
    push    r3
    push    r4
    push    r5
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH
    
    eor     r2, r2
    eor     r3, r3
    eor     r4, r4
    eor     r5, r5
    
    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 24    
    rjmp    _U24_TO_BCD_NO_CORRECT
    
_U24_TO_BCD_LOOP:    
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
           
_U24_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo    
    lsl     R_DIV_DIVIDEND_0
    rol     R_DIV_DIVIDEND_1
    rol     R_DIV_DIVIDEND_2
    rol     r2
    rol     r3
    rol     r4
    rol     r5
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U24_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL
    st      X+, r2
    st      X+, r3
    st      X+, r4
    st      X+, r5
    sbiw    X, 4

    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r5
    pop     r4
    pop     r3
    pop     r2
    pop     R_DIV_DIVIDEND_2
    pop     R_DIV_DIVIDEND_1
    pop     R_DIV_DIVIDEND_0

    ret


U32_TO_BCD_X:
    push    R_DIV_DIVIDEND_0
    push    R_DIV_DIVIDEND_1
    push    R_DIV_DIVIDEND_2
    push    R_DIV_DIVIDEND_3
    push    r2
    push    r3
    push    r4
    push    r5
    push    r6
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH   

    eor     r2, r2
    eor     r3, r3
    eor     r4, r4
    eor     r5, r5
    eor     r6, r6    

    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 32
    rjmp    _U32_TO_BCD_NO_CORRECT
    
_U32_TO_BCD_LOOP:    
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
           
_U32_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo    
    lsl     R_DIV_DIVIDEND_0
    rol     R_DIV_DIVIDEND_1
    rol     R_DIV_DIVIDEND_2
    rol     R_DIV_DIVIDEND_3
    rol     r2
    rol     r3
    rol     r4
    rol     r5
    rol     r6
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U32_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL
    st      X+, r2
    st      X+, r3
    st      X+, r4
    st      X+, r5
    st      X+, r6
    sbiw    X, 5

    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r6
    pop     r5
    pop     r4
    pop     r3
    pop     r2
    pop     R_DIV_DIVIDEND_3
    pop     R_DIV_DIVIDEND_2
    pop     R_DIV_DIVIDEND_1
    pop     R_DIV_DIVIDEND_0
    
    ret
*/
; wskazania na poczatkowy rejestr korekty BCD
_BIN_TO_BCD_X_CORRECT_INIT_REG: 
    .db 0, 0, 3, 3, 3, 3, 3, 3  
    .db 4, 4, 4, 4, 4, 4, 4, 5
    .db 5, 5, 5, 5, 5, 5, 6, 6
    .db 6, 6, 6, 6, 7, 7, 7, 0
;----------------------------------------------------------------------------



TEST_COIL:
    
TEST_COIL_MEASURE:
    ; wykasowanie cewki
    ldi     R_TMP_1, 0
    out     TCCR1B, R_TMP_1
    cbi     L_1_MILIHENR_PORT, L_1_MILIHENR_BIT

    WAIT_MILISEC    500

    ; kasowanie licznika timera
    ldi     R_TMP_1, 0
    out     TCNT1H, R_TMP_1
    out     TCNT1L, R_TMP_1

    ; wlaczenie analogowego komparatora
    ldi     R_TMP_1, 1 << ACIE | 1 << ACIC | 3 << ACIS0
    out     ACSR, R_TMP_1
    
    ; wlaczenie cewki i uruchomienie timera
    ldi     R_TMP_1, 1
    sbi     L_1_MILIHENR_DDR, L_1_MILIHENR_BIT
    sbi     L_1_MILIHENR_PORT, L_1_MILIHENR_BIT
    out     TCCR1B, R_TMP_1
    
    ; czekamy 200 ms
    WAIT_MILISEC    200

    ; wyswietlenie wartosci cewki
    DISPLAY_SET_POS  0, 0

    in      R_DIV_DIVIDEND_0, TCNT1L
    in      R_DIV_DIVIDEND_1, TCNT1H
    rcall   PRINT_U16
    
    HD44780_PRINT_CHAR  'u'
    HD44780_PRINT_CHAR  'H'
    HD44780_PRINT_CHAR  ' '
    HD44780_PRINT_CHAR  ' '
    HD44780_PRINT_CHAR  ' '
    HD44780_PRINT_CHAR  ' '
    HD44780_PRINT_CHAR  ' '
    HD44780_PRINT_CHAR  ' '


    
    rjmp    TEST_COIL_MEASURE




ANALOG_COMPARATOR_INTERRUPT:
    push    R_TMP_1
    ldi     R_TMP_1, 0
    out     TCCR1B, R_TMP_1
    cbi     L_1_MILIHENR_PORT, L_1_MILIHENR_BIT
    pop     R_TMP_1
    reti

;.include "I2CMaster.asm"
.include "Wait.asm"
.include "HD44780.asm"

