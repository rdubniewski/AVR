/****************************************************************************
File:				Wait.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.01
Modified:			2013.02.01
****************************************************************************/

#ifndef _MATH_MUL_INC_
#define _MATH_MUL_INC_


; Argumenty mnozenia
/*
.def    R_MATH_A_0				        = r16
.def    R_MATH_A_1				        = r17
.def    R_MATH_A_2				        = r18
.def    R_MATH_A_3				        = r19

.def    R_MATH_B_0					    = r20
.def    R_MATH_B_1					    = r21
.def    R_MATH_B_2					    = r22
.def    R_MATH_B_3					    = r23
*/

; Wynik zawsze w rejestrach r0-rN
; rN - najstarszy rejestr wyniku, N = suma ilosci rejestrow argumentow R_MATH_A i R_MATH_B

; R_MUL_TMP
; Rejestr pomocniczy
; rejestry: (rN;r31>
; rN - najstarszy rejestr wyniku
; .def  R_MUL_TMP                       = r15

; R_LOOP
; Rejestr petli dla w pelni programowego mnozenia, bez uzycia instrukcji mul
; rejestry: <r16;r31>
; .def  R_LOOP                          = r24


.macro  MUL_U24_U24
	.set    USE_MUL_U24_U24_F = 1
    rcall   MUL_U24_U24_F
.endmacro

.macro  MUL_U16_U16
	.set    USE_MUL_U16_U16_F = 1
    rcall   MUL_U16_U16_F
.endmacro

#endif
