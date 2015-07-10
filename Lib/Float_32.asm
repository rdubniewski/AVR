/****************************************************************************
File:				Wait.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2014.03.21
Modified:			2014.03.21
****************************************************************************/

#ifndef _FLOAT_32_ASM_
#define _FLOAT_32_ASM_

.include    "Float_32.inc"
.include    "MathMul.inc"

;----------------------------------------------------------------------------
; konwertuje int 16 do float 32
FLOAT_A_TO_INT16_F:
    ; zachowanie znaku - we fladze SREG-T
    bst     R_MATH_A_3, 7
    ; konwercja
    rcall   FLOAT_A_TO_UINT16_F
    ; zanegowanie int 16 fladze SREG-T
    brtc    PC + 3
    neg     R_MATH_A_1
    com     R_MATH_A_2

    ret
;----------------------------------------------------------------------------
; konwertujeR_FLOAT_A do unsigned 16,
; wejscie:R_FLOAT_A_[3..0]
; wyjscie:R_FLOAT_A_U16_[1..0] (FLOAT_A_[2..1])
FLOAT_A_TO_UINT16_F:
    rcall   FLOAT_32_PREPARE_TO_CALCULATE

    ; sparwdzenie 0
    tst     R_MATH_A_3
    breq    _FLOAT_A_TO_UINT16_F_0

    ; przesuniecie mantysy
    subi    R_MATH_A_3, 126 + 16
    breq    _FLOAT_A_TO_UINT16_F_LOOP_END
_FLOAT_A_TO_UINT16_F_LOOP:    
    lsr     R_MATH_A_2
    ror     R_MATH_A_1
    inc     R_MATH_A_3
    brne    _FLOAT_A_TO_UINT16_F_LOOP
_FLOAT_A_TO_UINT16_F_LOOP_END:
    ret

_FLOAT_A_TO_UINT16_F_0:
    clr     R_MATH_A_2
    eor     R_MATH_A_1, R_MATH_A_1 ; dla flag w SREG
    ret
;----------------------------------------------------------------------------
; konwertuje int 16 do float 32
INT16_TO_FLOAT_F:
    ; zachowanie znaku - we fladze SREG-T
    bst     R_MATH_A_2, 7
    ; wartosc bezwzgledna
    brtc    PC + 3
    neg     R_MATH_A_1
    com     R_MATH_A_2
    ; konwercja
    rcall   UINT16_TO_FLOAT_A_F
    ; ustawienie znaku
    bld     R_MATH_A_3, 7
    ret
;----------------------------------------------------------------------------
; konwertuje unsigned 16 do float 32
UINT16_TO_FLOAT_A_F:
    ; test na wertosc 0
    clr     R_MATH_A_0
    cp      R_MATH_A_1, R_MATH_A_0
    cpc     R_MATH_A_2, R_MATH_A_0
    breq    _FLOAT_32_SET_0_F1
    ; podstawowa wartosc wykladnika
    ldi     R_MATH_A_3, 126 + 16
    ; normalizacja mantysy i inkrementacja wykladnika
_U16TF_NORMALIZE:
    sbrc    R_MATH_A_2, 7
    rjmp    _U16TF_NORMALIZE_END
    lsl     R_MATH_A_1
    rol     R_MATH_A_2
    dec     R_MATH_A_3
    rjmp    _U16TF_NORMALIZE
_U16TF_NORMALIZE_END:
    ; przestawienie najmlodszego bitu wykladnika
    lsl     R_MATH_A_2
    lsr     R_MATH_A_3
    ror     R_MATH_A_2

    ret
;----------------------------------------------------------------------------
FLOAT_32_SET_0_F:
    clr     R_MATH_A_0
_FLOAT_32_SET_0_F1:
    clr     R_MATH_A_1
    clr     R_MATH_A_2
    clr     R_MATH_A_3
    ret
