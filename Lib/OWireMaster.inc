#ifndef _OWIRE_MASTER_INC_
#define _OWIRE_MASTER_INC_

; Rozmiar romu urz¹dzenia 1-Wir
.equ OWIRE_ROM_WITHOUT_CRC_SIZE	= 7

;****************************************************************************
;								Funkcje
;
; OWIRE_MASTER_DETECT_PRESENCE:
;   Inicjuje transmisje do czujnikow, wysyla RESET i czeka na PRESET
;
;
; OWIRE_MASTER_SEARCH_ROM:
;   Wyszukuje podpiete urzadzenie, odnalezione ROMy urzadzen zapisuje do
; pamieci RAM pod adresem OWIRE_ROM: Ze wzgledu ograniczenia zuzycia pamieci
; ROM funkcja jest wlaczana warunkowo definicja OWIRE_MASTER_SEARCH_ROM_USING
; .equ OWIRE_MASTER_SEARCH_ROM_USING = 1
;   Funkcja wymaga zdefiniowania zewnetrznej funkcji OWIRE_ROM_FOUND, ktora
; jest wywolywana gdy urzadzenie zostanie odnalezione a jego identyfikator
; zapisany w OWIRE_ROM
; Na kompilacje maja wplyw flagi:
; - OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS
; - OWIRE_MASTER_SEARCH_ROM_NO_STORE_R_POINTER
;
;
; OWIRE_MASTER_SKIP_ROM:
;   Wysyla polecenie pominiecia ROMu urzadzenia
;
;
; OWIRE_MASTER_MATCH_ROM:
;   Wysyla instrukcje OWIRE_OP_MATCH_ROM (0x55) a po niej 7 bajtow 
; identyfikatora zapisanych w OWIRE_ROM: 
; i na koniec CRC wyliczone z OWIRE_ROM.
;
;
; OWIRE_MASTER_MATCH_ROM_X:
;   Wysyla instrukcje OWIRE_OP_MATCH_ROM (0x55) a po niej 7 bajtow 
; identyfikatora na ktory wskazuje rejestr X 
; i na koniec CRC wyliczone z wyslanych bajtow.
;
;
;****************************************************************************
;                               !!! UWAGA !!!
;   Nastepuj¹ca funkcje: OWIRE_MASTER_MATCH_ROM, OWIRE_MASTER_SEARCH_ROM 
; uzywaja obszaru pamieci OWIRE_ROM:. 
;   OWIRE_ROM jest domyslnie przydzielany w OWireMaster.asm jednak moze byc 
; przydzielony w innym miejscu. Wowczas nalezy pamietaæ, ¿e przydzielony 
; obszar powinien mieæ minimum OWIRE_ROM_WITHOUT_CRC_SIZE bajtów
;****************************************************************************

;----------------------------------------------------------------------------
.macro OWIRE_MASTER_0
	sbi OWIRE_MASTER_DDR, OWIRE_MASTER_BIT
.endmacro
;----------------------------------------------------------------------------
.macro OWIRE_MASTER_1
	cbi OWIRE_MASTER_DDR, OWIRE_MASTER_BIT
.endmacro
;----------------------------------------------------------------------------

#endif
