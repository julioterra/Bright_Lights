/********************* 
    SAVE COLORS
    This methods saves the current color to the EEPROM, so that it can  
    feature the saved color on startup.
  */
void save_data(){
    // fix code so that it only saves when color has not changed for a while
    if (!data_saved && (millis() - last_save) > save_interval) {  
        byte temp_array[] = {0,0};

        int2bytes(hsb_vals[0], temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_hsb_address[0]+i, temp_array[i]); }

        int2bytes(hsb_vals[1], temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_hsb_address[1]+i, temp_array[i]); }

        int2bytes(hsb_vals[2], temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_hsb_address[2]+i, temp_array[i]); }
        
        int2bytes(scroll_speed, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_scroll_address[0]+i, temp_array[i]); }
        
        int2bytes(scroll_direction, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_scroll_address[1]+i, temp_array[i]); }

        int2bytes(scroll_width, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_scroll_address[2]+i, temp_array[i]); }
        
        int2bytes(strobe_speed, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_strobe_address[0]+i, temp_array[i]); }

        data_saved = true;
        last_save = millis();
    }
}


/*********************
    LOAD COLORS
    This methods loads the saved color from the EEPROM, so that it can  
    feature the saved color on startup.
  */
void load_data() {
  byte load_array[2] = {EEPROM.read(EEPROM_hsb_address[0]), EEPROM.read(EEPROM_hsb_address[0]+1)};
  hsb_vals[0] = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_hsb_address[1]);
  load_array[1] = EEPROM.read(EEPROM_hsb_address[1]+1);
  hsb_vals[1] = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_hsb_address[2]);
  load_array[1] = EEPROM.read(EEPROM_hsb_address[2]+1);
  hsb_vals[2] = bytes2int(load_array);
  convertHSB();

  load_array[0] = EEPROM.read(EEPROM_scroll_address[0]);
  load_array[1] = EEPROM.read(EEPROM_scroll_address[0]+1);
  scroll_speed = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_scroll_address[1]);
  load_array[1] = EEPROM.read(EEPROM_scroll_address[1]+1);
  scroll_direction = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_scroll_address[2]);
  load_array[1] = EEPROM.read(EEPROM_scroll_address[2]+1);
  scroll_width = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_strobe_address[0]);
  load_array[1] = EEPROM.read(EEPROM_strobe_address[0]+1);
  strobe_speed = bytes2int(load_array);

}

//void load_fun_mode() {
//  byte fun_load[] = {EEPROM.read(EEPROM_scroll_address[0]), EEPROM.read(EEPROM_scroll_address[0]+1)};
//  scroll_speed = bytes2int(fun_load);
//
//  fun_load[0] = EEPROM.read(EEPROM_scroll_address[1]);
//  fun_load[1] = EEPROM.read(EEPROM_scroll_address[1]+1);
//  scroll_direction = bytes2int(fun_load);
//
//  fun_load[0] = EEPROM.read(EEPROM_scroll_address[2]);
//  fun_load[1] = EEPROM.read(EEPROM_scroll_address[2]+1);
//  scroll_width = bytes2int(fun_load);
//
//  fun_load[0] = EEPROM.read(EEPROM_strobe_address[0]);
//  fun_load[1] = EEPROM.read(EEPROM_strobe_address[0]+1);
//  strobe_speed = bytes2int(fun_load);
//}


