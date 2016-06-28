/****************************************************************************
File:               SterownikZaworu.inc
Author:             Rafa³ Dubniewski
PCB Verssion        1.x
Verssion            1.0
Created:            2014.01.4
Modified:           2014.01.4
****************************************************************************/
.include    "DefineIO.inc"
.include    "I2C_DeviceTypes.inc"


; Typ i wercja ukladu
.equ    DEVICE_TYPE_DEF                         = DEVICE_VALVE_DRIVER_TYPE
.equ    DEVICE_VERSION_DEF                      = 0x10


; Czêstotliwoœci
.equ    FREQUENCY                               = 16000000

; Definicja preskalera zegara przy generatorze PLL
.equ    CLKPR_DEF                   = 0 << CLKPS2 | 0 << CLKPS1 | 0 << CLKPS0

; Maksymalna liczba obs³ugiwanych czujników temperatury
.equ    MAX_SENSOR_COUNT                        = 12

.equ    MAX_SENSOR_READ_ONCE                    = 3

; konfiguracja timera kontroli stanu (timer 1), ok 5hZ
.equ    TIMER_FREQUENCY             = 5
.equ    TIMER_PRESCALER             = 16384
.equ    TIMER_CONTROL_1             = TCCR1
.equ    TIMER_CONTROL_1_DEF         = 1 << PWM1A |   \
                                      1 << CS13 | 1 << CS12 | 1 << CS11 | 1 << CS10
.equ    TIMER_CONTROL_2             = GTCCR
.equ    TIMER_CONTROL_2_DEF         = 1 << PWM1B
.equ    TIMER_OCR                   = OCR1C
.equ    TIMER_OCR_DEF               = (FREQUENCY / TIMER_PRESCALER / TIMER_FREQUENCY) + 0
.equ    TIMER_MASK_DEF              = 1 << TOIE1


; Czestotliwosc pomiaru
; Dla precyzji 0.5 czas pomiaru to ok 100ms, damy 200 czyli 5Hz
.equ    MESAURE_FREQUENCY               = 5
; Ilosc taktow timera do pobrania wyniku pomiaru. 
.equ    MEASURE_TIMER_TICKS             = TIMER_FREQUENCY / MESAURE_FREQUENCY
; Gradacja dzialania PWM ok sekunda
.equ    MOTOR_PWM_COUNTER_PERIOD_MAX    = MESAURE_FREQUENCY

; Wylaczenie odkladania na stosie rejestrow w funkcji OWIRE_MASTER_SEARCH_ROM
.equ    OWIRE_MASTER_SEARCH_ROM_NO_STORE_REGS = 1
; Wylaczenie odkladania na stosie rejestrow w funkcji WAIT_*
.equ    WAIT_NO_STORE_REGS = 1


; Definicje IO mokrokontrolera
DEFINE_IO   OWIRE_MASTER,   B, 1
DEFINE_IO   SCL,            B, 2
DEFINE_IO   SDA,            B, 0
DEFINE_IO   MOTOR,          B, 4
//DEFINE_IO   MOTOR_LEFT,     B, 3
//DEFINE_IO   MOTOR_RIGHT,    B, 4


; Definicja rejestrów
.def    R_ZERO                                  = r2
.def    R_MOTOR_PWM_COUNTER_PERIOD              = r7
.def    R_MOTOR_PWM_COUNTER                     = r8
.def    R_OWIRE_MASTER_STACK                    = r9
.def    R_OWIRE_MASTER_STACK_PTR                = r10
.def    R_OWIRE_MASTER_STACK_PTR_MAX            = r11
; uzywane w innych miekscach wiec moga sie pokrywac
#define R_READ_TEMPERATURE_SENSOR_TMP           R_OWIRE_MASTER_STACK
#define R_TEMPERATURE_L_TMP                     R_OWIRE_MASTER_STACK_PTR
#define R_TEMPERATURE_H_TMP                     R_OWIRE_MASTER_STACK_PTR_MAX
#define R_SENSOR_IN_INDEX                       R_OWIRE_MASTER_STACK_PTR
#define R_SENSOR_OUT_INDEX                      R_OWIRE_MASTER_STACK_PTR_MAX
.def    R_TEMPERATURE_L                         = r12
.def    R_TEMPERATURE_H                         = r13
.def    R_TMP_1                                 = r16
.def    R_TMP_2                                 = r17
.def    R_DATA                                  = r18
.def    R_OWIRE_CRC                             = r19
.def    R_WORKING_STATE                         = r19   ; Uzywane w innym niejscu wiec moze sie pokrywac

.if     MEASURE_TIMER_TICKS > 1
    .def    R_TIMER_COUNTER                     = r4
.endif

#define R_POINTER                               X
#define R_POINTER_L                             XL
#define R_POINTER_H                             XH

