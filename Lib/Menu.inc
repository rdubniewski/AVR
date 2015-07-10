#ifndef _MENU_INC_
#define _MENU_INC_

/****************************************************************************
File:				Menu.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.18
Modified:			2013.03.18
****************************************************************************/

; pozycje funkcji w strukturze pozycji menu, zgodnie z nia w prohramie 
; g³ównym musi byæ definiowana struktura menu.
.equ    MENU_FUN_INIT_OFFSET            = 0
.equ    MENU_FUN_DOWN_OFFSET            = 1
.equ    MENU_FUN_UP_OFFSET              = 2
.equ    MENU_FUN_EXEC_OFFSET            = 3
.equ    MENU_FUN_DISPLAY_OFFSET         = 4
.equ    MENU_FUN_AFTER_DISPLAY_OFFSET   = 5
.equ    MENU_FUN_LABEL_OFFSET           = 6
.equ    MENU_LABEL_OFFSET               = 7

; znak oznajmiajacy nie wskazanie danej pozycji
.ifndef MENU_POSITION_NO_INDICATOR
.equ    MENU_POSITION_NO_INDICATOR      = ' '
.endif

; znak oznajmiajacy wskazanie na dana pozycje
.ifndef MENU_POSITION_INDICATOR
.equ    MENU_POSITION_INDICATOR         = '>'
.endif


#endif
