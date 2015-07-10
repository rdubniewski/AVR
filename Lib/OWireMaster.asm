#ifndef _OWIRE_MASTER_ASM_
#define _OWIRE_MASTER_ASM_

.include "OWireMaster.inc"
.include "OWire.asm"

.equ    OWIRE_MASTER_SLOT           = 80
.equ    OWIRE_MASTER_START          = 5
.equ    OWIRE_MASTER_READ_SAMPLE    = 10
.equ    OWIRE_MASTER_SEND_STOP      = 5


.ifndef OWIRE_ROM

.dseg
OWIRE_ROM: 
OWIRE_ROM_FAMILY_CODE:              .byte 1
OWIRE_ROM_ID:
OWIRE_ROM_ID_0:                     .byte 1
OWIRE_ROM_ID_1:                     .byte 1
OWIRE_ROM_ID_2:                     .byte 1
OWIRE_ROM_ID_3:                     .byte 1
OWIRE_ROM_ID_4:                     .byte 1
OWIRE_ROM_ID_5:                     .byte 1

.endif

.cseg

;----------------------------------------------------------------------------
; Inicjuje transmisje do czujnikow, wysyla RESET i czeka na PRESET
OWIRE_MASTER_DETECT_PRESENCE:
    ;OWIRE_DISABLE_INTERRUPTS r2

    OWIRE_MASTER_0

    ;rcall OWIRE_WAIT_480_MS
    WAIT_MICROSEC_OWIRE_MASTER  500

    OWIRE_MASTER_1

    ;rcall OWIRE_WAIT_70_MS
    WAIT_MICROSEC_OWIRE_MASTER  100

    ;
    ; dodac odczyt stanu portu
    ; kasowanie ustawianego bitu
    cbr     R_OWIRE_DATA, 0x80
    sbic    OWIRE_MASTER_PIN, OWIRE_MASTER_BIT
    sbr     R_OWIRE_DATA, 0x80

    ;rcall OWIRE_WAIT_410_MS
    WAIT_MICROSEC_OWIRE_MASTER  400

    ;OWIRE_RESTORE_INTERRUPTS r2

    ret 
;----------------------------------------------------------------------------
.ifndef OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS
    .equ    OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS   = 0
.endif



OWIRE_MASTER_SEARCH_ROM:

.if OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS == 0
    push    R_LOOP
    push    R_OWIRE_MASTER_STACK
    push    R_OWIRE_MASTER_STACK_PTR
    push    R_OWIRE_MASTER_STACK_PTR_MAX
.endif
    
    ; inicjowanie wstepne
    clr     R_OWIRE_MASTER_STACK
    eor     R_OWIRE_MASTER_STACK_PTR_MAX, R_OWIRE_MASTER_STACK_PTR_MAX
        
; Petla odczytu wszystkich urzadzen na magistrali
_OSR_LOOP_ROMS:

    ; zainicjowanie szukania dla pojedynczego urzadzenia
    push    R_OWIRE_MASTER_POINTER_L
    push    R_OWIRE_MASTER_POINTER_H

    ldi     R_OWIRE_MASTER_POINTER_L, low(OWIRE_ROM)
    ldi     R_OWIRE_MASTER_POINTER_H, high(OWIRE_ROM)

    clr     R_OWIRE_CRC
    eor     R_OWIRE_MASTER_STACK_PTR, R_OWIRE_MASTER_STACK_PTR

    ; wyslanie polecenia SEARCH ROM
    rcall   OWIRE_MASTER_DETECT_PRESENCE	
    ldi     R_OWIRE_DATA, OWIRE_OP_SEARCH_ROM
    rcall   OWIRE_M_SEND_BYTE

    ldi     R_LOOP, 0

