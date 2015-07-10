/****************************************************************************
File:				BCD.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.10.29
Modified:			2013.10.29
****************************************************************************/

#ifndef _BCD_INC_
#define _BCD_INC_

.set    USE_U8_TO_BCD_X_F               = 0
.set    USE_U16_TO_BCD_X_F              = 0
.set    USE_U24_TO_BCD_X_F              = 0
.set    USE_U32_TO_BCD_X_F              = 0


.macro  U8_TO_BCD_X
    .set    USE_U8_TO_BCD_X_F           = 1
    rcall   U8_TO_BCD_X_F
.endmacro

.macro  U16_TO_BCD_X
    .set    USE_U16_TO_BCD_X_F          = 1
    rcall   U16_TO_BCD_X_F
.endmacro

.macro  U24_TO_BCD_X
    .set    USE_U24_TO_BCD_X_F          = 1
    rcall   U24_TO_BCD_X_F
.endmacro

.macro  U32_TO_BCD_X
    .set    USE_U32_TO_BCD_X_F          = 1
    rcall   U32_TO_BCD_X_F
.endmacro


#endif
