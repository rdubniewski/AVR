#ifndef _WAIT_TINY25_TIMER0_
#define _WAIT_TINY25_TIMER0_


.macro   WAIT_TICKS_TINY25_TIMER0
.set     _WAIT_TINY25_TIMER0_TICKS_ = @0 - 14
    ; zatrzymanie timera
    ;out     TCCR0B, R_ZERO
    ; kasowanie flagi przepelnienia
    ldi     R_TMP_1, 1 << TOV0
    out     TIFR, R_TMP_1
.if     _WAIT_TINY25_TIMER0_TICKS_ < 1
    .set    _WAIT_TINY25_TIMER0_TCNT0_  = 0
    .set    _WAIT_TINY25_TIMER0_TCCR0_  = (1 << CS10) + 0
.elif   _WAIT_TINY25_TIMER0_TICKS_ < 0x00100
    .set    _WAIT_TINY25_TIMER0_TCNT0_  = _WAIT_TINY25_TIMER0_TICKS_ / 1
    .set    _WAIT_TINY25_TIMER0_TCCR0_  = (1 << CS10) + 0
.elif   _WAIT_TINY25_TIMER0_TICKS_ < 0x00800
    .set    _WAIT_TINY25_TIMER0_TCNT0_  = _WAIT_TINY25_TIMER0_TICKS_ / 0x008
    .set    _WAIT_TINY25_TIMER0_TCCR0_  = (1 << CS10) + 1
.elif   _WAIT_TINY25_TIMER0_TICKS_ < 0x04000
    .set    _WAIT_TINY25_TIMER0_TCNT0_  = _WAIT_TINY25_TIMER0_TICKS_ / 0x040
    .set    _WAIT_TINY25_TIMER0_TCCR0_  = (1 << CS10) + 2
.elif   _WAIT_TINY25_TIMER0_TICKS_ < 0x10000
    .set    _WAIT_TINY25_TIMER0_TCNT0_  = _WAIT_TINY25_TIMER0_TICKS_ / 0x100
    .set    _WAIT_TINY25_TIMER0_TCCR0_  = (1 << CS10) + 3
.elif   _WAIT_TINY25_TIMER0_TICKS_ < 0x40000
    .set    _WAIT_TINY25_TIMER0_TCNT0_  = _WAIT_TINY25_TIMER0_TICKS_ / 0x400
    .set    _WAIT_TINY25_TIMER0_TCCR0_  = (1 << CS10) + 4
.else
    .error "to many ticks"
.endif
    ; licznik
    ldi     R_TMP_1, 255 - _WAIT_TINY25_TIMER0_TCNT0_
;    out     TCNT0, R_TMP_1
    ; preskaler
    ldi     R_TMP_2, _WAIT_TINY25_TIMER0_TCCR0_
;    out     TCCR0B, R_TMP_2
    ; poczekanie na koniec
;    in      R_TMP_1, TIFR
;    sbrs    R_TMP_1, TOV0
;    rjmp    PC - 2
    rcall   WAIT_TINY25_TIMER0_WAIT_F
.endmacro

.macro  WAIT_MICROSEC_MINUS_TICKS_TINY25_TIMER0
    WAIT_TICKS_TINY25_TIMER0    (@0) * FREQUENCY / 1000000 - @1
.endmacro

.macro  WAIT_MICROSEC_TINY25_TIMER0
    WAIT_TICKS_TINY25_TIMER0    (@0) * FREQUENCY / 1000000
.endmacro


/*
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
*/

#endif
