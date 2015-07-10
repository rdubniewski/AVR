/****************************************************************************
File:				Wait.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.03.01
Modified:			2013.02.01
****************************************************************************/

.include "MathDiv.inc"
;----------------------------------------------------------------------------
;dzielenie uint8 / uint8
.ifdef USE_DIV_U8_F
.warning "Uzyto DIV_U8_F"
DIV_U8_F:
	push  R_LOOP
	sub   R_DIV_REMAINDER_0, R_DIV_REMAINDER_0
	LDI   R_LOOP, 8            ;ile bitow ma zmienna (licznik petli)

DIV_U8_1:                ;glowna petla obliczen
	LSL   R_DIV_DIVIDEND_0            ;przesuwanie dzielnej z reszt¹ (8bitow) w lewo
	ROL   R_DIV_REMAINDER_0
	SUB   R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;odejmowanie dzielnika od reszty
	BRCC  DIV_U8_2        ;czy reszta >= dzielnik

	ADD   R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;nie mo¿emy odjac, reszta jest mniejsza od dzielnika
														;przywroc wartosc reszty przez dodanie
	RJMP  DIV_U8_3

DIV_U8_2:                
	SBR   R_DIV_DIVIDEND_0, 1            ;poprawne odejmowanie, ustaw 1 w wyniku dzilenia

DIV_U8_3:
	DEC   R_LOOP            ;zmniejsz licznik petli
	BRNE  DIV_U8_1        ;czy to ostatnia petla obliczen?, nie na poczatek petli

	pop  R_LOOP
	ret                    ;powrot z procedury

.endif

;---------------------------------------------------------------------
;dzielenie uint16 / uint16
.ifdef USE_DIV_U16_F
.Warning "Uzyto DIV_U16_F"
DIV_U16_F:
	push  R_LOOP
	CLR   R_DIV_REMAINDER_0                ;zerowanie reszty
	sub   R_DIV_REMAINDER_1, R_DIV_REMAINDER_1
	LDI   R_LOOP, 16            ;ile bitow ma zmienna (licznik petli)

DIV_U16_1:                ;glowna petla obliczen
	LSL   R_DIV_DIVIDEND_0            ;przesuwanie dzielnej z reszt¹ (16bitow) w lewo
	ROL   R_DIV_DIVIDEND_1
	ROL   R_DIV_REMAINDER_0
	ROL   R_DIV_REMAINDER_1
	SUB   R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;odejmowanie dzielnika od reszty
	SBC   R_DIV_REMAINDER_1, R_DIV_DIVISOR_1
	BRCC  DIV_U16_2        ;czy reszta >= dzielnik

	ADD   R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;nie mo¿emy odjac, reszta jest mniejsza od dzielnika
	ADC   R_DIV_REMAINDER_1, R_DIV_DIVISOR_1            ;przywroc wartosc reszty przez dodanie
	RJMP  DIV_U16_3

DIV_U16_2:                
	SBR   R_DIV_DIVIDEND_0, 1            ;poprawne odejmowanie, ustaw 1 w wyniku dzilenia

DIV_U16_3:
	DEC   R_LOOP            ;zmniejsz licznik petli
	BRNE  DIV_U16_1        ;czy to ostatnia petla obliczen?, nie na poczatek petli

	;koniec obliczen, wynik w [r27,r26] reszta w [r1,r0]
	pop  R_LOOP
	ret                    ;powrot z procedury

.endif
;---------------------------------------------------------------------
;dzielenie uint24 / uint24
;---------------------------------------------------------------------
.ifdef USE_DIV_U24_F
.Warning "Uzyto DIV_U24_F"
DIV_U24_F:
	push R_LOOP
    CLR  R_DIV_REMAINDER_0                ;zerowanie reszty
    CLR  R_DIV_REMAINDER_1
	sub  R_DIV_REMAINDER_2, R_DIV_REMAINDER_2
    LDI  R_LOOP, 24            ;ile bitow ma zmienna (licznik petli)

DIV_U24_1:                ;glowna petla obliczen
    LSL  R_DIV_DIVIDEND_0            ;przesuwanie dzielnej z reszt¹ (24bity) w lewo
    ROL  R_DIV_DIVIDEND_1
	ROL  R_DIV_DIVIDEND_2
	ROL  R_DIV_REMAINDER_0
    ROL  R_DIV_REMAINDER_1
	ROL  R_DIV_REMAINDER_2
	SUB  R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;odejmowanie dzielnika od reszty
    SBC  R_DIV_REMAINDER_1, R_DIV_DIVISOR_1
	SBC  R_DIV_REMAINDER_2, R_DIV_DIVISOR_2
	BRCC DIV_U24_2        ;czy reszta >= dzielnik

    ADD  R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;nie mo¿emy odjac, reszta jest mniejsza od dzielnika
    ADC  R_DIV_REMAINDER_1, R_DIV_DIVISOR_1            ;przywroc wartosc reszty przez dodanie
	ADC  R_DIV_REMAINDER_2, R_DIV_DIVISOR_2
	RJMP DIV_U24_3

DIV_U24_2:                
    SBR  R_DIV_DIVIDEND_0, 1            ;poprawne odejmowanie, ustaw 1 w wyniku dzilenia

