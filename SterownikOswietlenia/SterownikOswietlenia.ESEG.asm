
.eseg
E_I2C_MY_ADDRESS:                       .db   I2C_MY_ADDRESS_DEFAULT
E_I2C_MY_ADDRESS_L:                     .byte   1

E_RESERVED:                             .byte   8

E_LED_GROUP_LEN_TAB:                    .byte   8

E_LED_SECTION_COUNT:                    .byte   1

E_LED_SECTION_0:
E_LED_SECTION_0_GROUP:                  .byte   1
E_LED_SECTION_0_STATE_3:                .byte   1
E_LED_SECTION_0_STATE_2:                .byte   1
E_LED_SECTION_0_STATE_1:                .byte   1
E_LED_SECTION_0_STATE_0:                .byte   1
E_LED_SECTION_0_DATA_SKIP:              .byte   1
E_LED_SECTION_0_RESERVED_3:             .byte   1
E_LED_SECTION_0_RESERVED_2:             .byte   1
E_LED_SECTION_0_RESERVED_1:             .byte   1
E_LED_SECTION_0_RESERVED_0:             .byte   1
E_LED_SECTION_0_DATA:                   .byte   1
E_LED_SECTIONS_NEXT_DATA:               .byte   EEPROMEND - E_LED_SECTION_0_DATA - 4
E_LED_SECTIONS_END:
