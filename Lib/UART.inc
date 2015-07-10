/****************************************************************************
File:				Uart.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2012.02.21
Modified:			2012.02.21
****************************************************************************/

#ifndef _UART_INC_
#define _UART_INC_

.dseg
; Bajt wysylany przez UART
UART_DATA: .db 0
UART_BPS_DELAY: .byte 2

; Czestotliwosc zegara
; Musi byc zdefiniowany w programie, przez wlaczeniem Uart.asm
;.equ UART_FREQUENCY = 1000000;

; Dostepne wartosci dla makra UART_SET_BPS
.equ UART_BPS_600	= 600
.equ UART_BPS_1200	= 1200
.equ UART_BPS_1800	= 1800
.equ UART_BPS_2400	= 2400
.equ UART_BPS_4800	= 4800
.equ UART_BPS_7200	= 7200
.equ UART_BPS_9600	= 9600

; Ustala predkosc transmisji UART,
; Oblicza wartosci opoznienia dla funkcji UART_WAIT, 
; wynik zapisuje w  UART_BPS_DELAY
.macro UART_SET_BPS
	push r31
	.equ delay = (UART_FREQUENCY / @0  / 4) - 9 ; 9 jest dobrany doswiadczalnie
	ldi  r31, low(delay)
	sts  UART_BPS_DELAY, r31
	ldi  r31, high(delay)
	sts  UART_BPS_DELAY + 1, r31
	pop  r31
.endmacro

; Dozwolone wartosci dla UART_BYTE_SIZE
#define UART_BYTE_SIZE_5	5
#define UART_BYTE_SIZE_6	6
#define UART_BYTE_SIZE_7	7
#define UART_BYTE_SIZE_8	8

; Rozmiar bajtu 5 - 8 bitow
; Musi byc zdefiniowany w programie, przez wlaczeniem Uart.asm
;#define UART_BYTE_SIZE		UART_BYTE_SIZE_8


; Dozwolone wartosci dla UART_PARITY
#define UART_PARITY_NONE	2
#define UART_PARITY_EVEN	3
#define UART_PARITY_ODD		4
#define UART_PARITY_1		5
#define UART_PARITY_0		6

; Bit parzystowsci, moze byc jedna z powyzszych pieciu wartosci
; #define UART_PARITY UART_PARITY_NONE

; Dozwolone wartosci dla UART_BIT_STOP
#define UART_BIT_STOP_1		2
#define UART_BIT_STOP_2		3

; Ilosc bitow stopu, moze byc jedna z powyzszych 2 wartosci
; #define UART_BIT_STOP UART_BIT_STOP_1

; Port nadajacy 
; Musi byc zdefiniowany w programie, przez wlaczeniem Uart.asm
;.equ UART_SEND_PORT = PORTB
;.equ UART_SEND_DDR = DDRB
;.equ UART_SEND_PIN = 0

#endif
