/****************************************************************************
File:				Menu.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.15
Modified:			2013.03.15
****************************************************************************/

.include "Menu.inc"

;----------------------------------------------------------------------------
MENU_ACTIVATE:
    ; koniec jezeli menu jest aktywne
    sbrc    R_CONTROL, R_CONTROL_MENU_BIT
    ret

    ; wlaczenie menu
    sbr     R_CONTROL, 1 << R_CONTROL_MENU_BIT
	
    ; aktywowanie pozycji menu o indeksie 0
	ldi     R_TMP_1, 0xFF
	sts     MENU_INDEX, R_TMP_1
	rcall   MENU_NEXT_VISIBLE_ITEM
    
	ret
;----------------------------------------------------------------------------
MENU_EDIT_ITEM:
    push_16  Z

    ; ustawienie rejestru Z na strukture okreslona przez aktualna pozycje menu
	rcall   MENU_ITEM_INIT_Z
	adiw    ZL, MENU_FUN_EXEC_OFFSET * 2
	rcall   CALL_Z_ADDR
	
    rcall   MENU_DISPLAY
	
    pop_16  Z

    ret
;----------------------------------------------------------------------------
MENU_NEXT_VISIBLE_ITEM:
    PUSH_16 Z
    push    R_LOOP
    
_MNVI_LOOP:    
    ; przejscie na nastepna pozycje menu
    lds     R_TMP_1, MENU_INDEX
    inc     R_TMP_1
    ; powrot na pozycje 0 gdy indeks wyszedl za ostatnia pozycje
    cpi     R_TMP_1, MAIN_MENU_ITEM_COUNT
    brlo    _MNVI_NO_SET_INDEX_0
    ldi     R_TMP_1, 0
_MNVI_NO_SET_INDEX_0:
    sts     MENU_INDEX, R_TMP_1

	; ustawienie rejestru Z na strukture okreslona przez aktualna pozycje menu
	rcall   MENU_ITEM_INIT_Z
	adiw    Z, MENU_FUN_INIT_OFFSET * 2
	rcall   CALL_Z_ADDR
	
    ; sprawdzenie czy pozycja menu jest widoczna
    lds     R_TMP_1, MENU_CONTROL
    sbrc    R_TMP_1, MENU_CONTROL_VISIBLE_BIT
    rjmp    _MNVI_END_DISPLAY

    ; pozycja menu jest niewidoczna, kontynuacja szukania    
    dec     R_LOOP
    brne    _MNVI_LOOP

    ; nie znaleziono widocznej pozycji
    rjmp    _MPVI_END

_MNVI_END_DISPLAY:
    rcall MENU_DISPLAY

    pop     R_LOOP
	POP_16  Z

	ret
;----------------------------------------------------------------------------
MENU_PREV_VISIBLE_ITEM:
    PUSH_16 Z
    push    R_LOOP
    
_MPVI_LOOP:    
    ; przejscie na poprzednia pozycje menu
    lds     R_TMP_1, MENU_INDEX
    dec     R_TMP_1
    ; powrot na ostatni apozycje gdy indeks = 0xFF
    cpi     R_TMP_1, MAIN_MENU_ITEM_COUNT
    brlo    _MPVI_NO_SET_INDEX_MAX
    ldi     R_TMP_1, MAIN_MENU_ITEM_COUNT - 1
_MPVI_NO_SET_INDEX_MAX:
    sts     MENU_INDEX, R_TMP_1

	; ustawienie rejestru Z na strukture okreslona przez aktualna pozycje menu
	rcall   MENU_ITEM_INIT_Z
	adiw    Z, MENU_FUN_INIT_OFFSET * 2
	rcall   CALL_Z_ADDR
	
    ; sprawdzenie czy pozycja menu jest widoczna
    lds     R_TMP_1, MENU_CONTROL
    sbrc    R_TMP_1, MENU_CONTROL_VISIBLE_BIT
    rjmp    _MPVI_END_DISPLAY

    ; pozycja menu jest niewidoczna, kontynuacja szukania    
    dec     R_LOOP
    brne    _MPVI_LOOP
    ; nie znaleziono widocznej pozycji
    rjmp    _MPVI_END

_MPVI_END_DISPLAY:
    rcall MENU_DISPLAY

_MPVI_END:

    pop     R_LOOP
	POP_16  Z

	ret
;----------------------------------------------------------------------------
MENU_ITEM_UP:
    push_16  Z
    
    rcall   MENU_ITEM_INIT_Z
	adiw    Z, MENU_FUN_UP_OFFSET * 2
	rcall   CALL_Z_ADDR
	rcall   MENU_DISPLAY
	
    pop_16  Z

    ret
;----------------------------------------------------------------------------
MENU_ITEM_DOWN:
    push_16  Z
    
    rcall   MENU_ITEM_INIT_Z
	adiw    Z, MENU_FUN_DOWN_OFFSET * 2
	rcall   CALL_Z_ADDR
	rcall   MENU_DISPLAY
	
    pop_16  Z

    ret