;----------------------------------------------------------------------------
; DodajeR_FLOAT_A_[3-0] iR_FLOAT_B_[3-0], wynik wR_FLOAT_A_[3-0]
ADD_FLOAT_32:
    FLOAT_32_PUSH   R_MATH_B
    push    R_MATH_A_3
    ; okreslenie dzialania, dodawanie/odejmowanie wg zaleznosci:
    ; +A  +B  ->  (+)
    ; +A  -B  ->  (-)
    ; -A  +B  ->  (-)
    ; -A  -B  ->  (+)
    ; rodzaj dzialania bedzie przechowany we fladze SREG-T
    eor     R_MATH_A_3, R_MATH_B_3
    bst     R_MATH_A_3, 7
    eor     R_MATH_A_3, R_MATH_B_3

    ; rozdzielenie wykladnika i mantysy
    rcall  FLOAT_32_PREPARE_TO_CALCULATE
        
    ; sprawdzenie ktory wykladnik ma wieksza wartosc
    cp      R_MATH_A_3, R_MATH_B_3
    brlo    _ADD_FLOAT_32_B_GROW

_ADD_FLOAT_32_A_GROW_EQUAL:
    sub     R_MATH_B_3, R_MATH_A_3
    breq    _ADD_FLOAT_32_CALCULATE

    ; A ma wiekszy wykladnik od B
_ADD_FLOAT_32_CORRECT_B_LOOP:
    lsr     R_MATH_B_2
    ror     R_MATH_B_1
    ror     R_MATH_B_0
    inc     R_MATH_B_3
    brne    _ADD_FLOAT_32_CORRECT_B_LOOP
    rjmp    _ADD_FLOAT_32_CALCULATE

    ; B ma wiekszy wykladnik od A
_ADD_FLOAT_32_B_GROW:
    sub     R_MATH_A_3, R_MATH_B_3
_ADD_FLOAT_32_CORRECT_A_LOOP:
    lsr     R_MATH_A_2
    ror     R_MATH_A_1
    ror     R_MATH_A_0
    inc     R_MATH_A_3
    brne    _ADD_FLOAT_32_CORRECT_A_LOOP

    ; sumowanie poprawionych mantys
_ADD_FLOAT_32_CALCULATE:
    brts    _ADD_FLOAT_32_SUB

_ADD_FLOAT_32_ADD:
    ; dodawanie
    adc     R_MATH_A_0, R_MATH_B_0
    adc     R_MATH_A_1, R_MATH_B_1
    adc     R_MATH_A_2, R_MATH_B_2
    ; normalizacja mantysy po przepelnieniu
    brcc    _ADD_FLOAT_32_ADD_NORMALIZE_END
    ror     R_MATH_A_2
    ror     R_MATH_A_1
    ror     R_MATH_A_0
    inc     R_MATH_A_3
_ADD_FLOAT_32_ADD_NORMALIZE_END:
    add     R_MATH_A_3, R_MATH_B_3
    rjmp    _ADD_FLOAT_32_CALCULATE_END

_ADD_FLOAT_32_SUB:
    ; odejmowanie 
    clt ; wstepne kasowaie SREG-T nie bedzie powodowalo zmiany znaku liczbt A
    sub     R_MATH_A_0, R_MATH_B_0
    sbc     R_MATH_A_1, R_MATH_B_1
    sbc     R_MATH_A_2, R_MATH_B_2
    ; przy wyniku 0 jest 0
    breq    FLOAT_32_SET_0_F
    ; przy ujemnym wyniku nalezy zanegowac wynik 
    ; i ustawic flage SREG-T odwracajaca znak liczby A
    brcc    _ADD_FLOAT_32_SUB_NO_NEGATIV
    ; dodatkowe odjecie 1
    clr     R_MATH_B_0
    sbc     R_MATH_A_0, R_MATH_B_0
    sbc     R_MATH_A_1, R_MATH_B_0
    sbc     R_MATH_A_2, R_MATH_B_0
    com     R_MATH_A_0
    com     R_MATH_A_1
    com     R_MATH_A_2
    set
_ADD_FLOAT_32_SUB_NO_NEGATIV:

    ; wykladnik
    add     R_MATH_A_3, R_MATH_B_3

    ; normalizacja mantysy po odejmowaniu
