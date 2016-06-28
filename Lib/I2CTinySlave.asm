/****************************************************************************
File:				I2CTinySlave.asm
Author:				Rafa³ Dubniewski
Verssion			1.0
Created:			2013.10.10
Modified:			2013.10.10
****************************************************************************/

.include "I2CTinySlave.inc"



; Wartosci rejestru FLAGS
#define I2C_FLAGS_CHECK_SLAVE_ADDRESS_L_W_BIT       5
#define I2C_FLAGS_CHECK_SLAVE_ADDRESS_L_W      32
#define I2C_FLAGS_CHECK_SLAVE_ADDRESS_L        31
#define I2C_FLAGS_CHECK_SLAVE_ADDRESS          30       ; cpi
#define I2C_FLAGS_SEND_DATA_BIT                     3
#define I2C_FLAGS_SEND_DATA                     8
#define I2C_FLAGS_SEND_WAIT_ACK                 7       ; cpi
#define I2C_FLAGS_RECV_DATA                     6
#define I2C_FLAGS_SEND_CHECK_ACK                5       ; cpi
#define I2C_FLAGS_WAIT_SLAVE_ADDRESS_L_W_BIT        1
#define I2C_FLAGS_WAIT_SLAVE_ADDRESS_L_W        2
#define I2C_FLAGS_WAIT_SLAVE_ADDRESS_L          1
#define I2C_FLAGS_RECV_WAIT_DATA                0       ; cpi


#define _SFR_IO_ADDR(port) port



// SET_FLAGS
// I2C_COPY_FLAGS_TO_R_TMP
// I2C_COMPARE_FLAGS
// I2C_SKIP_IF_FLAG_CLEAR
.ifdef R_I2C_FLAGS
    .macro  SET_FLAGS                
        ldi     R_I2C_FLAGS, @0
    .endmacro
 
    .macro  SET_FLAGS_BLD
        ldi     R_I2C_FLAGS, @0
        bld     R_I2C_FLAGS, @1
    .endmacro

    .macro  FLAGS_BST
        bst     R_I2C_FLAGS, @0
    .endmacro

    .macro  CLEAR_FLAGS                     
        clr     R_I2C_FLAGS
    .endmacro
 
    .macro  I2C_COPY_FLAGS_TO_R_TMP
    .endmacro
    
    .macro  I2C_COMPARE_FLAGS        
        cpi     R_I2C_FLAGS, @0
    .endmacro
    //#define I2C_SKIP_IF_FLAG_CLEAR(_Flag)   sbrc    R_I2C_FLAGS, _Flag 

.endif
.ifdef I2C_FLAGS_IO

    .macro  SET_FLAGS_FROM_REG        
        out     _SFR_IO_ADDR( I2C_FLAGS_IO ), @0
    .endmacro
    
    .macro  SET_FLAGS                
        ldi     R_I2C_TMP, @0   
        SET_FLAGS_FROM_REG  R_I2C_TMP
    .endmacro

    .macro  SET_FLAGS_BLD
        ldi     R_I2C_TMP, @0   
        bld     R_I2C_TMP, @1   
        SET_FLAGS_FROM_REG  R_I2C_TMP
    .endmacro

    .macro  FLAGS_BST
        bst     R_I2C_TMP, @0
    .endmacro

    .macro  CLEAR_FLAGS                     
        clr     R_I2C_TMP
        SET_FLAGS_FROM_REG  R_I2C_TMP
    .endmacro

    .macro  I2C_COPY_FLAGS_TO_R_TMP         
        in      R_I2C_TMP, _SFR_IO_ADDR( I2C_FLAGS_IO )
    .endmacro

    .macro  I2C_COMPARE_FLAGS     
        cpi     R_I2C_TMP, @0
    .endmacro
    //#define I2C_SKIP_IF_FLAG_CLEAR(_Flag)   sbic    _SFR_IO_ADDR( I2C_FLAGS_IO ), _Flag 
    