;----------------------------------------------------------------------------
MENU_DISPLAY:
	push_16  Z
	
	; rejestr Z jest dodatkowo zapamietywany na stosie przed przed wywolaniem
	; funkcji menu i po wywolaniu przywracany
	
	; ustawienie rejestru Z na strukture okreslona przez aktualna pozycje menu
	rcall   MENU_ITEM_INIT_Z
		
	; wygaszenie kursora, mozliwe ze ktoras pozycja sobie wlaczyla
	ldi     R_HD44780_DATA, HD44780_DISPLAY | HD44780_D_DISPLAY_ON | \
	        HD44780_D_CURSOR_OFF
	rcall   HD44780_SEND_INSTRUCTION
	
	; wyswietlenie opisu pozycji.
	HD44780_16_SET_POS  0, 0
	; znacznik prezentacji wskazania
	ldi     R_HD44780_DATA, MENU_POSITION_NO_INDICATOR
	sbrs    R_CONTROL, R_CONTROL_MENU_EDIT_ITEM_BIT
	ldi     R_HD44780_DATA, MENU_POSITION_INDICATOR
	rcall   HD44780_WRITE_DATA 
	; wyswietlenie tekstu
	PUSH_16 Z
	adiw    Z, MENU_LABEL_OFFSET * 2
	rcall   HD44780_PRINT_CONST_STRING_Z_FUN
	POP_16  Z
	; wywolanie funkcji wyswietlajacej pozycje
	PUSH_16 Z
	adiw    ZL, MENU_FUN_LABEL_OFFSET * 2
	rcall   CALL_Z_ADDR
	POP_16  Z
	; zamazanie reszty spacjami
	rcall   DISPLAY_FILL_SPACE_TO_END

	; wyswietlenie wartosci
	HD44780_16_SET_POS  1, 0
	; wywolanie funkcji wyswietlajacej wartosc
	PUSH_16 Z
	adiw    Z, MENU_FUN_DISPLAY_OFFSET * 2
	rcall   CALL_Z_ADDR
	POP_16  Z

	; zakonczenie wyswietlania wartosci, zamazanie spacjami do konca
	adiw    Z, MENU_FUN_AFTER_DISPLAY_OFFSET * 2
	rcall   CALL_Z_ADDR
	
	POP_16 Z
	
	ret
;----------------------------------------------------------------------------
; Wyswietla wskaznik edycji wartosci
MENU_DISPLAY_INDICATOR:
    ldi     R_HD44780_DATA, MENU_POSITION_NO_INDICATOR
	sbrc    R_CONTROL, R_CONTROL_MENU_EDIT_ITEM_BIT
	ldi     R_HD44780_DATA, MENU_POSITION_INDICATOR
	rcall   HD44780_WRITE_DATA 
	
    ret
;----------------------------------------------------------------------------
; Wywoluje funkcje pod adresem zapisanym w miejscu wskazanym przez rejestr Z:
; Inaczej: Z wskazuje na adres pamieci, pod tym adresem jest adres 
; wywolywanej funkcji
CALL_Z_ADDR:
	lpm     R_TMP_1, Z+
	lpm     ZH, Z
	mov     ZL, R_TMP_1
	icall
	
	ret
;----------------------------------------------------------------------------
; Ustawia rejestr Z by wskazywal na strukture opisujaca pozycje menu
MENU_ITEM_INIT_Z:
	; pobranie adresu pozycji menu
	; adres pozycji 0
	LDI_16  Z, MAIN_MENU * 2
	; przesuniecie na aktualna pozycje (x 2, organizacja pamieci jest 2 bajtowa)
	lds     R_TMP_1, MENU_INDEX
	clr     R_TMP_2
	lsl     R_TMP_1 
	rol     R_TMP_2
	add     ZL, R_TMP_1
	adc     ZH, R_TMP_2
	; wpisanie adresu struktury menu z tabeli do rejestru Z
	lpm     R_TMP_1, Z+
	lpm     ZH, Z
	mov     ZL, R_TMP_1

	ret
;----------------------------------------------------------------------------
; Domyslna funkcja inicjujaca pozycje menu przed jego wyswietleniem
; Ustawia widocznosc pozycji bez flagi odswiezania w timerze.
MENU_ITEM_INIT:
    lds     R_TMP_1, MENU_CONTROL
    sbr     R_TMP_1, 1 << MENU_CONTROL_VISIBLE_BIT
    cbr     R_TMP_1, 1 << MENU_CONTROL_TIMER_REFRESH_BIT
    sts     MENU_CONTROL, R_TMP_1
    ret
;----------------------------------------------------------------------------
; Domyslna funkcja inicjujaca pozycje menu przed jego wyswietleniem
; Ustawia widocznosc pozycji i flage odswiezania w timerze.
MENU_ITEM_INIT_WITH_TIMER_REFRESH:
    lds     R_TMP_1, MENU_CONTROL
    sbr     R_TMP_1, 1 << MENU_CONTROL_VISIBLE_BIT | 1 << MENU_CONTROL_TIMER_REFRESH_BIT
    sts     MENU_CONTROL, R_TMP_1
    ret
;----------------------------------------------------------------------------
; przelacza pozycje menu pomiedzy edycja a prezentacja
MENU_ITEM_EXEC:
	ldi     R_TMP_1, 1 << R_CONTROL_MENU_EDIT_ITEM_BIT
	eor     R_CONTROL, R_TMP_1
	ret
;----------------------------------------------------------------------------
MENU_NONE:
	ret
