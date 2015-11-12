/*
 * SterownikZaworu_DSEG.asm
 *
 *  Created: 2014-01-04 19:31:09
 *   Author: Rafal
 */ 

; Organizacja RAMU
.dseg

I2C_SEND_DATA:
DEVICE_TYPE:                            .byte   1
DEVICE_VERSION:                         .byte   1

I2C_SEND_DATA_DEFAULT_START:
WORKING_STATE:                          .byte   1
SENSOR_COUNT:                           .byte   1
SENSOR_INDEXES:                         .byte   1
SENSOR_TEMPERATURES:                    .byte   MAX_SENSOR_COUNT * 1
SENSOR_ROMS:                            .byte   MAX_SENSOR_COUNT * 6
TEMPERATURE_REQUEST:                    .byte   1
TEMPERATURE_IN_MAX:                     .byte   1
MOTOR_PWM_COUNTER_MAX:                  .byte   1
MOTOR_ENABLED_COUNTER:
    MOTOR_ENABLED_COUNTER_H:            .byte   1
    MOTOR_ENABLED_COUNTER_L:            .byte   1
MOTOR_ENABLED_TIME:
    MOTOR_ENABLED_TIME_H:               .byte   1
    MOTOR_ENABLED_TIME_L:               .byte   1
I2C_SEND_DATA_END:

I2C_RECV_DATA:
I2C_RECV_DATA_REQUEST:                  .byte   1
I2C_RECV_DATA_ARG_0:                    .byte   1
I2C_RECV_DATA_ARG_1:                    .byte   1
I2C_RECV_DATA_END:


OWIRE_ROM: 
DS18B20_SCRATCHPAD:

OWIRE_ROM_FAMILY_CODE:
DS18B20_SCRATCHPAD_TEMPERATURE_L:       .byte   1

OWIRE_ROM_ID:
OWIRE_ROM_ID_0:
DS18B20_SCRATCHPAD_TEMPERATURE_H:       .byte   1

OWIRE_ROM_ID_1:
DS18B20_SCRATCHPAD_BYTE_1:              .byte   1

OWIRE_ROM_ID_2:
DS18B20_SCRATCHPAD_BYTE_2:              .byte   1

OWIRE_ROM_ID_3:
DS18B20_SCRATCHPAD_CONFIG:              .byte   1

OWIRE_ROM_ID_4:                         .byte   1
OWIRE_ROM_ID_5:                         .byte   1