_ADD_FLOAT_32_SUB_NORMALIZE:
    sbrc    R_MATH_A_2, 7
    rjmp    _ADD_FLOAT_32_CALCULATE_END
    lsl     R_MATH_A_0
    rol     R_MATH_A_1
    rol     R_MATH_A_2
    bld     R_MATH_A_0, 0 ; przy odwracaniu znaku
    dec     R_MATH_A_3
    rjmp    _ADD_FLOAT_32_SUB_NORMALIZE

_ADD_FLOAT_32_CALCULATE_END:

    ; przesuniecie wykladnika o bit w prawo i przywrocenie znaku
    lsl     R_MATH_A_2
    ; ustawienie w SREG-C oryginalnego 
    pop     R_MATH_B_3
    lsl     R_MATH_B_3
    ; przesuniecie wykladnika w prawo o bit wraz ze znakiem
    ror     R_MATH_A_3
    ror     R_MATH_A_2

    ; zanegowanie znaku liczby A w zaleznosci od SREG-T
    clr     R_MATH_B_3
    bld     R_MATH_B_3, 7
    eor     R_MATH_A_3, R_MATH_B_3

    FLOAT_32_POP    R_MATH_B

    ret
;----------------------------------------------------------------------------
SUB_FLOAT_32:
    ; zanegowanie B
    push    R_MATH_B_2
    ldi     R_MATH_B_2, 0x80
    eor     R_MATH_B_3, R_MATH_B_2
    pop     R_MATH_B_2
    rcall   ADD_FLOAT_32
    ret
;----------------------------------------------------------------------------
; MnozyR_FLOAT_A_[3-0] iR_FLOAT_B_[3-0], wynik wR_FLOAT_A_[3-0]
MUL_FLOAT_32:
    FLOAT_32_PUSH   R_MATH_B
    push    r5
    push    r4
    push    r3
    push    r2
    push    r1
    push    r0

    ; okreslenie znaku wyniku we fladze SREG-T
    eor     R_MATH_A_3, R_MATH_B_3
    bst     R_MATH_A_3, 7
    eor     R_MATH_A_3, R_MATH_B_3

    ; rozdzielenie wykladnika i mantysy
    rcall   FLOAT_32_PREPARE_TO_CALCULATE

    ; mnozenie mantys
    MUL_U24_U24

    ; normalizacja obliczonej mantysy
    sbrc    r5, 7
    rjmp    _MUL_FLOAT_32_NORMALIZE_END
    lsl     r2
    rol     r3
    rol     r4
    rol     r5
    dec     R_MATH_A_3
_MUL_FLOAT_32_NORMALIZE_END:

    ; kopiowanie mantysy doR_FLOAT_A
    mov     R_MATH_A_0, r3
    mov     R_MATH_A_1, r4
    mov     R_MATH_A_2, r5

    ; sumowanie wykladnikow
    add     R_MATH_A_3, R_MATH_B_3
    subi    R_MATH_A_3, 126

    ; przesuniecie wykladnika na wlasiwa pozycje
    lsl     R_MATH_A_2
    lsr     R_MATH_A_3
    ror     R_MATH_A_2

    ; ustawienie znaku z flagi SREG-T
    bld     R_MATH_A_3, 7

    pop     r0
    pop     r1
    pop     r2
    pop     r3
    pop     r4
    pop     r5
    FLOAT_32_POP    R_MATH_B

    ret
;----------------------------------------------------------------------------
FLOAT_32_PREPARE_TO_CALCULATE:
    ; wydzielenie wykladnikow A do najstarszego bajtu 
    ; i ustawienie najstarszego bitu mantysy
    lsl     R_MATH_A_2
    rol     R_MATH_A_3
    sec
    ror     R_MATH_A_2
    ; wydzielenie wykladnikow b do najstarszego bajtu
    ; i ustawienie najstarszego bitu mantysy
    lsl     R_MATH_B_2
    rol     R_MATH_B_3
    sec
    ror     R_MATH_B_2

    ret    
;----------------------------------------------------------------------------
.include "MathMul.asm"

#endif