.endif
.ifdef I2C_FLAGS_MEM

    .macro  SET_FLAGS_FROM_REG        
        sts     I2C_FLAGS_MEM, @0
    .endmacro

    .macro  SET_FLAGS                
        ldi     R_I2C_TMP, @0
        SET_FLAGS_FROM_REG  R_I2C_TMP
    .endmacro

    .macro  SET_FLAGS_BLD                
        ldi     R_I2C_TMP, @0
        bld     R_I2C_TMP, @1
        SET_FLAGS_FROM_REG  R_I2C_TMP
    .endmacro

    .macro  FLAGS_BST
        bst     R_I2C_TMP, @0
    .endmacro

    .macro  CLEAR_FLAGS                     
        clr     R_I2C_TMP
        SET_FLAGS_FROM_REG  R_I2C_TMP
    .endmacro

    .macro  I2C_COPY_FLAGS_TO_R_TMP         
        lds     R_I2C_TMP, I2C_FLAGS_MEM
    .endmacro

    .macro  I2C_COMPARE_FLAGS     
        cpi     R_I2C_TMP, @0
    .endmacro
    //#define I2C_SKIP_IF_FLAG_CLEAR(_Flag)   sbrc    R_I2C_TMP, _Flag

.endif



// I2C_SREG_STORE
// I2C_SREG_RESTORE
.ifdef  R_SREG_INTERRUPT_STORE
    
    .macro  I2C_SREG_STORE         
        in      R_SREG_INTERRUPT_STORE, _SFR_IO_ADDR(SREG)
    .endmacro

    .macro  I2C_SREG_RESTORE       
        out     _SFR_IO_ADDR(SREG), R_SREG_INTERRUPT_STORE
    .endmacro

.else

    .macro  I2C_SREG_STORE                            
        in      R_I2C_TMP, _SFR_IO_ADDR(SREG)       
        push    R_I2C_TMP
    .endmacro

    .macro  I2C_SREG_RESTORE                          
        pop     R_I2C_TMP                           
	    out     _SFR_IO_ADDR(SREG), R_I2C_TMP	
    .endmacro

.endif


// I2C_R_TMP_STORE
// I2C_R_TMP_RESTORE
.ifndef I2C_STORE_R_TMP
    .set    I2C_STORE_R_TMP = 1
.endif

.if( I2C_STORE_R_TMP != 0 )

    .macro  I2C_R_TMP_STORE
        push    R_I2C_TMP
    .endmacro

    .macro  I2C_R_TMP_RESTORE
        pop     R_I2C_TMP
    .endmacro

.else

    .macro  I2C_R_TMP_STORE
    .endmacro
        
    .macro  I2C_R_TMP_RESTORE
    .endmacro
    
.endif


// I2C_START_STORE_SREG
.ifndef I2C_START_STORE_SREG
    .set    I2C_START_STORE_SREG = 1    
.endif

;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
USI_I2C_INIT:
    cbi     SCL_DDR, SCL_BIT
    cbi     SDA_DDR,  SDA_BIT
    cbi     SCL_PORT, SCL_BIT
    sbi     SDA_PORT, SDA_BIT

    ldi     R_I2C_TMP, 1 << USISIE | 1 << USIWM1 | 1 << USICS1
    out     _SFR_IO_ADDR( USICR ), R_I2C_TMP
    ldi     R_I2C_TMP, 1 << USISIF | 1 << USIOIF | 1 << USIPF | 1 << USIDC
    out     _SFR_IO_ADDR( USISR ), R_I2C_TMP
        
    CLEAR_FLAGS
    
    ret
;----------------------------------------------------------------------------
USI_I2C_START:
    I2C_R_TMP_STORE

    I2C_START_BEGIN
    
.if I2C_START_STORE_SREG != 0
    I2C_SREG_STORE
