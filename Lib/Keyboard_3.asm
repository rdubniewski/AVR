/****************************************************************************
File:				Keyboard_3.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.07.23
Modified:			2013.07.23

Obs³uga klawiatury +,-,Menu wspó³pracuj¹cej z modu³em "Menu.asm"
****************************************************************************/

.include "Keyboard_3.inc"


.ifdef KEYBOARD_REPEAT_SPEED
.if( KEYBOARD_REPEAT_SPEED >= KEYBOARD_PRESS_COUNTER_START_REPEAT )
    .error "KEYBOARD_PRESS_REPEAT_COUNT >= KEYBOARD_PRESS_COUNTER_ENTER_REPEAT"
.endif
.endif


.dseg

KEYBOARD_STATE:                             .byte   1
KEYBOARD_PRESS_COUNTER:                     .byte   1

.ifdef KEYBOARD_REPEAT_SPEED_IN_MEMORY
.if KEYBOARD_REPEAT_SPEED_IN_MEMORY != 0
    KEYBOARD_REPEAT_SPEED_VAR:              .byte   1    
    ; sa parametry powtarzania
    .set    KEYBOARD_REPEAT_ENABLED         = 1    
.endif
.endif


.ifdef KEYBOARD_REPEAT_SPEED  
    ; sa parametry powtarzania
    .set    KEYBOARD_REPEAT_ENABLED         = 1    
.endif

    

.cseg
;----------------------------------------------------------------------------
KEYBOARD_CHECK:
	; detekcja przyciskow w R_TMP_1
    lds     R_TMP_1, KEYBOARD_STATE
    ; zapamietanie aktualnego stanu	
    swap    R_TMP_1
    andi    R_TMP_1, 0xF0
	; ustawienie flag stanu przyciskow
    sbis    BUTTON_MENU_PIN, BUTTON_MENU_BIT
	sbr     R_TMP_1, 1 << KEYBOARD_STATE_MENU_BIT

	sbis    BUTTON_DOWN_PIN, BUTTON_DOWN_BIT
	sbr     R_TMP_1, 1 << KEYBOARD_STATE_DOWN_BIT
    
    sbis    BUTTON_UP_PIN, BUTTON_UP_BIT
	sbr     R_TMP_1, 1 << KEYBOARD_STATE_UP_BIT
    ; zachowanie stanu przyciskow wraz ze stanem poprzednim
    sts     KEYBOARD_STATE, R_TMP_1
	
	; sprawdzenie ile jest wcisnietych przyciskow, 
	; jezeli wiecej niz jeden to blad, resetowanie licznika przycisniecia
	; i zakonczenie sprawdzania.
	clr     R_TMP_2
	sbrc    R_TMP_1, KEYBOARD_STATE_MENU_BIT
	inc     R_TMP_2
	sbrc    R_TMP_1, KEYBOARD_STATE_DOWN_BIT
	inc     R_TMP_2
	sbrc    R_TMP_1, KEYBOARD_STATE_UP_BIT
	inc     R_TMP_2

	cpi     R_TMP_2, 1
	breq    _KC_ONE_BUTTON_PRESSED

	; jest nacisnietych wiele przycisków albo ¿aden
	; zerowanie licznika 
	clr     R_TMP_1
	sts     KEYBOARD_PRESS_COUNTER, R_TMP_1
	; i koniec sprawdzania
	rjmp    _KC_END

_KC_ONE_BUTTON_PRESSED:

	; wlaczenie wyswietlacza
	rcall   DISPLAY_ON

	; sprawdzenie czy menu jest wlaczone, 
	; jak jest wlaczone to nie ma co sprawdzac dalej
	sbrc    R_CONTROL, R_CONTROL_MENU_BIT
	rjmp    _KC_MENU_IS_ACTIVE
		
	; sprawdzenie czy przycisk MENU jest nacisniety
	lds     R_TMP_1, KEYBOARD_STATE
    sbrs    R_TMP_1, KEYBOARD_STATE_MENU_BIT
	rjmp    _KC_NO_BUTTON_MENU
	
    ; Menu nieaktywne
	; przycisk menu jest nacisniety,
	; sprawdzenie czy przycisk byl nacisniety dostatecznie dlugo
	; by wlaczyc menu
	lds     R_TMP_1, KEYBOARD_PRESS_COUNTER
	cpi     R_TMP_1, KEYBOARD_PRESS_COUNTER_MENU
	brlo    _KC_NO_ACTIVATE_MENU
	
