#ifndef _DefineIO_inc_
#define _DefineIO_inc_

/* Przypisuje nazwie wyjscie procesora dodaj¹c do nazwy odpowiednie
    przyrostki: _PIN, _PORT, _DDR, _BIT.
@0: Nazwa dla IO.
@1: Litera IO: A, B, C...
@1: Bit portu: <0;7> */
.macro  DEFINE_IO
    .equ @0_DDR      = DDR@1
    .equ @0_PORT     = PORT@1
    .equ @0_PIN      = PIN@1
    .equ @0_BIT      = @2
.endmacro

#endif
