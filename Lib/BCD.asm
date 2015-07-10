/****************************************************************************
File:				BCD.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.10.29
Modified:			2013.10.29
****************************************************************************/

#ifndef _BCD_ASM_
#define _BCD_ASM_

#define R_BCD_TMP     YH

.set    DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG    = 0

;----------------------------------------------------------------------------
; dodanie 3 gdy wieksze od 5        
.macro  UX_TO_BCD_CORRECT
    ; pobranie poczatkowego rejestru korekcji
    lpm     XL, Z+
    ; pominiecie gdy rejestr = 0
    tst     XL
    breq    _UX_TO_BCD_CORRECT_END

_UX_TO_BCD_CORRECT_LOOP:
    ld      R_BCD_TMP, -X
    subi    R_BCD_TMP, -3
    sbrc    R_BCD_TMP, 3
    st      X, R_BCD_TMP
    ld      R_BCD_TMP, X
    subi    R_BCD_TMP, -0x30
    sbrc    R_BCD_TMP, 7
    st      X, R_BCD_TMP
    
    cpi     XL, 2
    brne    _UX_TO_BCD_CORRECT_LOOP

_UX_TO_BCD_CORRECT_END:

.endmacro

;----------------------------------------------------------------------------
.if ( USE_U8_TO_BCD_X_F != 0 )
.set    DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG    = 8

U8_TO_BCD_X_F:
    push    R_BCD_0
    push    r2
    push    r3
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH
    
    eor     r2, r2
    eor     r3, r3

    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 8
    
    rjmp    _U8_TO_BCD_NO_CORRECT
    
_U8_TO_BCD_LOOP:
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
   
_U8_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo
    lsl     R_BCD_0
    rol     r2
    rol     r3
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U8_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL    
    st      X+, r2
    st      X+, r3
    st      X+, r4
    sbiw    X, 3
    
    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r3
    pop     r2
    pop     R_BCD_0

    ret

.endif
;----------------------------------------------------------------------------
.if ( USE_U16_TO_BCD_X_F != 0 )
.set    DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG    = 16

U16_TO_BCD_X_F:
    push    R_BCD_0
    push    R_BCD_1
    push    r2
    push    r3
    push    r4
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH
    
    eor     r2, r2
    eor     r3, r3
    eor     r4, r4

    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 16
    
    rjmp    _U16_TO_BCD_NO_CORRECT
    
_U16_TO_BCD_LOOP:
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
   
_U16_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo
    lsl     R_BCD_0
    rol     R_BCD_1    
    rol     r2
    rol     r3
    rol     r4
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U16_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL    
    st      X+, r2
    st      X+, r3
    st      X+, r4
    sbiw    X, 3
    
    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r4
    pop     r3
    pop     r2
    pop     R_BCD_1
    pop     R_BCD_0

    ret

.endif
;----------------------------------------------------------------------------
.if ( USE_U24_TO_BCD_X_F != 0 )
.set    DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG    = 24

U24_TO_BCD_X_F:
    push    R_BCD_0
    push    R_BCD_1
    push    R_BCD_2
    push    r2
    push    r3
    push    r4
    push    r5
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH
    
    eor     r2, r2
    eor     r3, r3
    eor     r4, r4
    eor     r5, r5
    
    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 24    
    rjmp    _U24_TO_BCD_NO_CORRECT
    
_U24_TO_BCD_LOOP:    
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
           
_U24_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo    
    lsl     R_BCD_0
    rol     R_BCD_1
    rol     R_BCD_2
    rol     r2
    rol     r3
    rol     r4
    rol     r5
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U24_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL
    st      X+, r2
    st      X+, r3
    st      X+, r4
    st      X+, r5
    sbiw    X, 4

    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r5
    pop     r4
    pop     r3
    pop     r2
    pop     R_BCD_2
    pop     R_BCD_1
    pop     R_BCD_0

    ret

.endif
;----------------------------------------------------------------------------
.if ( USE_U32_TO_BCD_X_F != 0 )
.set    DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG    = 32

U32_TO_BCD_X_F:
    push    R_BCD_0
    push    R_BCD_1
    push    R_BCD_2
    push    R_BCD_3
    push    r2
    push    r3
    push    r4
    push    r5
    push    r6
    push    R_BCD_TMP
    push    ZL
    push    ZH

    ; X chwilowo przechowuje wskazany rejestr korekty BCD
    push    XL
    push    XH    
    clr     XH   

    eor     r2, r2
    eor     r3, r3
    eor     r4, r4
    eor     r5, r5
    eor     r6, r6    

    ; Ustawienie Z by wskazywal na tablice rejestrow BCD wymagajacych korekty
    ldi     ZL, low(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)
    ldi     ZH, high(_BIN_TO_BCD_X_CORRECT_INIT_REG * 2)

    ldi     R_LOOP, 32
    rjmp    _U32_TO_BCD_NO_CORRECT
    
_U32_TO_BCD_LOOP:    
    ; dodanie 3 gdy wieksze od 5        
    UX_TO_BCD_CORRECT
           
_U32_TO_BCD_NO_CORRECT:

    ; przesuniecie w lewo    
    lsl     R_BCD_0
    rol     R_BCD_1
    rol     R_BCD_2
    rol     R_BCD_3
    rol     r2
    rol     r3
    rol     r4
    rol     r5
    rol     r6
    
    ; warunek glownej petli
    dec     R_LOOP
    brne    _U32_TO_BCD_LOOP
    
    ; zapisanie pod X
    pop     XH
    pop     XL
    st      X+, r2
    st      X+, r3
    st      X+, r4
    st      X+, r5
    st      X+, r6
    sbiw    X, 5

    pop     ZH
    pop     ZL
    pop     R_BCD_TMP
    pop     r6
    pop     r5
    pop     r4
    pop     r3
    pop     r2
    pop     R_BCD_3
    pop     R_BCD_2
    pop     R_BCD_1
    pop     R_BCD_0
    
    ret

.endif
;----------------------------------------------------------------------------
; wskazania na poczatkowy rejestr korekty BCD
_BIN_TO_BCD_X_CORRECT_INIT_REG:
.if (DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG >= 8 )
    .db 0, 0, 3, 3, 3, 3, 3, 3  
.endif
.if (DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG >= 16 )
    .db 4, 4, 4, 4, 4, 4, 4, 5
.endif
.if (DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG >= 24 )
    .db 5, 5, 5, 5, 5, 5, 6, 6
.endif
.if (DEFINE_BIN_TO_BCD_X_CORRECT_INIT_REG >= 32 )
    .db 6, 6, 6, 6, 7, 7, 7, 0
.endif
;----------------------------------------------------------------------------

#endif
