/****************************************************************************
File:				Keyboard_3.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.07.23
Modified:			2013.07.23

Obs³uga klawiatury +,-,Menu wspó³pracuj¹cej z modu³em "Menu.asm"
****************************************************************************/

#ifndef _Keyboard_3_inc_
#define _Keyboard_3_inc_

/******************************************************************************
Zmienne w pamieci:

KEYBOARD_STATE:
KEYBOARD_PRESS_COUNTER:
KEYBOARD_REPEAT_SPEED_VAR: 
    (opcjonalnie, dla KEYBOARD_REPEAT_SPEED_IN_MEMORY != 1)

*****************************************************************************
Funkcje:

    KEYBOARD_CHECK:
Bada stan przycisków i podejmuje odpowiednie akcje: obsluga menu albo prosta 
obs³uga przycisków -/+(zewnetrzne funkcje BUTTON_DOWN_PRESSED/BUTTON_UP_PRESSED)

    KEYBOARD_ANY_KEY_PRESSED:
Przestawia SREG-Z by wskazywala czy jest wcisniety jakikolwiek przycisk:
kasuje bit gdy jest jakikolwiek przycisk,
ustawia gdy zaden nie jest wcisniety.

*****************************************************************************
Makra:

    KEYBOARD_REPEAT_SPEED_SET(stala)
Zapisuje przekazana stala do zmiennej KEYBOARD_REPEAT_SPEED_VAR, 
uzywa rejestru R_TMP_1.

******************************************************************************/

; Flagi zmiennej stanu klawiatury KEYBOARD_STATE
.equ    KEYBOARD_STATE_MENU_BIT         = 0
.equ    KEYBOARD_STATE_DOWN_BIT         = 1
.equ    KEYBOARD_STATE_UP_BIT           = 2
.equ    KEYBOARD_STATE_MENU_PREV_BIT    = 4 + KEYBOARD_STATE_MENU_BIT
.equ    KEYBOARD_STATE_DOWN_PREV_BIT    = 4 + KEYBOARD_STATE_DOWN_BIT
.equ    KEYBOARD_STATE_UP_PREV_BIT      = 4 + KEYBOARD_STATE_UP_BIT

.equ    KEYBOARD_STATE_CURRENT_MASK     = 1 << KEYBOARD_STATE_MENU_BIT | \
                                          1 << KEYBOARD_STATE_DOWN_BIT | \
                                          1 << KEYBOARD_STATE_UP_BIT

.equ    KEYBOARD_STATE_PREV_MASK        = 1 << KEYBOARD_STATE_MENU_PREV_BIT | \
                                          1 << KEYBOARD_STATE_DOWN_PREV_BIT | \
                                          1 << KEYBOARD_STATE_UP_PREV_BIT



; Czas nacisniecia przycisku dla aktywowania MENU.
; Wartosc mierzona w KEYBOARD_CHECK_FREQUENCY
.ifndef KEYBOARD_PRESS_COUNTER_MENU
    .equ    KEYBOARD_PRESS_COUNTER_MENU             = KEYBOARD_CHECK_FREQUENCY * 3
    .warning "Ustawiono domyslny czas trzymania przycisku meny dla aktywowania menu - 3 sekundy" 
.endif


; Czas przy ktorym zacznie sie szybkie powtarzanie przy trzymaniu przycisku.
; Wartosc mierzona w KEYBOARD_CHECK_FREQUENCY
.ifndef KEYBOARD_PRESS_COUNTER_START_REPEAT
    .equ    KEYBOARD_PRESS_COUNTER_START_REPEAT     = KEYBOARD_CHECK_FREQUENCY * 1
    .warning "Ustawiono domyslny czas po jakim zacznie sie szybkie powtarzanie przycisku - 1 sekunda" 
.endif


; Zapisuje przekazana stala (0) do zmiennej KEYBOARD_REPEAT_SPEED_VAR, 
; uzywa rejestru R_TMP_1.
.macro KEYBOARD_REPEAT_SPEED_SET
    ldi     R_TMP_1, @0
    sts     KEYBOARD_REPEAT_SPEED_VAR, R_TMP_1
.endmacro


#endif
