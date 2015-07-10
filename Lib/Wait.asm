/****************************************************************************
File:				Wait.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.01.07
Modified:			2014.03.24
****************************************************************************/

#ifndef _Wait_asm_
#define _Wait_asm_

.include    "Wait.inc"
;----------------------------------------------------------------------------
.ifdef  USE_WAIT_8_BITS

WAIT_8_BITS:
    subi    R_WAIT_0, 1
    brne    WAIT_8_BITS
    ret

.endif
;----------------------------------------------------------------------------
.ifdef  USE_WAIT_16_BITS

WAIT_16_BITS:
    subi    R_WAIT_0, 1
    sbci    R_WAIT_1, 0
    brne    WAIT_16_BITS
    ret

.endif
;----------------------------------------------------------------------------
.ifdef  USE_WAIT_24_BITS

WAIT_24_BITS:
    subi    R_WAIT_0, 1
	sbci    R_WAIT_1, 0
    sbci    R_WAIT_2, 0
	brne    WAIT_24_BITS
	ret

.endif
;----------------------------------------------------------------------------
.ifdef USE_WAIT_32_BITS

WAIT_32_BITS:
    subi    R_WAIT_0, 1
	sbci    R_WAIT_1, 0
    sbci    R_WAIT_2, 0
    sbci    R_WAIT_3, 0
    brne    WAIT_32_BITS
	ret

.endif

#endif
