.include    "Wait_Tiny25_Timer1.inc"

WAIT_TINY25_TIMER1_WAIT_F:
    ; licznik
    ;ldi     R_TMP_1, 255 - WAIT_TIMER_TCNT1
    out     TCNT1, R_TMP_1
    ; preskaler
    ;ldi     R_TMP_2, WAIT_TIMER_TCCR1
    out     TCCR1, R_TMP_2
    ; poczekanie na koniec
    in      R_TMP_1, TIFR
    sbrs    R_TMP_1, TOV1
    rjmp    PC - 2
    ret
