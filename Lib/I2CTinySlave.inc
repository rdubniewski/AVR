/****************************************************************************
File:				I2CTinySlave.inc
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.10.10
Modified:			2013.10.10
****************************************************************************/
#ifndef _I2CTINYSLAVE_INC_
#define _I2CTINYSLAVE_INC_

/****************************************************************************
Wymagane definicje portow, na przykladzie Tiny25/45/85:

.equ    I2C_DDR         = DDRB
.equ    I2C_PORT        = PORTB
.equ    I2C_PIN         = PINB
.equ    I2C_SCL         = 2
.equ    I2C_SDA         = 0
*/



/****************************************************************************
R_I2C_TMP

Rejestr <r16;r31> wymagany do obslugi, np:
.def    R_I2C_TMP       = r16
*/



/****************************************************************************
R_I2C_FLAGS,
I2C_FLAGS

Bajt kontrolny, moze byc zdefiniowany jako rejestr, port lub komorka pamieci,
na przykladzie Tiny25/45/85:

1. jako rejestr <r16;r31>
.def    R_I2C_FLAGS     = r17

2. ogolny port dostepny w procesorze
.equ    I2C_FLAGS       = GPIOR0

3. w obszarze pamieci:
.dseg
I2C_FLAGS:          .byte 1
*/



/****************************************************************************
R_SREG_INTERRUPT_STORE

SREG domyslnie jest przechowywany na stosie 
ale moze tez byc przechowywany w przeznaczonym do tego rejestrze 
jezeli ten rejestr zostanie zdefiniowany, np:
.def    R_SREG_INTERRUPT_STORE          = r15
*/



/****************************************************************************
I2C_STORE_R_TMP

Okresla czy rejestr R_I2C_TMP bêdzie odk³adany na stos w trakcie przerwañ.
Wartosc rozna od 0 powoduje odk³adanie na stosie. Domyslnie przyjmowana
jest wartoœæ 1 odk³adaj¹ca na stos
*/



/****************************************************************************
I2C_START_STORE_SREG

Okresla czy porzy wywolaniu USI_I2C_START SREG bêdzie odk³adany na stos.
Wartosc rozna od 0 powoduje od³o¿enie SREG na stosie.
Domyœlnie przyjmowana jest wartosc 1
*/



/****************************************************************************
I2C_CHECK_SLAVE_ADDRESS

Makro  sprawdzajace czy odebrany adres jest wlasnym adresem.
po wykonaniu powinna byc ustawiona flagaflaga SREG-Z, 0 - poprawny, 1 - obcy
adres. 
Przyk³ad:
.macro I2C_CHECK_SLAVE_ADDRESS
    cpi     R_I2C_TMP, I2C_SLAVE_ADDRESS
.endmacro
*/



/****************************************************************************
I2C_RECV_BYTE

Makro wywolywane po przyjsciu bajtu od MASTER, bajt znajduje sie w porcie 
USIDR
Prayk³ad:
.macro  I2C_RECV_BYTE
    in      R_I2C_TMP, USIDR
    sts     BAJCIK_OD_MASTERA, R_I2C_TMP
.endmacro
*/



/****************************************************************************
I2C_SEND_BYTE

Makro wywolywane przed wyslaniem bajtu do MASTER, musi ustawic port USIDR.
Prayk³ad:
.macro  I2C_SEND_BYTE
    lds     R_I2C_TMP, BAJCIK_DLA_MASTERA
    out     USIDR, R_I2C_TMP
.endmacro
*/



/****************************************************************************
USI_I2C_INIT

Funkcja konfigurujaca IO do pracy jako I2C
*/



/****************************************************************************
USI_I2C_START

Funkcja obslugi przerwania poczatku nadawania, USI_STARTaddr.
Musi byc wywolana nastepujaco:
.org    USI_STARTaddr
    rjmp    I2C_START
*/



/****************************************************************************
I2C_START_BEGIN

Makro wstawiane na poczatku funkcji obslugi przerwania I2C_START,
po odlozeniu (ewentualnym) R_I2C_TMP na stos

*/



/****************************************************************************
I2C_START_END

Makro wstawiane na koncu funkcji obslugi przerwania I2C_START 
przed przywroceniem (ewentualnym) R_I2C_TMP se stosu

*/



/****************************************************************************
USI_I2C_OV

Funkcja obslugi przerwania zakonczenia nadawania lub odbioru kawalka danych
Musi byc wywolana nastepujaco:

.org    USI_OVFaddr
    rjmp    I2C_OV
*/



/****************************************************************************
I2C_OV_BEGIN

Makro wstawiane na poczatku funkcji obslugi przerwania I2C_OV,
po odlozeniu (ewentualnym) R_I2C_TMP na stos

*/



/****************************************************************************
I2C_OV_END

Makro wstawiane na koncu funkcji obslugi przerwania I2C_OV 
przed przywroceniem (ewentualnym) R_I2C_TMP se stosu

*/



#endif

