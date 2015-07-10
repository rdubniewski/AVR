/****************************************************************************
File:				Uart.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2012.02.21
Modified:			2012.02.21
****************************************************************************/
.include "Uart.inc"

.cseg

; Funkcja czeka (UART_FREQUENCY / UART_BPT) taktow zegara
UART_WAIT:
	push r31 ; Licznik H
	push r30 ; Licznik L
	
	lds  r30, UART_BPS_DELAY
	lds  r31, UART_BPS_DELAY + 1

_UW_LOOP:
	sbiw r30, 1
	brne _UW_LOOP
	
	nop
	nop
	nop

	pop r30
	pop r31

	ret 
;------------------------------------------------------------------------------
; konfiguruje IO do komunikacji
UART_PREPARE_OUTPUT:
	sbi UART_T_DDR, UART_T_BIT
	sbi UART_T_PORT, UART_T_BIT
	ret
;------------------------------------------------------------------------------
; Ustawia bit stopu i czeka dwa takry
UART_INIT:
	;bit stopu
	sbi  UART_T_PORT, UART_T_BIT
	rcall UART_WAIT
	rcall UART_WAIT
	ret
;------------------------------------------------------------------------------
; Wysyla bajt zgodnie z konfiguracja w Uart.inc
UART_SEND:
	push r31 ; 
	push r30
	
	; licznik wysylanych jedynek, inkrementowany w funkcji UART_SEND_BIT
	clr r31 

	; Wysylana wartosc
	lds r30, UART_DATA

	; bit startu, kasowany Carry, UART_SEND_BIT ustawi bit Carry jezeli w UART_DATA
	; byl ustawiony najmlodszy bit
	clc
	rcall UART_SEND_BIT
	; kolejno 5-8 bitow
	rcall UART_SEND_BIT ; 0 bit
	rcall UART_SEND_BIT ; 1 bit
	rcall UART_SEND_BIT ; 2 bit
	rcall UART_SEND_BIT ; 3 bit
#ifndef UART_BYTE_SIZE
  #error "Undefined UART_BYTE_SIZE"
#elif (UART_BYTE_SIZE >= UART_BYTE_SIZE_5 && UART_BYTE_SIZE <= UART_BYTE_SIZE_8)	
	rcall UART_SEND_BIT ; 4 bit 	
 #if (UART_BYTE_SIZE >= UART_BYTE_SIZE_6)
    rcall UART_SEND_BIT ; 5 bit
  #if (UART_BYTE_SIZE >= UART_BYTE_SIZE_7)
	rcall UART_SEND_BIT ; 6 bit 
	#if (UART_BYTE_SIZE == UART_BYTE_SIZE_8)
	rcall UART_SEND_BIT ; 7 bit
	#endif
  #endif
 #endif
#else
  #error "Invalid definition of UART_BYTE_SIZE"	
#endif

	; bit PARZYSTOSCI
#if ( UART_PARITY == UART_PARITY_NONE )
  #message "UART_PARITY == UART_PARITY_NONE"
#else
  #if ( UART_PARITY == UART_PARITY_EVEN )
    #message "UART_PARITY == UART_PARITY_EVEN"
	lsr r31
  #elif ( UART_PARITY == UART_PARITY_ODD )
    #message "UART_PARITY == UART_PARITY_ODD"
	com r31 ; negacja wszystkich bitow
	lsr r31
  #elif ( UART_PARITY == UART_PARITY_1 )
    #message "UART_PARITY == UART_PARITY_1"
	sec ; ustawienie SREG:Carry
  #elif ( UART_PARITY == UART_PARITY_0 )
    #message "UART_PARITY == UART_PARITY_0"
	clc	; wyczyszczenie SREG:Carry
  #else    
    #error "Invalid definition of UART_PARITY"
  #endif
  rcall UART_SEND_BIT
#endif
	; bit stopu
	sec ; ustawienie SREG:Carry
#ifdef UART_BIT_STOP
 #if ((UART_BIT_STOP == UART_BIT_STOP_1) || (UART_BIT_STOP == UART_BIT_STOP_2) )
	rcall UART_SEND_BIT	
  #if (UART_BIT_STOP == UART_BIT_STOP_2 )
	rcall UART_WAIT
  #endif
 #else
  #error "Invalid definition of UART_BIT_STOP"
 #endif
#else
 #error "Undefined UART_BIT_STOP"
#endif
	
	pop r30
	pop r31

	ret
;------------------------------------------------------------------------------
; Ustawia UART_SEND_PORT:UART_SEND_PIN jezeli Carry jest jest ustawione
; kasuje gdy Carry nie jest ustawione
; Przesuniecie nastepuje na koncu
UART_SEND_BIT:	
	brcs UART_SEND_BIT_1;

UART_SEND_BIT_0:
	cbi  UART_T_PORT, UART_T_BIT
	rjmp UART_SEND_BIT_END

UART_SEND_BIT_1:
	sbi  UART_T_PORT, UART_T_BIT
	; zmiana bit parzystosci w r31
	inc r31
	
UART_SEND_BIT_END:
	
	rcall UART_WAIT
	
	; przesuniecie w na nastepny bit,
	; jezeli teraz najmlodszy (nastepny wysylany bit) bedzie ustawiony
	; to zostanie ustawiona flaga SREG:Carry
	lsr  r30
	
	ret
;------------------------------------------------------------------------------
/* 
; Funkcja testujaca
UART_TEST:
	push r31

	rcall UART_INIT
	
	ldi r31, 8
	sts UART_DATA, r31
	rcall UART_SEND
	
	ldi r31, 9
	sts UART_DATA, r31
	rcall UART_SEND
	
	ldi r31, 123
	sts UART_DATA, r31
	rcall UART_SEND

	ldi r31, 51
	sts UART_DATA, r31
	rcall UART_SEND

	pop r31

	ret
*/
UART_FREQUENCY_TEST:		
_UFT_LOOP:
	clc
	rcall UART_SEND_BIT
	sec
	rcall UART_SEND_BIT
	rjmp _UFT_LOOP
	