#define R_OWIRE_MASTER_POINTER                  R_POINTER
#define R_OWIRE_MASTER_POINTER_L                R_POINTER_L
#define R_OWIRE_MASTER_POINTER_H                R_POINTER_H


.equ    DS18B20_SCRATCHPAD_IN_RAM_IS_DEFINED    = 1

; Liczy pomiary przy wlaczanym silniku by co sekunde inkrementowaæ MOTOR_ENABLED_COUNTER
.def    R_MOTOR_ENABLED_TIMER_COUNTER           = r5
.def    R_LOOP                                  = r20
.def    R_SENSOR_INDEX                          = r21
.def    R_WAIT_0                                = r24  ; Muni byc r24 bo na nim wykonana jest adiw dla licznika czasu
.def    R_WAIT_1                                = r25
; Rejestry poni¿ej nie moga siê pokrywaæ z inymi rejestrami,
; u¿ywane w przerwaniach
.def    R_SREG_INTERRUPT_STORE                  = r15
.def    R_I2C_FLAGS                             = r22
.def    R_I2C_TMP                               = r23
.def    R_I2C_MY_ADDRESS                        = r6
.def    R_I2C_MY_ADDRESS_L                      = r3
.def    R_CONTROL                               = r29
#define R_I2C_BUF_POINTER                       Z
#define R_I2C_BUF_POINTER_L                     ZL
#define R_I2C_BUF_POINTER_H                     ZH

.equ    I2C_STORE_R_TMP                         = 0
.equ    I2C_START_STORE_SREG                    = 1

#define R_OWIRE_DATA                            R_DATA
;.equ    I2C_FLAGS                              = GPIOR0


; Bity rejestru kontrolnego pracy programu R_CONTROL
; Flaga ustawiana w przerwaniui timera nakazujaca liczenie taktow do pomiaru
.equ    R_CONTROL_CHECK_TIMER_BIT               = 0
; Flaga wyslania zadania pomiaru do czujników.
.equ    R_CONTROL_CHECK_MOTOR_BIT               = 1
; Flaga nakazujaca odwrocenie kierunku sterowaia zaworem.
.equ    R_CONTROL_CHANGE_DIRECTION_BIT          = 2
; Okresla czy poprzednio silnik obracal sie lewo
.equ    R_CONTROL_PREV_MOTOR_LEFT_BIT           = 3
; Okresla czy poprzednio silnik obracal sie lewo
.equ    R_CONTROL_PREV_MOTOR_RIGHT_BIT          = 4
; Okresla czy silnik nalezy zastopowac w wyniku zbyt dlugiej pracy
.equ    R_CONTROL_MOTOR_STOPPED_BIT             = 5

; Flaga informuj¹ca o nadejœciu bajtu
.equ    R_CONTROL_I2C_READ_BYTE_BIT             = 7

.equ    R_CONTROL_PREV_MOTOR_MASK   = \
            1 << R_CONTROL_PREV_MOTOR_LEFT_BIT  |   \
            1 << R_CONTROL_PREV_MOTOR_RIGHT_BIT


; Bity bajtu kontrolnego WORKING_STATE zwracanego po I2C
.equ    WORKING_STATE_CHANGE_DIRECTION_BIT  = 0
.equ    WORKING_STATE_MOTOR_RIGHT_BIT       = 1
.equ    WORKING_STATE_MOTOR_LEFT_BIT        = 2


; Wartoœci domyœlne
.equ    TEMPERATURE_REQUEST_DEFAULT         = 27
.equ    TEMPERATURE_IN_MAX_DEFAULT          = 45
.equ    MOTOR_ENABLED_TIME_DEFAULT          = 180 ;2 minuty
; Rozdzielczoœæ PWM, dzie³anie co 0.5 stopnia C
.equ    MOTOR_PWM_COUNTER_MAX_DEFAULT       = 4
.equ    I2C_MY_ADDRESS_DEFAULT              = DEVICE_VALVE_DRIVER_I2C_ADDRES


; ¯¹dania I2C
.equ    I2C_REQUEST_SLAVE_ADDRESS               = 0x81

.equ    I2C_REQUEST_SAVE_EE                     = 0xA1

.equ    I2C_REQUEST_SET_TEMPERATURE             = 0xC1
.equ    I2C_REQUEST_SET_TEMPERATURE_IN_MAX      = 0xC2
.equ    I2C_REQUEST_SEARCH_SENSORS              = 0xC3
.equ    I2C_REQUEST_SET_SENSOR_INDEXES          = 0xC4
.equ    I2C_REQUEST_SET_MOTOR_PWM_COUNTER_MAX   = 0xC5
.equ    I2C_REQUEST_SET_MOTOR_ENABLED_TIME      = 0xC6

.equ    I2C_REQUEST_RESET                       = 0xC8
