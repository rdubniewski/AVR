/****************************************************************************
File:				Wait.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.01
Modified:			2013.02.01
****************************************************************************/

#ifndef _MATH_MUL_ASM_
#define _MATH_MUL_ASM_

.include "MathMul.inc"
;----------------------------------------------------------------------------
.ifndef MATH_MUL_FULL_SOFT
.set    MATH_MUL_FULL_SOFT              = 1
.endif
;----------------------------------------------------------------------------
;mnozenie U24 * U24
.ifdef  USE_MUL_U24_U24_F

.if MATH_MUL_FULL_SOFT != 0
.warning "Uzyto funkcji MUL_U24_U24_F w pelni programowej"

;----------------------------------------------------------------------------
MUL_U24_U24_F:
    push    R_MUL_TMP_0
    push    R_LOOP

    clr     r0
    clr     r1
    clr     r2
    clr     R_MUL_TMP_0

    ldi     R_LOOP, 24

_MUL_U24_U24_LOOP:
_MUL_U24_U24_LOOP_SHIFT:
    lsl     r0
    rol     r1
    rol     r2
    rol     r3
    rol     r4
    rol     r5

    lsl     R_MUL_A_0
    rol     R_MUL_A_1
    rol     R_MUL_A_2
    brcc    _MUL_U24_U24_LOOP_END

_MUL_U24_U24_LOOP_ADD:
    inc     R_MUL_A_0
    add     r0, R_MUL_B_0
    adc     r1, R_MUL_B_1
    adc     r2, R_MUL_B_2
    adc     r3, R_MUL_TMP_0
    adc     r4, R_MUL_TMP_0
    adc     r5, R_MUL_TMP_0
    
_MUL_U24_U24_LOOP_END:
    dec     R_LOOP
    brne    _MUL_U24_U24_LOOP

    pop     R_LOOP
    pop     R_MUL_TMP_0

    ret
;----------------------------------------------------------------------------

.else
.warning "Uzyto funkcji MUL_U24_U24_F operujaca na instrukcji mul"

;----------------------------------------------------------------------------
MUL_U24_U24_F:
    
    push    R_MUL_TMP_0 ; tymczasowy dla bajtu 0 wyniku
    push    R_MUL_TMP_1 ; tymczasowy dla bajtu 1 wyniku
    
    eor     r2, r2
    eor     r3, r3
    movw    r4, r2
    
    mul     R_MUL_A_0, R_MUL_B_0
    movw    R_MUL_TMP_0, r0
    
    mul     R_MUL_A_1, R_MUL_B_0
    add     R_MUL_TMP_1, r0
    adc     r2, r1

    mul     R_MUL_A_2, R_MUL_B_0
    add     r2, r0
    adc     r3, r1
    
    mul     R_MUL_A_0, R_MUL_B_1
    add     R_MUL_TMP_1, r0
    adc     r2, r1
    adc     r3, r5 ; przepelnienie, r5 jest 0 do konca

    mul     R_MUL_A_1, R_MUL_B_1
    add     r2, r0
    adc     r3, r1
    adc     r4, r5 ; przepelnienie, r5 jest 0 do konca
    
    mul     R_MUL_A_2, R_MUL_B_1
    add     r3, r0
    adc     r4, r1    
    
    mul     R_MUL_A_0, R_MUL_B_2
    add     r2, r0
    adc     r3, r1
    adc     r4, r5 ; przepelnienie, r5 jest 0 do konca

    mul     R_MUL_A_1, R_MUL_B_2
    add     r3, r0
    adc     r4, r1
    adc     r5, r5 ; przepelnienie, r5 jest 0 do konca
    
    mul     R_MUL_A_2, R_MUL_B_2
    add     r4, r0
    adc     r5, r1    

    movw    r0, r4
    
    pop     R_MUL_TMP_1
    pop     R_MUL_TMP_0

    ret
;----------------------------------------------------------------------------

.endif

.endif
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;mnozenie U16 * U16
.ifdef  USE_MUL_U16_U16_F

.if MATH_MUL_FULL_SOFT != 0
.warning "Uzyto funkcji MUL_U16_U16_F w pelni programowej"

;----------------------------------------------------------------------------
MUL_U16_U16_F:
    push    R_MUL_TMP_0
    push    R_LOOP

    clr     r0
    clr     r1
    clr     R_MUL_TMP_0

    ldi     R_LOOP, 16

_MUL_U16_U16_LOOP:
_MUL_U16_U16_LOOP_SHIFT:
    lsl     r0
    rol     r1
    rol     r2
    rol     r3
    
    lsl     R_MUL_A_0
    rol     R_MUL_A_1
    brcc    _MUL_U16_U16_LOOP_END

_MUL_U16_U16_LOOP_ADD:
    inc     R_MUL_A_0
    add     r0, R_MUL_B_0
    adc     r1, R_MUL_B_1
    adc     r2, R_MUL_TMP_0
    adc     r3, R_MUL_TMP_0
    
_MUL_U16_U16_LOOP_END:
    dec     R_LOOP
    brne    _MUL_U16_U16_LOOP

    pop     R_LOOP
    pop     R_MUL_TMP_0

    ret
;----------------------------------------------------------------------------

.else
.warning "Uzyto funkcji MUL_U16_U16_F uperujaca na instrukcji mul"

;----------------------------------------------------------------------------
MUL_U16_U16_F:
    push    R_MUL_TMP_0 ; tymczasowy dla bajtu 0 wyniku
    push    R_MUL_TMP_1 ; tymczasowy dla bajtu 1 wyniku
    
    eor     r2, r2
    eor     r3, r3
    
    mul     R_MUL_A_0, R_MUL_B_0
    movw    R_MUL_TMP_0, r0
    
    mul     R_MUL_A_1, R_MUL_B_0
    add     R_MUL_TMP_1, r0
    adc     r2, r1
    
    mul     R_MUL_A_0, R_MUL_B_1
    add     R_MUL_TMP_1, r0
    adc     r2, r1
    adc     r3, r3 ; przepelnienie, przed suma r3 jest 0
    
    mul     R_MUL_A_1, R_MUL_B_1
    add     r2, r0
    adc     r3, r1

    movw    r0, R_MUL_TMP_0
    
    pop     R_MUL_TMP_1
    pop     R_MUL_TMP_0

    ret
;----------------------------------------------------------------------------

.endif

.endif
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------


#endif