; Petla odczytu 64 bitow ROM z kolejnego urzadzenia
_OSR_LOOP_ONE_ROM:
    ; odczyt danych, pierwszy bit jest na pozycji 6 drugi na pozycji 7
    clr     R_OWIRE_DATA
    rcall   OWIRE_M_READ_BIT
    rcall   OWIRE_M_READ_BIT

    ; analiza co zostalo odczytane
    cpi     R_OWIRE_DATA, 0
    breq    _OSR_DISCREPANCY
    cpi     R_OWIRE_DATA, 1 << 7 | 1 << 6
    breq    _OSR_ERROR

    ; jest jednoznaczny bit
    rjmp    _OSR_SEND_BIT

_OSR_DISCREPANCY:
; obsluga sprzecznosci
    ; jezeli stos jest rowny stos_max to na stos 0
    cp      R_OWIRE_MASTER_STACK_PTR, R_OWIRE_MASTER_STACK_PTR_MAX
;;;;	breq  _OSR_DISCREPANCY_PUSH_0 
    brlo    _OSR_DISCREPANCY_POP

_OSR_DISCREPANCY_PUSH_0:
    ; jako pierwszy jest bit 0, i wrzucony na stos
    ; ustawienie wskazikow stosu
    lsl     R_OWIRE_MASTER_STACK_PTR
;;;;	tst   R_OWIRE_MASTER_STACK_PTR
    brne    _OSR_DISCREPANCY_PUSH_0_NO_INIT
;;;;	eor   R_OWIRE_MASTER_STACK_PTR, R_OWIRE_MASTER_STACK_PTR
    inc     R_OWIRE_MASTER_STACK_PTR
_OSR_DISCREPANCY_PUSH_0_NO_INIT:
    mov     R_OWIRE_MASTER_STACK_PTR_MAX, R_OWIRE_MASTER_STACK_PTR
    ; zapis do bitu wartosci 0
    com     R_OWIRE_MASTER_STACK_PTR
    and     R_OWIRE_MASTER_STACK, R_OWIRE_MASTER_STACK_PTR
    com     R_OWIRE_MASTER_STACK_PTR
    ; ustawienie do wyslania bitu 0
;;;;	clr   R_OWIRE_DATA

;;;;	mov   R_OWIRE_DATA, R_OWIRE_MASTER_STACK_PTR
;;;;	com   R_OWIRE_DATA
;;;;	and   R_OWIRE_MASTER_STACK, R_OWIRE_DATA
;;;;	; ustawienie do wyslania bitu 0
;;;;	clr   R_OWIRE_DATA
    ; w tym momencie R_OWIRE_DATA jest 0
    rjmp    _OSR_SEND_BIT 

_OSR_DISCREPANCY_POP:
    ; pobierany jest bit ze stosu i zwiekszany stos
    lsl     R_OWIRE_MASTER_STACK_PTR
    tst     R_OWIRE_MASTER_STACK_PTR
    brne    _OSR_DISCREPANCY_POP_NO_INIT
    eor     R_OWIRE_MASTER_STACK_PTR, R_OWIRE_MASTER_STACK_PTR
    inc     R_OWIRE_MASTER_STACK_PTR
_OSR_DISCREPANCY_POP_NO_INIT:

    mov     R_OWIRE_DATA, R_OWIRE_MASTER_STACK
    and     R_OWIRE_DATA, R_OWIRE_MASTER_STACK_PTR
    breq    _OSR_DISCREPANCY_POP_0
    ldi     R_OWIRE_DATA, 1 << 6
_OSR_DISCREPANCY_POP_0:
    rjmp    _OSR_SEND_BIT 

