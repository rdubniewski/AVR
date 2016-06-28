#ifndef _I2CTinySlaveMacro1_inc_
#define _I2CTinySlaveMacro1_inc_
;----------------------------------------------------------------------------
/**     I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS

Sta³a okreœla czy moziwe traktowanie jednego odczytanego bajtu jako adresu 
zwracanych bajtów je¿eli po odczycie wyst¹pi³ bit stop.
Oznacza to, ¿e dla I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS != 0 
lub gdy nie jest zdefiniowana bêdzie 
mo¿liwa równi¿ komunikacja:
    S Adre_W Rejestr P S Adres_R Wartosc_R Wartosc_R+1 ... P
Dla sta³ej I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS
lub gdy I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS = 0 bêdzie 
poprawna tylko taka komunikacja:
    S Adre_W Rejestr Sr Adres_R Wartosc_R Wartosc_R+1 ... P
Wartosc_R jest wartoscia rejestru (komorki pamieci) okreœlonym przez Rejestr.
*/
;----------------------------------------------------------------------------
.ifndef I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS
    .equ    I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS    = 1
.endif
;----------------------------------------------------------------------------
.macro  I2C_START_BEGIN
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_START_EXT_CODE
    ; jak nie ma ustawionej flagi konca transkosji USIPF to znaczy,
    ; ze zostal powtorzony start, wtedy musi zostac ustawiony adres wysylania
    ; danych jaki zostal zadany przez mastera.
    ; sprawdzenie czy wskaznik bufora wskazuje na odebranie jednego bajtu
    ; i ustawienie offsetu dla domyslnego adresu wysylania danych
    cpi     R_I2C_BUF_POINTER_L, low(I2C_RECV_DATA_REQUEST + 1)
.if (I2C_RECV_DATA_REQUEST + 1) > 0xFF
    ldi     R_I2C_TMP, high(I2C_RECV_DATA_REQUEST + 1)
    cpc     R_I2C_BUF_POINTER_H, R_I2C_TMP
.endif
    ldi     R_I2C_BUF_POINTER_H, 0
    ldi     R_I2C_BUF_POINTER_L, I2C_SEND_DATA_DEFAULT_START - I2C_SEND_DATA
    brne    _ISE_ADD_START_ADDRESS
    ; sprawdzenie czy powtorzony start
.if I2C_MACRO1_ACCEPT_STOP_AFTER_REG_ADDRESS == 0
    dupa
    sbic    USISR, USIPF
    rjmp    _ISE_ADD_START_ADDRESS
.endif
    ; powtorzony start, sprawdzenie czy odczytany bajt miesci sie w zakresie 
    ; wielkosci bufora wysylania danych
    lds     R_I2C_TMP, I2C_RECV_DATA_REQUEST
    cpi     R_I2C_TMP, I2C_SEND_DATA_END - I2C_SEND_DATA + 1
    brsh    _ISE_ADD_START_ADDRESS

    ; ustawienie zadanego offsetu wysylania danych
    mov     R_I2C_BUF_POINTER_L, R_I2C_TMP

_ISE_ADD_START_ADDRESS:
    ; dodanie do offsetu bufora wysylania adresu poczatku bufora
    ldi     R_I2C_TMP, low(I2C_SEND_DATA)
    add     R_I2C_BUF_POINTER_L, R_I2C_TMP
    ldi     R_I2C_TMP, high(I2C_SEND_DATA)
    adc     R_I2C_BUF_POINTER_H, R_I2C_TMP
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_START_END
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_OV_BEGIN
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_OV_END
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_CHECK_SLAVE_ADDRESS
    cp      R_I2C_TMP, R_I2C_MY_ADDRESS
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_CHECK_SLAVE_ADDRESS_L
    cp      R_I2C_TMP, R_I2C_MY_ADDRESS_L
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_SLAVE_ADDRESS_CORRECT
    ; ustawienie wskaznika na pobieranie danych
    brts    PC + 3
    ldi     R_I2C_BUF_POINTER_H, high(I2C_RECV_DATA)
    ldi     R_I2C_BUF_POINTER_L, low(I2C_RECV_DATA)
.endmacro
;----------------------------------------------------------------------------
.macro  I2C_RECV_BYTE
    ; sprawdzenie czy bufor zostal przepelniony
    cpi     R_I2C_BUF_POINTER_L, low(I2C_RECV_DATA_END)
.if I2C_RECV_DATA_END > 0xFF
    ldi     R_I2C_TMP, high(I2C_RECV_DATA_END)
    cpc     R_I2C_BUF_POINTER_H, R_I2C_TMP
.endif
    brsh    I2C_RECV_BYTE_SEND_NAK

    ; zapis do bufora odczytu
    in      R_I2C_TMP, USIDR
    st      R_I2C_BUF_POINTER+, R_I2C_TMP
    
    I2C_BYTE_RECEIVED

.endmacro
;----------------------------------------------------------------------------
.macro  I2C_SEND_BYTE
    ; sprawdzenie czy koniec bufora
    cpi     R_I2C_BUF_POINTER_L, low(I2C_SEND_DATA_END)
.if I2C_SEND_DATA_END > 0xFF
    ldi     R_I2C_TMP, high(I2C_SEND_DATA_END)
    cpc     R_I2C_BUF_POINTER_H, R_I2C_TMP
.endif
    brsh    I2C_SEND_BYTE_STOP

    ld      R_I2C_TMP, R_I2C_BUF_POINTER+
    out     USIDR, R_I2C_TMP
.endmacro
;----------------------------------------------------------------------------
#endif
