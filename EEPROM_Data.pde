/********************* 
    SAVE COLORS
    This methods saves the current color to the EEPROM, so that it can  
    feature the saved color on startup.
  */
void save_colors(){
    // fix code so that it only saves when color has not changed for a while
    if (!color_saved && (millis() - last_color_change) > save_interval) {  
        byte hsb_hue[] = {0,0};
        byte hsb_sat[] = {0,0};
        byte hsb_bright[] = {0,0};
        
        int2bytes(hsb_vals[0], hsb_hue);
        int2bytes(hsb_vals[1], hsb_sat);
        int2bytes(hsb_vals[2], hsb_bright);
        
        for (int i; i < 2; i++) {
            EEPROM.write(EEPROM_hsb_address[0]+i, hsb_hue[i]);
            EEPROM.write(EEPROM_hsb_address[1]+i, hsb_sat[i]);
            EEPROM.write(EEPROM_hsb_address[2]+i, hsb_bright[i]);
        }
        color_saved = true;
    }
}

void save_fun_mode(){
    // fix code so that it only saves when color has not changed for a while
    if (!fun_mode_saved && (millis() - last_fun_mode_change) > save_interval) {  
        byte scroll_speed_array[] = {0,0};
        byte scroll_direction_array[] = {0,0};
        byte scroll_width_array[] = {0,0};
        byte strobe_speed_array[] = {0,0};
        
        int2bytes(scroll_speed, scroll_speed_array);
        int2bytes(scroll_direction, scroll_direction_array);
        int2bytes(scroll_width, scroll_width_array);
        int2bytes(strobe_speed, strobe_speed_array);
        
        for (int i; i < 2; i++) {
            EEPROM.write(EEPROM_scroll_address[0]+i, scroll_speed_array[i]);
            EEPROM.write(EEPROM_scroll_address[1]+i, scroll_direction_array[i]);
            EEPROM.write(EEPROM_scroll_address[2]+i, scroll_width_array[i]);
            EEPROM.write(EEPROM_strobe_address[0]+i, strobe_speed_array[i]);
        }
        fun_mode_saved = true;
    }
}



/*********************
    LOAD COLORS
    This methods loads the saved color from the EEPROM, so that it can  
    feature the saved color on startup.
  */
void load_colors() {
  byte hsb_hue[2] = {EEPROM.read(EEPROM_hsb_address[0]), EEPROM.read(EEPROM_hsb_address[0]+1)};
  byte hsb_sat[2] = {EEPROM.read(EEPROM_hsb_address[1]), EEPROM.read(EEPROM_hsb_address[1]+1)};
  byte hsb_bright[2] = {EEPROM.read(EEPROM_hsb_address[2]), EEPROM.read(EEPROM_hsb_address[2]+1)};
  hsb_vals[0] = bytes2int(hsb_hue);
  hsb_vals[1] = bytes2int(hsb_sat);
  hsb_vals[2] = bytes2int(hsb_bright);
  convertHSB();
}

void load_fun_mode() {
  byte scroll_speed_array[] = {EEPROM.read(EEPROM_scroll_address[0]), EEPROM.read(EEPROM_scroll_address[0]+1)};
  byte scroll_direction_array[] = {EEPROM.read(EEPROM_scroll_address[1]), EEPROM.read(EEPROM_scroll_address[1]+1)};
  byte scroll_width_array[] = {EEPROM.read(EEPROM_scroll_address[2]), EEPROM.read(EEPROM_scroll_address[2]+1)};
  byte strobe_speed_array[] = {EEPROM.read(EEPROM_strobe_address[0]), EEPROM.read(EEPROM_strobe_address[0]+1)};

  scroll_speed = bytes2int(scroll_speed_array);
  scroll_width = bytes2int(scroll_width_array);
  scroll_direction = bytes2int(scroll_direction_array);
  strobe_speed = bytes2int(strobe_speed_array);
}