_OSR_SEND_BIT:
    ; wyslanie otrzymanego bitu 
    sbrs    R_OWIRE_DATA, 6
    rcall   OWIRE_M_SEND_BIT_0
    sbrc    R_OWIRE_DATA, 6
    rcall   OWIRE_M_SEND_BIT_1

    ; zachowanie bitu w biezacym bajcie
    ; caly bajt jest zapisywany do R_OWIRE_DATA
    bst     R_OWIRE_DATA, 6
    ld      R_OWIRE_DATA, R_OWIRE_MASTER_POINTER
    lsr     R_OWIRE_DATA
    bld     R_OWIRE_DATA, 7
    st      R_OWIRE_MASTER_POINTER, R_OWIRE_DATA

    inc     R_LOOP

    ; jezeli to jest ostatni bajt CRC to nie ma zapisu i koiniec petli
    cpi     R_LOOP, 64
    breq    _OSR_LOOP_EXIT

    ; jezeli zebralo sie 8 bitow to zapis bajtu
    mov     R_TMP_1, R_LOOP
    andi    R_TMP_1, 0x07
    brne    _OSR_LOOP_ONE_ROM
    ; kalkulacja CRC
    adiw    R_OWIRE_MASTER_POINTER, 1
    rcall   OWIRE_COMPUTE_CRC
/*
    ; zachowanie bitu w tymczasowym bajcie 1
    lsr   R_TMP_1
    sbrc  R_OWIRE_DATA, 6
    ori   R_TMP_1, 1 << 7

    inc   R_LOOP
    
    ; jezeli to jest ostatni bajt CRC to nie ma zapisu
    ; i koiniec petli
    cpi   R_LOOP, 64
    breq  _OSR_LOOP_EXIT
    
    ; jezeli zebralo sie 8 bitow to zapis bajtu
    mov   R_TMP_2, R_LOOP
    andi  R_TMP_2, 0x07
    brne  _OSR_LOOP_SKIP_STORE_BYTE
    ; Zapis bajtu do pamieci
    mov   R_OWIRE_DATA, R_TMP_1
    st    X+, R_OWIRE_DATA
    ; kalkulacja CRC
    rcall OWIRE_COMPUTE_CRC
*/
    
_OSR_LOOP_SKIP_STORE_BYTE:

    rjmp    _OSR_LOOP_ONE_ROM

_OSR_LOOP_EXIT:

    ; zostaly odczytane wszystkie 64 bity
    ; sprawdzenie czy CRC wyliczone jest zgodne z odebranym
    cp      R_OWIRE_CRC, R_OWIRE_DATA
    brne    _OSR_ERROR

    ; suma kontrolna sie zgadza
    ; Wywolanie funkcji powiadamiajacej o znalezionym urzadzeniu
    pop     R_OWIRE_MASTER_POINTER_H
    pop     R_OWIRE_MASTER_POINTER_L
    rcall   OWIRE_ROM_FOUND

    ; aktualizacja stau stosu
    ; usuniecie elementow stosu ktore maja ustawiona 1
_OSR_NO_STACK_POP_1:
    mov     R_OWIRE_DATA, R_OWIRE_MASTER_STACK
    and     R_OWIRE_DATA, R_OWIRE_MASTER_STACK_PTR
    breq    _OSR_NO_STACK_POP_1_EXIT
    ; zdjecie ze stosu 1
    lsr     R_OWIRE_MASTER_STACK_PTR
    mov     R_OWIRE_MASTER_STACK_PTR_MAX, R_OWIRE_MASTER_STACK_PTR
    rjmp    _OSR_NO_STACK_POP_1
_OSR_NO_STACK_POP_1_EXIT:
    
    ; jak ostatni element stosu jest 0 to zmiana na 1
    or      R_OWIRE_MASTER_STACK, R_OWIRE_MASTER_STACK_PTR

    ; jezeli zostaly znalezione wszystkie urzadzenia to koniec
    tst     R_OWIRE_MASTER_STACK_PTR_MAX
    breq    _OSR_END
    ;rjmp  _OSR_END

    ; sa jeszcze urzadzenia, ponowne szukanie
    rjmp    _OSR_LOOP_ROMS

_OSR_ERROR:
    pop     R_OWIRE_MASTER_POINTER_H
    pop     R_OWIRE_MASTER_POINTER_L
    
_OSR_END:

.if OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS == 0
    pop     R_OWIRE_MASTER_STACK_PTR_MAX
    pop     R_OWIRE_MASTER_STACK_PTR
    pop     R_OWIRE_MASTER_STACK
    pop     R_LOOP
