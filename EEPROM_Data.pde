/********************* 
    SAVE COLORS
    This methods saves the current color, strobe and scroll preferences to the EEPROM.
  */
void Bright_Lights::save_data(){
    if (!data_saved && (millis() - last_save) > save_interval) {  
        byte temp_array[] = {0,0};

        int2bytes(hsb_vals[0], temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[0]+i, temp_array[i]); }

        int2bytes(hsb_vals[1], temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[1]+i, temp_array[i]); }

        int2bytes(hsb_vals[2], temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[2]+i, temp_array[i]); }
        
        int2bytes(scroll_speed, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[3]+i, temp_array[i]); }
        
        int2bytes(scroll_direction, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[4]+i, temp_array[i]); }

        int2bytes(scroll_width, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[5]+i, temp_array[i]); }
        
        int2bytes(strobe_speed, temp_array);
        for (int i; i < 2; i++) { EEPROM.write(EEPROM_addresses[6]+i, temp_array[i]); }

        data_saved = true;
        last_save = millis();
    }
}


/*********************
    LOAD DATA
    This methods loads the saved color, scroll and strobe information from the EEPROM.
  */
void Bright_Lights::load_data() {
  byte load_array[2] = {0,0};

  load_array[0] = EEPROM.read(EEPROM_addresses[0]);
  load_array[1] = EEPROM.read(EEPROM_addresses[0]+1);
  hsb_vals[0] = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_addresses[1]);
  load_array[1] = EEPROM.read(EEPROM_addresses[1]+1);
  hsb_vals[1] = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_addresses[2]);
  load_array[1] = EEPROM.read(EEPROM_addresses[2]+1);
  hsb_vals[2] = bytes2int(load_array);
  convertHSB();

  load_array[0] = EEPROM.read(EEPROM_addresses[3]);
  load_array[1] = EEPROM.read(EEPROM_addresses[3]+1);
  scroll_speed = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_addresses[4]);
  load_array[1] = EEPROM.read(EEPROM_addresses[4]+1);
  scroll_direction = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_addresses[5]);
  load_array[1] = EEPROM.read(EEPROM_addresses[5]+1);
  scroll_width = bytes2int(load_array);

  load_array[0] = EEPROM.read(EEPROM_addresses[6]);
  load_array[1] = EEPROM.read(EEPROM_addresses[6]+1);
  strobe_speed = bytes2int(load_array);

}
