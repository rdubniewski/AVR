/****************************************************************************
File:				Wait.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.01
Modified:			2013.02.01
****************************************************************************/

.include "Calendar.inc"
;----------------------------------------------------------------------------

; Ilosc dni z RTC, do liczenia roku, miesiaca i dnia
; w gornym obszarze wyniku dzielenia 32 bitow, to dzielenie jest tylko 
; za pierwszym razem, tetem liczby mieszcza sie w 16 bitach
#define R_DAYS_0			R_DIV_REMAINDER_3
#define R_DAYS_1			R_DIV_DIVISOR_3

; Dla liczenia roku, uzywane sa: R_DAYS_0,1
#define R_DAYS_IN_YEAR_0	R_DIV_DIVIDEND_0
#define R_DAYS_IN_YEAR_1	R_DIV_DIVIDEND_1
#define R_YEAR_PRZESTEPNY	R_DIV_DIVIDEND_2
#define R_YEAR				R_DIV_DIVIDEND_3

; Dla liczenia miesiaca, uzywane sa: R_YEAR, R_DAYS_0,1
#define R_MONTH				R_DIV_DIVIDEND_2
; Dla porownania z dniem w roku ( > 255 ) dni w miesiacu na 2 rejestrach
#define R_DAYS_IN_MONTH_0	R_DIV_DIVIDEND_0
#define R_DAYS_IN_MONTH_1	R_DIV_DIVIDEND_1
#define R_STORE_ZL			R_DIV_DIVISOR_0
#define R_STORE_ZH			R_DIV_DIVISOR_1

RTC_DAYS_IN_MONTH: .db 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


RTC_TEST:
	push   R_DIV_DIVIDEND_0
	push   R_DIV_DIVIDEND_1
	push   R_DIV_DIVIDEND_2
	push   R_DIV_DIVIDEND_3
	push   R_DIV_DIVISOR_0
	push   R_DIV_DIVISOR_1
	push   R_DIV_DIVISOR_2
	push   R_DIV_DIVISOR_3
	push   R_DIV_REMAINDER_0
	push   R_DIV_REMAINDER_1
	push   R_DIV_REMAINDER_2
	push   R_DIV_REMAINDER_3

	; Najpierw policzenie ilosci dni od poczatku, reszta z tego to sekundy w dobie.
	; Poniewaz amy juz sekundy to liczony jest czas(godziny, minuty, sekundy) przed data
	; poniewaz sekundy zapisane sa jako reszta i przy kolejnych obliczeniach, zostaly 
	; by zamazane, a liczenie czasu nie ma wplywu na obliczona juz ilosc dni.

	; policzenie dni, reszta z dzielenia to ilosc sekund w dobie
	lds   R_DIV_DIVIDEND_0, RTC_TICKS
	lds   R_DIV_DIVIDEND_1, RTC_TICKS + 1
	lds   R_DIV_DIVIDEND_2, RTC_TICKS + 2
	lds   R_DIV_DIVIDEND_3, RTC_TICKS + 3
	LDI_DIV_32 R_DIV_DIVISOR_3, R_DIV_DIVISOR_2, R_DIV_DIVISOR_1, R_DIV_DIVISOR_0, 24 * 60 * 60	
	DIV_U32

	; zachowanie dni, beda jeszcze potrzebne
	mov   R_DAYS_0, R_DIV_DIVIDEND_0
	mov   R_DAYS_1, R_DIV_DIVIDEND_1
	
	; policzenie ilosci godzin w dniu, reszta z dzielenia to sekundy w godzinie
	mov   R_DIV_DIVIDEND_0, R_DIV_REMAINDER_0
	mov   R_DIV_DIVIDEND_1, R_DIV_REMAINDER_1
	mov   R_DIV_DIVIDEND_2, R_DIV_REMAINDER_2
	LDI_DIV_24  R_DIV_DIVISOR_2, R_DIV_DIVISOR_1, R_DIV_DIVISOR_0, 60 * 60
	DIV_U24
	sts   RTC_HOURS, R_DIV_RESULT_0

	; policzenie ilosci minut w godzinie, reszta z dzielenia to sekundy
	mov   R_DIV_DIVIDEND_0, R_DIV_REMAINDER_0
	mov   R_DIV_DIVIDEND_1, R_DIV_REMAINDER_1
	LDI_DIV_16 R_DIV_DIVISOR_1, R_DIV_DIVISOR_0, 60
	DIV_U16
	sts   RTC_MINUTES, R_DIV_RESULT_0
	
	; zapisanie sekund
	sts   RTC_SECONDS, R_DIV_REMAINDER_0

	; Dzien tygodnia, reszta z dzielenia (dni + 5) przez 7.
	; 1 stycznia 2000 roku to sobota
.ifdef RTC_DAY_OF_WEEK
	LDI_DIV_16 R_DIV_DIVIDEND_1, R_DIV_DIVIDEND_0, 5
	add   R_DIV_DIVIDEND_0, R_DAYS_0
	adc   R_DIV_DIVIDEND_1, R_DAYS_1
	LDI_DIV_16 R_DIV_DIVISOR_1, R_DIV_DIVISOR_0, 7
	DIV_U16
	sts   RTC_DAY_OF_WEEK, R_DIV_REMAINDER_0
.endif

	; Rok i Dzien w roku
	; ilosci dni do wyliczenia, 
	; Jezeli ilosc dni przekracza 28-lutego-2100 to ilosc dni ++
	LDI_DIV_16 R_DAYS_IN_YEAR_1, R_DAYS_IN_YEAR_0, (365 * 4 + 1) * 25 + 365
	cp    R_DAYS_IN_YEAR_0, R_DAYS_0
	cpc   R_DAYS_IN_YEAR_1, R_DAYS_1
	brsh  UNDER_2101