.endif

    ret
;----------------------------------------------------------------------------
OWIRE_MASTER_SKIP_ROM:
    ldi     R_OWIRE_DATA, OWIRE_OP_SKIP_ROM
    rjmp    OWIRE_M_SEND_BYTE
;----------------------------------------------------------------------------
; Wysyla instrukcje OWIRE_OP_MATCH_ROM (0x55) a po niej 7 bajtow identyfikatora
; zapisanych w OWIRE_ROM: i na koniec CRC wyliczone z OWIRE_ROM
OWIRE_MASTER_MATCH_ROM:
    push    R_OWIRE_MASTER_POINTER_L
    push    R_OWIRE_MASTER_POINTER_H

    ldi     R_OWIRE_MASTER_POINTER_L, low(OWIRE_ROM)
    ldi     R_OWIRE_MASTER_POINTER_H, high(OWIRE_ROM)
    rcall   OWIRE_MASTER_MATCH_ROM_POINTER

    pop     R_OWIRE_MASTER_POINTER_H
    pop     R_OWIRE_MASTER_POINTER_L

    ret
;----------------------------------------------------------------------------
; Wysyla instrukcje OWIRE_OP_MATCH_ROM (0x55), po niej 1 bajt Famili Code
; z R_OWIRE_DATA nastêpnie 6 bajtów z rejestru X jako identyfikator 
; i na koniec CRC wyliczone z wyslanych bajtow
; 
;	                             !!!!! UWaga !!!!!
; Czesc czesc funkcji wysylajaca dane z rejestru X jest wspolna z funkcj¹
; OWIRE_MASTER_MATCH_ROM_POINTER
; na ktore wskazuje rejestr X: 
;
OWIRE_MASTER_MATCH_ROM_FC_ID_POINTER:
    push    R_LOOP ; licznik kolejnego bajtu

    ; przechowanie wartosci z R_OWIRE_DATA
    mov     R_LOOP, R_OWIRE_DATA

    ; instrukcja OP_MATCH_ROM (0x55)
    ldi     R_OWIRE_DATA, OWIRE_OP_MATCH_ROM
    rcall   OWIRE_M_SEND_BYTE

    ; Famili Code z R_OWIRE_DATA
    mov     R_OWIRE_DATA, R_LOOP
    ; wyslanie z liczeniem CRS
    clr     R_OWIRE_CRC
    rcall   OWIRE_M_SEND_BYTE_CRC

    ; wyslanie reszty danych
    ldi     R_LOOP, 6
    rjmp    _OMMR_OWIRE_SEND_DATA_POINTER
;----------------------------------------------------------------------------
; Wysyla instrukcje OWIRE_OP_MATCH_ROM (0x55) a po niej 7 bajtow identyfikatora
; na ktore wskazuje rejestr X: i na koniec CRC wyliczone z wyslanych bajtow
;
;                             !!!!! UWaga !!!!!
; Czesc czesc funkcji wysylajaca dane z rejestru X jest wspolna z funkcj¹
; OWIRE_MASTER_MATCH_ROM_POINTER
; na ktore wskazuje rejestr X:
;
OWIRE_MASTER_MATCH_ROM_POINTER:
    push    R_LOOP ; licznik kolejnego bajtu

    ; instrukcja OP_MATCH_ROM (0x55)
    ldi     R_OWIRE_DATA, OWIRE_OP_MATCH_ROM
    rcall   OWIRE_M_SEND_BYTE

    clr     R_OWIRE_CRC
    ldi     R_LOOP, 7

_OMMR_OWIRE_SEND_DATA_POINTER:

    ; po kolei 7 bajtow identyfikatora