.endif

    ; przygotowanie SDA do odbioru
    cbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT ; SDA-wejscie

    ; po odbiorze sprawdzony bedzie adres 
    SET_FLAGS(I2C_FLAGS_CHECK_SLAVE_ADDRESS)
    
    ; inicjowanie rejestrow kontrolnych
    sbi     _SFR_IO_ADDR( USICR ), USIOIE

    I2C_START_EXT_CODE

    ; oczekiwanie na zakonczenie sygnalu START
USV_WAIT_SCL_0:
    sbic    _SFR_IO_ADDR( SCL_PIN ), SCL_BIT
    rjmp    USV_WAIT_SCL_0

.if I2C_START_STORE_SREG != 0
    I2C_SREG_RESTORE
.endif

    I2C_START_END
    
    ; koniec obslugi start
    ldi     R_I2C_TMP, (1 << USISIF) + (1 << USIPF) + (1 << USIOIF) + 0
    out     USISR, R_I2C_TMP

    I2C_R_TMP_RESTORE

    reti
;----------------------------------------------------------------------------
USI_I2C_OV:

    I2C_R_TMP_STORE

    I2C_OV_BEGIN

    I2C_SREG_STORE
    
    I2C_COPY_FLAGS_TO_R_TMP
    
    I2C_COMPARE_FLAGS   I2C_FLAGS_CHECK_SLAVE_ADDRESS
    breq    _I2C_OV_CHECK_SLAVE_ADDRESS
    brsh    _I2C_OV_CHECK_SLAVE_ADDRESS_L
    
    I2C_COMPARE_FLAGS I2C_FLAGS_SEND_WAIT_ACK
    breq    _I2C_OV_SEND_WAIT_ACK
    brsh    _I2C_OV_SEND_DATA

    I2C_COMPARE_FLAGS I2C_FLAGS_SEND_CHECK_ACK
    breq    _I2C_OV_SEND_DATA_CHECK_ACK
    brsh    _I2C_OV_RECV_DATA

    I2C_COMPARE_FLAGS I2C_FLAGS_RECV_WAIT_DATA
    breq    _I2C_OV_RECV_WAIT_DATA
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
_I2C_OV_WAIT_SLAVE_ADDRESS_L:
    FLAGS_BST   I2C_FLAGS_WAIT_SLAVE_ADDRESS_L_W_BIT
    cbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT ; SDA-wejscie
    SET_FLAGS_BLD   I2C_FLAGS_CHECK_SLAVE_ADDRESS_L, I2C_FLAGS_CHECK_SLAVE_ADDRESS_L_W_BIT
    ldi     R_I2C_TMP, (1<<USISIF) | (1<<USIPF)
    rjmp    _I2C_OV_SET_USISR
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
_I2C_OV_RECV_WAIT_DATA:
    cbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT ; SDA-wejscie
    SET_FLAGS   I2C_FLAGS_RECV_DATA
    ldi     R_I2C_TMP, (1<<USISIF) | (1<<USIPF)
    rjmp    _I2C_OV_SET_USISR
;----------------------------------------------------------------------------
_I2C_OV_RECV_DATA:
    I2C_RECV_BYTE
    
    SET_FLAGS ( I2C_FLAGS_RECV_WAIT_DATA )
    
    ; ustawienie wyslania ACK
    rjmp    _I2C_OV_SEND_BIT_ACK
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; Wywolany po nadejsciu ACK/NAK do MASTER (po wyslaniu bajtu do MASTERTR)
_I2C_OV_SEND_DATA_CHECK_ACK:
    ; sprawdzenie czy MASTERowi odeslano ACK czy NAK
    sbic    _SFR_IO_ADDR( USIDR ), 0
    rjmp    _I2C_OV_RESET
    
    ; TODO: sprawdzenie czy koniec    
;----------------------------------------------------------------------------
_I2C_OV_SEND_DATA:
    ; wyslanie danych

    I2C_SEND_BYTE

    sbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT    ; SDA-wyjscie
    ; przy nastepnym wejsciu pobranie ACK/NAK od MASTER
    SET_FLAGS ( I2C_FLAGS_SEND_WAIT_ACK )
    
    ldi     R_I2C_TMP, 1 << USISIF | 1 << USIPF
    rjmp    _I2C_OV_SET_USISR
