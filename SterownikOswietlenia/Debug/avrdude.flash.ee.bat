 "c:\program files\avrdude\avrdude.exe" -p ATmega32 -c stk200 -P lpt1 -i 50 -U lfuse:w:0xFF:m -U hfuse:w:0x49:m  -U flash:w:"C:\Users\Public\Wymiana\Rafal\Git\AVR\SterownikOswietlenia\Debug\SterownikOswietlenia.hex":i 
 -U eeprom:w:"C:\Users\Public\Wymiana\Rafal\Git\AVR\SterownikOswietlenia\Debug\SterownikOswietlenia.eep":i  
