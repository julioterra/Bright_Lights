/********************* 
    SAVE COLORS
    This methods saves the current color to the EEPROM, so that it can  
    feature the saved color on startup.
  */
void save_colors(){
    // fix code so that it only saves when color has not changed for a while
    if (!color_saved && (millis() - last_color_change) > save_interval) {  
        byte hsb_temp[] = {0,0};        

        int2bytes(hsb_vals[0], hsb_temp);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_hsb_address[0]+i, hsb_temp[i]); }

        int2bytes(hsb_vals[1], hsb_temp);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_hsb_address[1]+i, hsb_temp[i]); }

        int2bytes(hsb_vals[2], hsb_temp);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_hsb_address[2]+i, hsb_temp[i]); }

        color_saved = true;
        last_color_change = millis();
    }
}

void save_fun_mode(){
    // fix code so that it only saves when color has not changed for a while
    if (!fun_mode_saved && (millis() - last_mode_change) > save_interval) {  
        byte temp_array[] = {0,0};
        
        int2bytes(scroll_speed, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_scroll_address[0]+i, temp_array[i]); }
        
        int2bytes(scroll_direction, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_scroll_address[1]+i, temp_array[i]); }

        int2bytes(scroll_width, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_scroll_address[2]+i, temp_array[i]); }
        
        int2bytes(strobe_speed, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_strobe_address[0]+i, temp_array[i]); }
        
        fun_mode_saved = true;
        last_mode_change = millis();
    }
}



/*********************
    LOAD COLORS
    This methods loads the saved color from the EEPROM, so that it can  
    feature the saved color on startup.
  */
void load_colors() {
  byte hsb_load[2] = {EEPROM.read(EEPROM_hsb_address[0]), EEPROM.read(EEPROM_hsb_address[0]+1)};
  hsb_vals[0] = bytes2int(hsb_load);

  hsb_load[0] = EEPROM.read(EEPROM_hsb_address[1]);
  hsb_load[1] = EEPROM.read(EEPROM_hsb_address[1]+1);
  hsb_vals[1] = bytes2int(hsb_load);

  hsb_load[0] = EEPROM.read(EEPROM_hsb_address[2]);
  hsb_load[1] = EEPROM.read(EEPROM_hsb_address[2]+1);
  hsb_vals[2] = bytes2int(hsb_load);
  convertHSB();
}

void load_fun_mode() {
  byte fun_load[] = {EEPROM.read(EEPROM_scroll_address[0]), EEPROM.read(EEPROM_scroll_address[0]+1)};
  scroll_speed = bytes2int(fun_load);

  fun_load[0] = EEPROM.read(EEPROM_scroll_address[1]);
  fun_load[1] = EEPROM.read(EEPROM_scroll_address[1]+1);
  scroll_direction = bytes2int(fun_load);

  fun_load[0] = EEPROM.read(EEPROM_scroll_address[2]);
  fun_load[1] = EEPROM.read(EEPROM_scroll_address[2]+1);
  scroll_width = bytes2int(fun_load);

  fun_load[0] = EEPROM.read(EEPROM_strobe_address[0]);
  fun_load[1] = EEPROM.read(EEPROM_strobe_address[0]+1);
  strobe_speed = bytes2int(fun_load);
}