_KC_ACTIVATE_MENU:
    ; licznik nacisniecia osiagn¹³ wystarczajac¹ wartoœæ, w³¹czenie trybu MENU	
    rcall   MENU_ACTIVATE
    rjmp    _KC_END
    
_KC_NO_ACTIVATE_MENU:
	; inkrementacja licznika czasu nacisniecia przycisku,
    rcall   KEYBOARD_INCREMENT_PRESS_COUNTER
    rjmp    _KC_END
	
_KC_MENU_IS_ACTIVE:

; obsluga przycisku MENU
	lds     R_TMP_1, KEYBOARD_STATE
	sbrs    R_TMP_1, KEYBOARD_STATE_MENU_PREV_BIT
	sbrs    R_TMP_1, KEYBOARD_STATE_MENU_BIT
	rjmp    _KC_NO_BUTTON_MENU
	
	; Edycja pozycji menu
	rcall   MENU_EDIT_ITEM
    rjmp    _KC_END

_KC_NO_BUTTON_MENU:


; Jest nacisniety UP albo DOWM 
; (ktorys musi byc jezeli tu wszedl bo przycisk MENU nie jest wcisniety)
; obsluga powielenia przy dlugim nacisnieciu
	rcall   KEYBOARD_INCREMENT_PRESS_COUNTER
	
    ; POWTARZANIE PRZYCISKU
.ifdef KEYBOARD_REPEAT_ENABLED
    clr     R_TMP_2
	lds     R_TMP_1, KEYBOARD_PRESS_COUNTER
	cpi     R_TMP_1, KEYBOARD_PRESS_COUNTER_START_REPEAT
	brlo    _KC_NO_REPEAT_BUTTON
	; wartosc wystarczajaca do powtorzenia
	; ustawienie licznika na kolejne liczenie, krotsze.

.ifdef  KEYBOARD_REPEAT_SPEED_VAR
    ; wartosc licznika dla powtarzania okreslana jest przez zmienna
    ldi     R_TMP_1, KEYBOARD_PRESS_COUNTER_START_REPEAT
    lds     R_TMP_2, KEYBOARD_REPEAT_SPEED_VAR
    sub     R_TMP_1, R_TMP_2
.else
    ; wartosc powtarzania jest stala
	ldi     R_TMP_1, KEYBOARD_PRESS_COUNTER_START_REPEAT - KEYBOARD_REPEAT_SPEED
.endif
	sts     KEYBOARD_PRESS_COUNTER, R_TMP_1
	; ustawione bity w R_TMP_2 oznaczaja ze przycisk zostal powtorzony w.
	; R_TMP_2 nie jest miedzyczasie modyfikowany !!!
	ldi     R_TMP_2, 0xFF    
_KC_NO_REPEAT_BUTTON:
.endif
	
; obsluga przycisku UP
	lds     R_TMP_1, KEYBOARD_STATE
	; gdy jest powtorzenie to pomijane jest sprawdzanie czy przycisk 
	; byl zwolniony, ustawione bity w R_TMP_2 oznaczaja powtarzanie
.ifdef KEYBOARD_REPEAT_ENABLED
	sbrs    R_TMP_2, 1
.endif
	sbrs    R_TMP_1, KEYBOARD_STATE_UP_PREV_BIT
	sbrs    R_TMP_1, KEYBOARD_STATE_UP_BIT
	rjmp    _KC_NO_BUTTON_UP

_KC_BUTTON_UP:

	; przycisk nacisniety, zaleznie od trybu pracy:
    ; Zwyczajnie bez aktywnego menu, zmiana pozycji menu albo wartosci menu
	; Zwykle nacisniecie bez aktywnego menu
    sbrs    R_CONTROL, R_CONTROL_MENU_BIT
.ifdef BUTTON_UP_PRESSED    
    rjmp    _KC_BUTTON_UP_NORMAL
.else
    rjmp    _KC_END