DIV_U24_3:
    DEC  R_LOOP            ;zmniejsz licznik petli
    BRNE DIV_U24_1        ;czy to ostatnia petla obliczen?, nie na poczatek petli

    ;koniec obliczen, wynik w [r27,r26] reszta w [r1,r0]
	pop R_LOOP
    ret                    ;powrot z procedury

.endif
;---------------------------------------------------------------------
;dzielenie uint24 / uint8
;---------------------------------------------------------------------
.ifdef USE_DIV_U24_U8_F
.Warning "Uzyto DIV_U24_U8_F"
DIV_U24_U8_F:
	push    R_LOOP
    push    R_DIV_DIVISOR_1

    clr     R_DIV_DIVISOR_1
    
    clr     R_DIV_REMAINDER_0                ;zerowanie reszty
    clr     R_DIV_REMAINDER_1
	sub     R_DIV_REMAINDER_2, R_DIV_REMAINDER_2
    ldi     R_LOOP, 8            ;ile bitow ma dzielnik (licznik petli)

DIV_U24_U8_1:                ;glowna petla obliczen
    LSL  R_DIV_DIVIDEND_0            ;przesuwanie dzielnej z reszt¹ (24bity) w lewo
    ROL  R_DIV_DIVIDEND_1
	ROL  R_DIV_DIVIDEND_2
	ROL  R_DIV_REMAINDER_0
    ROL  R_DIV_REMAINDER_1
	ROL  R_DIV_REMAINDER_2
	SUB  R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;odejmowanie dzielnika od reszty
    SBC  R_DIV_REMAINDER_1, R_DIV_DIVISOR_1
	SBC  R_DIV_REMAINDER_2, R_DIV_DIVISOR_1
	BRCC DIV_U24_U8_2        ;czy reszta >= dzielnik

    ADD  R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;nie mo¿emy odjac, reszta jest mniejsza od dzielnika
    ADC  R_DIV_REMAINDER_1, R_DIV_DIVISOR_1            ;przywroc wartosc reszty przez dodanie
	ADC  R_DIV_REMAINDER_2, R_DIV_DIVISOR_1
	RJMP DIV_U24_U8_3

DIV_U24_U8_2:                
    SBR  R_DIV_DIVIDEND_0, 1            ;poprawne odejmowanie, ustaw 1 w wyniku dzilenia

DIV_U24_U8_3:
    dec     R_LOOP            ;zmniejsz licznik petli
    brne    DIV_U24_U8_1        ;czy to ostatnia petla obliczen?, nie na poczatek petli

    ;koniec obliczen, wynik w [r27,r26] reszta w [r1,r0]
	pop     R_DIV_DIVISOR_1
    pop     R_LOOP
    ret                    ;powrot z procedury

.endif
;---------------------------------------------------------------------
;dzielenie uint32 / uint32
;---------------------------------------------------------------------
.ifdef USE_DIV_U32_F
.Warning "Uzyto DIV_U32_F"
DIV_U32_F:
	push R_LOOP
    CLR  R_DIV_REMAINDER_0                ;zerowanie reszty
    CLR  R_DIV_REMAINDER_1
	CLR  R_DIV_REMAINDER_2
	sub  R_DIV_REMAINDER_3, R_DIV_REMAINDER_3
    LDI  R_LOOP, 32            ;ile bitow ma zmienna (licznik petli)

DIV_U32_1:                ;glowna petla obliczen
    LSL  R_DIV_DIVIDEND_0            ;przesuwanie dzielnej z reszt¹ (32bity) w lewo
    ROL  R_DIV_DIVIDEND_1
	ROL  R_DIV_DIVIDEND_2
	ROL  R_DIV_DIVIDEND_3
    ROL  R_DIV_REMAINDER_0
    ROL  R_DIV_REMAINDER_1
	ROL  R_DIV_REMAINDER_2
	ROL  R_DIV_REMAINDER_3
    SUB  R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;odejmowanie dzielnika od reszty
    SBC  R_DIV_REMAINDER_1, R_DIV_DIVISOR_1
	SBC  R_DIV_REMAINDER_2, R_DIV_DIVISOR_2
	SBC  R_DIV_REMAINDER_3, R_DIV_DIVISOR_3
    BRCC DIV_U32_2        ;czy reszta >= dzielnik

    ADD  R_DIV_REMAINDER_0, R_DIV_DIVISOR_0            ;nie mo¿emy odjac, reszta jest mniejsza od dzielnika
    ADC  R_DIV_REMAINDER_1, R_DIV_DIVISOR_1            ;przywroc wartosc reszty przez dodanie
	ADC  R_DIV_REMAINDER_2, R_DIV_DIVISOR_2
	ADC  R_DIV_REMAINDER_3, R_DIV_DIVISOR_3
    RJMP DIV_U32_3

DIV_U32_2:                
    SBR  R_DIV_DIVIDEND_0, 1            ;poprawne odejmowanie, ustaw 1 w wyniku dzilenia

DIV_U32_3:
    DEC  R_LOOP            ;zmniejsz licznik petli
    BRNE DIV_U32_1        ;czy to ostatnia petla obliczen?, nie na poczatek petli

    ;koniec obliczen, wynik w [r27,r26] reszta w [r1,r0]
	pop R_LOOP
    ret                    ;powrot z procedury

.endif
;---------------------------------------------------------------------

