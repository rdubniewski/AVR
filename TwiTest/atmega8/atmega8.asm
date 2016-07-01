/*
 * atmega8.asm
 *
 *  Created: 2013-07-24 21:54:45
 *   Author: Rafal
 *
 */ 


 .include <m8adef.inc>

.equ    FREQUENCY                           = 4000000


 ; konfiguracja timera kontroli ladowania, klawiatury, wyswietlania (Hz)
; preskaler ustawiony na 8 zeby zeby uzyskiwac ladne czestotliwosci
.equ    TIMER_CHECK_TCCR2                   = 1 << WGM21 | 1 << CS21
.equ    TIMER_CHECK_PRESCALER               = 8
; zadana generowania przerwania resetu timera ( calkowita wielokrotnosc 1kHz )
.equ    TIMER_CHECK_INTERRUPT_FREQUENCY     = 1000 * (1  + (FREQUENCY / TIMER_CHECK_PRESCALER / 1000 / 256) )
; wartosc przepelnienia licznika timera by zachowac n * 1hHz
.equ    TIMER_CHECK_OCR                     = FREQUENCY / (TIMER_CHECK_PRESCALER * TIMER_CHECK_INTERRUPT_FREQUENCY) - 1
; kontrola czy wyliczony TIMER_CHECK_OCR da czestotliwosc przerwan n*1kHz
.if ( FREQUENCY != ((TIMER_CHECK_OCR + 1) * TIMER_CHECK_INTERRUPT_FREQUENCY * TIMER_CHECK_PRESCALER) )
    .error "TIMER_CHECK_INTERRUPT_FREQUENCY nie jest wielokrotnoscia 1kHz, prowadzi to do blednego obliczania przekazanej energii"
.endif

; czestotliwosc dla kontroli stanu (Hz)
.equ    CONTROL_FREQUENCY                   = 50
; wartosc poczatkowa dla licznika TIMER_CHECK_COUNTER.
; Po przekroczeniu jej nastepuje zerowanie licznika i kontrola stanu
.equ    CONTROL_FREQUENCY_COUNTER_MAX       = TIMER_CHECK_INTERRUPT_FREQUENCY / CONTROL_FREQUENCY
; kontrola czy przy wyliczaniu CONTROL_FREQUENCY_COUNTER_MAX jest liczba calkowita
.if ( (CONTROL_FREQUENCY_COUNTER_MAX * CONTROL_FREQUENCY) != TIMER_CHECK_INTERRUPT_FREQUENCY)
    .error "Obliczenie TIMER_CHECK_COUNTER_MAX nie dalo wyniku calkowitego, prowadzi to do blednego obliczania przekazanej energii"
.endif

.equ    SLA_W                       = 96

.def    R_TMP_1                     = r16
.def    R_AR                        = r20
.def    R_DR                        = r21
.def    R_CONTROL                   = r25

.equ    R_CONTROL_SIGNAL_BIT		= 7


 
.dseg
CONTROL_FREQUENCY_COUNTER:  .byte   1



.cseg

.org 0x0        rjmp    RESET	
.org OC2addr    rjmp    TIMER2
.org TWIaddr    rjmp    TWI

.org INT_VECTORS_SIZE

RESET:
    ; zainicjowanie stosu
    ldi     r31, low(RAMEND)
	out     SPL, r31
	ldi     r31, high(RAMEND)
	out     SPH, r31

    ldi     r16, CONTROL_FREQUENCY_COUNTER_MAX
    sts     CONTROL_FREQUENCY_COUNTER, r16
    
    ; ustawienie timera badania klawiatury mocy i wyswietlacza:
	in      R_TMP_1, TIMSK
	sbr     R_TMP_1, 1 << OCIE2
    out     TIMSK, R_TMP_1
    ldi     R_TMP_1, TIMER_CHECK_OCR
    out     OCR2, R_TMP_1
    ldi     R_TMP_1, TIMER_CHECK_TCCR2
	out     TCCR2, R_TMP_1
    
    sei
    
    ; konfiguracja
    sbi     PORTC, 4
    sbi     PORTC, 5

    ; bitrate
    ldi     R_TMP_1, 3;
    out     TWBR, R_TMP_1

    ; preskaler
    ldi     R_TMP_1, 0;
    out     TWSR, R_TMP_1

    ldi     R_AR, 0xD0
    
MAIN_LOOP:
    sbrc    R_CONTROL, R_CONTROL_SIGNAL_BIT
    rjmp    _ML_SIGNAL
    sleep
    rjmp    MAIN_LOOP    

_ML_SIGNAL:
    cbr     R_CONTROL, 1 << R_CONTROL_SIGNAL_BIT
   
    ; Send START condition
.equ    START = 0x08
.equ    MT_SLA_ACK = 0x18
    ldi r16, (1<<TWINT)|(1<<TWSTA)| (1<<TWEN);
    out TWCR, r16

    ; Wait for TWINT Flag set. 
    ; This indicates that the START condition has been transmitted
wait1:
    in r16,TWCR
    sbrs r16,TWINT
    rjmp wait1

    ; Check value of TWI Status Register. 
    ; Mask prescaler bits. If status different from START go to ERROR
    in r16,TWSR
    andi r16, 0xF8
    cpi r16, START
    brne ERROR

    ; Load SLA_W into TWDR Register.
    ; Clear TWINT bit in TWCR to start transmission of address 
    out TWDR, R_AR
    ldi r16, (1<<TWINT) | (1<<TWEN)
    out TWCR, r16

    ; Wait for TWINT Flag set. 
    ; This indicates that the SLA+W has been transmitted, 
    ; and ACK/NACK has been received.
wait2:
    in r16,TWCR
    sbrs r16,TWINT
    rjmp wait2

    ; Check value of TWI Status Register. 
    ; Mask prescaler bits. 
    ; If status different from MT_SLA_ACK go to ERROR
    in r16,TWSR
    andi r16, 0xF8
    cpi r16, MT_SLA_ACK
    brne ERROR


    ; Load DATA into TWDR Register.
    ; Clear TWINT bit in TWCR to start transmission of data
    out TWDR, R_DR
    ldi r16, (1<<TWINT) | (1<<TWEN)
    out TWCR, r16

    ; Wait for TWINT Flag set. 
    ; This indicates that the DATA has been transmitted, 
    ; and ACK/NACK has been received.
wait3:
    in r16,TWCR
    sbrs r16,TWINT
    rjmp wait3

    inc R_DR

    rjmp    STOP

ERROR:
    inc R_AR
    
STOP:
    ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
    out TWCR, r16

    rjmp    MAIN_LOOP    
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
TIMER2:
    push    r16
    in      r16, SREG
    push    r16
    
    lds     r16, CONTROL_FREQUENCY_COUNTER
    dec     r16
    sts     CONTROL_FREQUENCY_COUNTER, r16
    
    brne    _T2_NO_SIGNAL

    ldi     r16, CONTROL_FREQUENCY_COUNTER_MAX
    sts     CONTROL_FREQUENCY_COUNTER, r16
    
    sbr     R_CONTROL, 1 << R_CONTROL_SIGNAL_BIT

_T2_NO_SIGNAL:    

    pop     r16
    out     SREG, r16
    pop     r16

    reti
;----------------------------------------------------------------------------
TWI:
    reti