.endif
    
    sbrc    R_CONTROL, R_CONTROL_MENU_EDIT_ITEM_BIT
	rjmp    _KC_BUTTON_UP_MENU_VAL

_KC_BUTTON_UP_MENU_ITEM:
    ; zmiana pozycji menu
    rcall   MENU_NEXT_VISIBLE_ITEM
    rjmp    _KC_END	

_KC_BUTTON_UP_MENU_VAL:
	; zmiana wartosci menu
	rcall   MENU_ITEM_UP
    rjmp    _KC_END
    
    ; nacisniecie przycisku bez aktywnego menu
.ifdef BUTTON_UP_PRESSED    
_KC_BUTTON_UP_NORMAL:
    rcall   BUTTON_UP_PRESSED
    rjmp    _KC_END
.endif
    
_KC_NO_BUTTON_UP:

; obsluga przycisku DOWN
	lds     R_TMP_1, KEYBOARD_STATE
	; gdy jest powtorzenie to pomijane jest sprawdzanie czy przycisk 
	; byl zwolniony, ustawione bity w R_TMP_2 oznaczaja powtarzanie
.ifdef KEYBOARD_REPEAT_ENABLED
	sbrs    R_TMP_2, 1
.endif
	sbrs    R_TMP_1, KEYBOARD_STATE_DOWN_PREV_BIT
	sbrs    R_TMP_1, KEYBOARD_STATE_DOWN_BIT
    rjmp    _KC_NO_BUTTON_DOWN
	
    ; przycisk nacisniety, zaleznie od trybu pracy:
    ; Zwyczajnie bez aktywnego menu, zmiana pozycji menu albo wartosci menu
	; Zwykle nacisniecie bez aktywnego menu
    sbrs    R_CONTROL, R_CONTROL_MENU_BIT
.ifdef BUTTON_DOWN_PRESSED    
    rjmp    _KC_BUTTON_DOWN_NORMAL
.else
    rjmp    _KC_END
.endif
    
    sbrc    R_CONTROL, R_CONTROL_MENU_EDIT_ITEM_BIT
	rjmp    _KC_BUTTON_DOWN_MENU_VAL
	
_KC_BUTTON_DOWN_MENU_ITEM:
    ; zmiana pozycji menu
    rcall   MENU_PREV_VISIBLE_ITEM
    rjmp    _KC_END	

_KC_BUTTON_DOWN_MENU_VAL:
	; zmiana wartosci menu
    rcall   MENU_ITEM_DOWN	
    rjmp    _KC_END
    
.ifdef BUTTON_DOWN_PRESSED
_KC_BUTTON_DOWN_NORMAL:
    ; nacisniecie przycisku bez aktywnego menu
    rcall   BUTTON_DOWN_PRESSED
    rjmp    _KC_END
.endif

_KC_NO_BUTTON_DOWN:

_KC_END:
	
	ret
;----------------------------------------------------------------------------
; Przestawia SREG-Z by wskazywala czy jest wcisniety jakikolwiek przycisk:
; kasuje bit gdy jest jakikolwiek przycisk,
; ustawia gdy zaden nie jest wcisniety.
KEYBOARD_ANY_KEY_PRESSED:
    lds     R_TMP_1, KEYBOARD_STATE
    andi    R_TMP_1, KEYBOARD_STATE_CURRENT_MASK
    ret
;----------------------------------------------------------------------------
; Inkrementuje , BUTTON_PRESS_COUNTER jezeli ten jest mniejszy od 255
KEYBOARD_INCREMENT_PRESS_COUNTER:
	lds     R_TMP_1, KEYBOARD_PRESS_COUNTER
	cpi     R_TMP_1, 255
	breq    _KSIPC_NO_INCREMENT
	; inkrementacja
    inc     R_TMP_1
    sts     KEYBOARD_PRESS_COUNTER, R_TMP_1
_KSIPC_NO_INCREMENT:
	ret
;----------------------------------------------------------------------------
; ustawia 0 w BUTTON_PRESS_COUNTER
RESET_BUTTON_PRESS_COUNTER:
	ldi     R_TMP_1, 0
	sts     KEYBOARD_PRESS_COUNTER, R_TMP_1
	ret
