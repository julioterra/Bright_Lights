/* SAVE COLORS
    This methods saves the current color to the EEPROM, so that it can  
    feature the saved color on startup.
  */
void save_colors(){
     for (int i; i < NUM_color_ctrls; i++) EEPROM.write(EEPROM_color_address[i], rgb_vals[i]);
//        EEPROM.write(EEPROM_color_address[R], rgb_vals[R]);
//        EEPROM.write(EEPROM_color_address[G], rgb_vals[G]);
//        EEPROM.write(EEPROM_color_address[B], rgb_vals[B]);
}

/* LOAD COLORS
    This methods loads the saved color from the EEPROM, so that it can  
    feature the saved color on startup.
  */
void load_colors() {
   for (int i; i < NUM_color_ctrls; i++) rgb_vals[i] = EEPROM.read(EEPROM_color_address[i]); 
}


