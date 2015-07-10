.include    "Wait_Tiny25_Timer0.inc"

WAIT_TINY25_TIMER0_WAIT_F:
    ; licznik
    ;ldi     R_TMP_1, 255 - WAIT_TIMER_TCNT1
    out     TCNT0, R_TMP_1
    ; preskaler
    ;ldi     R_TMP_2, WAIT_TIMER_TCCR1
    out     TCCR0B, R_TMP_2
    ; poczekanie na koniec
    in      R_TMP_1, TIFR
    sbrs    R_TMP_1, TOV0
    rjmp    PC - 2
    ret
