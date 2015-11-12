/*
 * SterownikZaworu_ESEG.asm
 *
 *  Created: 2014-01-04 19:31:09
 *   Author: Rafal
 */ 

; organizacja EEPROM
.eseg

E_I2C_MY_ADDRESS:                       .db I2C_MY_ADDRESS_DEFAULT
E_SENSOR_INDEXES:                       .db 0xF0
E_TEMPERATURE_REQUEST:                  .db TEMPERATURE_REQUEST_DEFAULT
E_TEMPERATURE_IN_MAX:                   .db TEMPERATURE_IN_MAX_DEFAULT
E_SENSOR_COUNT:                         .db 0
E_SENSOR_ROMS:                          .byte   6 * MAX_SENSOR_COUNT
E_MOTOR_PWM_COUNTER_MAX:                .db MOTOR_PWM_COUNTER_MAX_DEFAULT
E_MOTOR_ENABLED_TIME_L:                 .db low(MOTOR_ENABLED_TIME_DEFAULT)
E_MOTOR_ENABLED_TIME_H:                 .db high(MOTOR_ENABLED_TIME_DEFAULT)