_OMMR_OWIRE_DATA_LOOP:
    ld      R_OWIRE_DATA, X+

    ; Wyslanie z liczeniem CRC
    rcall OWIRE_M_SEND_BYTE_CRC

    dec     R_LOOP
    brne    _OMMR_OWIRE_DATA_LOOP
    ; koniec _OMR_OWIRE_DATA_LOOP

    ; wyslanie bajtu CRC
    mov     R_OWIRE_DATA, R_OWIRE_CRC
    rcall   OWIRE_M_SEND_BYTE

    pop     R_LOOP

    ret
;----------------------------------------------------------------------------
OWIRE_M_SEND_BYTE_CRC:
    rcall   OWIRE_COMPUTE_CRC

OWIRE_M_SEND_BYTE:
    push    R_LOOP

    ldi     R_LOOP, 8
_OMSB_LOOP:
    ; 0
    sbrs    R_OWIRE_DATA, 0
    rcall   OWIRE_M_SEND_BIT_0
    ; 1
    sbrc    R_OWIRE_DATA, 0
    rcall   OWIRE_M_SEND_BIT_1

    lsr     R_OWIRE_DATA

    dec     R_LOOP
    brne    _OMSB_LOOP

    pop     R_LOOP
    ret
;----------------------------------------------------------------------------
OWIRE_M_READ_BYTE:
    push    R_LOOP

    ldi     R_LOOP, 8
_OMRB_LOOP:
    ; odczyt bitu
    rcall   OWIRE_M_READ_BIT

    dec     R_LOOP
    brne    _OMRB_LOOP

    pop     R_LOOP

    ret
;----------------------------------------------------------------------------
OWIRE_M_READ_BYTE_CRC:
    rcall   OWIRE_M_READ_BYTE
    rcall   OWIRE_COMPUTE_CRC
    ret
;----------------------------------------------------------------------------
; Jezeli odczyta 0 to R_OWIRE_DATA bedzie mial 0, 
; jezeli odczyta 1 to R_OWIRE_DATA bedzie 0x80.
; Bity od 0-6 pozostaja niezmienione
OWIRE_M_READ_BIT:
    ; odczyt bitu
    OWIRE_DISABLE_INTERRUPTS r2

    ; inicjowanie pobierania danych
    OWIRE_MASTER_0

    WAIT_MICROSEC_OWIRE_MASTER  OWIRE_MASTER_START

    OWIRE_MASTER_1

    WAIT_MICROSEC_OWIRE_MASTER  OWIRE_MASTER_READ_SAMPLE - OWIRE_MASTER_START

    ; odczyt stanu pinu
    lsr     R_OWIRE_DATA
    sbic    OWIRE_MASTER_PIN, OWIRE_MASTER_BIT
    sbr     R_OWIRE_DATA, 0x80

    OWIRE_RESTORE_INTERRUPTS    r2

    WAIT_MICROSEC_MINUS_TICKS_OWIRE_MASTER  \
        OWIRE_MASTER_SLOT - OWIRE_MASTER_READ_SAMPLE - OWIRE_MASTER_START, 4 + 2

    ret
;----------------------------------------------------------------------------
OWIRE_M_SEND_BIT_0:
    OWIRE_DISABLE_INTERRUPTS r2

    OWIRE_MASTER_0
    WAIT_MICROSEC_OWIRE_MASTER  OWIRE_MASTER_SLOT
    OWIRE_MASTER_1

    OWIRE_RESTORE_INTERRUPTS r2

    WAIT_MICROSEC_OWIRE_MASTER  OWIRE_MASTER_SEND_STOP

    ret
;----------------------------------------------------------------------------
OWIRE_M_SEND_BIT_1:
    OWIRE_DISABLE_INTERRUPTS r2

    OWIRE_MASTER_0
    WAIT_MICROSEC_OWIRE_MASTER  OWIRE_MASTER_START
    OWIRE_MASTER_1

    OWIRE_RESTORE_INTERRUPTS r2

    WAIT_MICROSEC_MINUS_TICKS_OWIRE_MASTER  OWIRE_MASTER_SLOT - OWIRE_MASTER_START, 4

    ret
;----------------------------------------------------------------------------

#endif
