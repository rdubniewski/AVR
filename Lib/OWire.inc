#ifndef _OWIRE_INC_
#define _OWIRE_INC_

;----------------------------------------------------------------------------
.equ OWIRE_OP_MATCH_ROM		= 0x55
.equ OWIRE_OP_SKIP_ROM		= 0xCC
.equ OWIRE_OP_SEARCH_ROM	= 0xF0
;----------------------------------------------------------------------------
.macro OWIRE_DISABLE_INTERRUPTS
;	push @0
;	in @0, SREG
;	cli
.endmacro
;----------------------------------------------------------------------------
.macro OWIRE_RESTORE_INTERRUPTS
;	sbrc @0, SREG_I
;	sei
;	pop @0
.endmacro
;----------------------------------------------------------------------------
/*
.macro OWIRE_WAIT_6_MS
	rjmp _OW6M_1
_OW6M_1:	
	rjmp _OW6M_2
_OW6M_2:	
	rjmp _OW6M_3
_OW6M_3:	
.endmacro
*/

#endif