OVER_2101:
	; zwiekszenie dnia
	LDI_DIV_16 R_DAYS_IN_YEAR_1, R_DAYS_IN_YEAR_0, 1
	add   R_DAYS_0, R_DAYS_IN_YEAR_0
	adc   R_DAYS_1, R_DAYS_IN_YEAR_1
UNDER_2101:

	; policzenie ktora to grupa czterech lat 366 + 3 * 365
	mov   R_DIV_DIVIDEND_0, R_DAYS_0
	mov   R_DIV_DIVIDEND_1, R_DAYS_1
	LDI_DIV_16 R_DIV_DIVISOR_1, R_DIV_DIVISOR_0, 365 * 4 + 1
	DIV_U16
	mov   R_YEAR, R_DIV_RESULT_0
	lsl   R_YEAR
	lsl   R_YEAR
	; zapisanie ile dni pozostalo
	mov   R_DAYS_0, R_DIV_REMAINDER_0
	mov   R_DAYS_1, R_DIV_REMAINDER_1
	; w R_YEAR jest rok zaokraglony w dol do 4 lat,
	; obliczenie precyzyjnie roku i ilosci dni w roku
	LDI_DIV_16 R_DAYS_IN_YEAR_1, R_DAYS_IN_YEAR_0, 366
	; korekta ilosci dni dla roku 2100
	cpi   R_YEAR, 100
	brne  NOT_YEAR_2100
	ldi   R_DAYS_IN_YEAR_0, low(365)
NOT_YEAR_2100:
	; petla liczenia roku z pakietu czterech lat
YEAR_LOOP:
	; jezeli ilosc dni jaka zostala jest mniejsza od ilosci dni w roku
	; koniec liczenia
	cp    R_DAYS_0, R_DAYS_IN_YEAR_0
	cpc   R_DAYS_1, R_DAYS_IN_YEAR_1
	brlo  YEAR_LOOP_EXIT	
	; kolejny rok
	inc R_YEAR
	; minus dzni z roku
	sub   R_DAYS_0, R_DAYS_IN_YEAR_0
	sbc   R_DAYS_1, R_DAYS_IN_YEAR_1
	; dni na kolejny rok
	ldi   R_DAYS_IN_YEAR_0, low(365)
	rjmp  YEAR_LOOP
YEAR_LOOP_EXIT:

	; sprawdzenie czy rok przestepny
	mov   R_YEAR_PRZESTEPNY, R_DAYS_IN_YEAR_0
	subi  R_YEAR_PRZESTEPNY, low(365)

	; zapisanie roku
	sts RTC_YEAR, R_YEAR
	; zapisanie dnia w roku
.ifdef RTC_DAY_OF_YEAR
	sts RTC_DAY_OF_YEAR_L, R_DAYS_0
	sts RTC_DAY_OF_YEAR_H, R_DAYS_1
.endif

	; Miesiac i Dzien miesiaca.
	; zachowanie rejestru Z z nieuzywanych juz rejestrach R_STORE_Z
	; oszczedza to 2 bajty pamieci na stosie.
	; rejestr Z sluzy do pobierania dni tygodnia
	mov  R_STORE_ZL, ZL
	mov  R_STORE_ZH, ZH

	LDI_16 Z, RTC_DAYS_IN_MONTH * 2
	clr   R_MONTH
	clr   R_DAYS_IN_MONTH_1
MONTH_LOOP:
	; pobranie ilosci dni w miesiacu.
	lpm   R_DAYS_IN_MONTH_0, Z+
	; sprawdzenie czy luty i rok przestepny
	cpi   R_MONTH, 1
	brne  MONTH_LOOP_NO_29_DAYS
	; czy rok przestepny?
	tst   R_YEAR_PRZESTEPNY
	breq  MONTH_LOOP_NO_29_DAYS	
	; na 29 dni bo luty i rok przestepny
	inc   R_DAYS_IN_MONTH_0
MONTH_LOOP_NO_29_DAYS:
	; sprawdzenie czy ilosc jest mniejsza od ilosci dni w miesiacu
	cp    R_DAYS_0, R_DAYS_IN_MONTH_0
	cpc   R_DAYS_1, R_DAYS_IN_MONTH_1
	brlo  MONTH_LOOP_EXIT	
	; kolejny miesiac
	inc   R_MONTH
	; minus dzni z miesiaca
	sub   R_DAYS_0, R_DAYS_IN_MONTH_0
	sbc   R_DAYS_1, R_DAYS_IN_MONTH_1
	rjmp  MONTH_LOOP
MONTH_LOOP_EXIT:
	; zapis miesiaca i dnia miesiaca
	sts   RTC_MONTH, R_MONTH
	sts   RTC_DAY_OF_MONTH, R_DAYS_0

	; przywrocenie wartosci rejestru Z
	mov   ZL, R_STORE_ZL
	mov   ZH, R_STORE_ZH
		

RTC_TEST_END:

	pop   R_DIV_REMAINDER_3
	pop   R_DIV_REMAINDER_2
	pop   R_DIV_REMAINDER_1
	pop   R_DIV_REMAINDER_0
	pop   R_DIV_DIVISOR_3
	pop   R_DIV_DIVISOR_2
	pop   R_DIV_DIVISOR_1
	pop   R_DIV_DIVISOR_0
	pop   R_DIV_DIVIDEND_3
	pop   R_DIV_DIVIDEND_2
	pop   R_DIV_DIVIDEND_1
	pop   R_DIV_DIVIDEND_0
	
	ret