;----------------------------------------------------------------------------
; Wywolanie po wyslaniu danych do MASTER, oczekiwanie na ACK/NAK
_I2C_OV_SEND_WAIT_ACK:
    cbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT    ; SDA-wejscie    
    ; przy nastepnym wejsciu sprawdzanie ACK od MASTER
    SET_FLAGS ( I2C_FLAGS_SEND_CHECK_ACK )
    
    cbi     _SFR_IO_ADDR( USIDR ), 7
    rjmp    _I2C_OV_SEND_BIT_7
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
I2C_CHECK_SLAVE_ADDRESS_NOT_CORRECT:
I2C_RECV_BYTE_SEND_NAK:
I2C_SEND_BYTE_STOP:
_I2C_OV_RESET:
    cbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT ; SDA - wejscie
    CLEAR_FLAGS
    cbi     _SFR_IO_ADDR( USICR ), USIOIE
    ldi     R_I2C_TMP, (1<<USISIF)|(1<<USIPF)|(1<<USIDC)
    rjmp    _I2C_OV_SET_USISR
;----------------------------------------------------------------------------
_I2C_OV_CHECK_SLAVE_ADDRESS:
    in      R_I2C_TMP, _SFR_IO_ADDR( USIDR )
    bst     R_I2C_TMP, 0
    cbr     R_I2C_TMP, 1
    
    I2C_CHECK_SLAVE_ADDRESS
    brne    I2C_CHECK_SLAVE_ADDRESS_NOT_CORRECT

    ; sprawdzenie czy to adres 10-o bitowy
    cbr     R_I2C_TMP, 0b00000110
    cpi     R_I2C_TMP, 0b11110000
    brne    I2C_CHECK_SLAVE_ADDRESS_CORRECT
    ; adres jest 10-o bitowy
    SET_FLAGS_BLD   I2C_FLAGS_WAIT_SLAVE_ADDRESS_L, I2C_FLAGS_WAIT_SLAVE_ADDRESS_L_W_BIT
    rjmp    _I2C_OV_SEND_BIT_ACK
;----------------------------------------------------------------------------
_I2C_OV_CHECK_SLAVE_ADDRESS_L:
    FLAGS_BST   I2C_FLAGS_CHECK_SLAVE_ADDRESS_L_W_BIT
    in      R_I2C_TMP, _SFR_IO_ADDR( USIDR )
    I2C_CHECK_SLAVE_ADDRESS_L
    brne    I2C_CHECK_SLAVE_ADDRESS_NOT_CORRECT
;----------------------------------------------------------------------------
I2C_CHECK_SLAVE_ADDRESS_CORRECT:
    I2C_SLAVE_ADDRESS_CORRECT
    ; poprawny odres
    SET_FLAGS_BLD   0, I2C_FLAGS_SEND_DATA_BIT
    ; ustawienie wyslania ACK
_I2C_OV_SEND_BIT_ACK:
	clr     R_I2C_TMP
    out		USIDR, R_I2C_TMP
	;cbi     _SFR_IO_ADDR( USIDR ), 7
    sbi     _SFR_IO_ADDR( SDA_DDR ), SDA_BIT ; SDA-wyjscie
;----------------------------------------------------------------------------
_I2C_OV_SEND_BIT_7:
    ldi     R_I2C_TMP, (1<<USISIF)|(1<<USIPF)|(0x0E<<USICNT0)

_I2C_OV_SET_USISR:
    out     _SFR_IO_ADDR( USISR ), R_I2C_TMP

_I2C_OV_END:

    I2C_SREG_RESTORE

    I2C_OV_END

    I2C_R_TMP_RESTORE

    sbi     _SFR_IO_ADDR( USISR ), USIOIF
    
    reti
;----------------------------------------------------------------------------
