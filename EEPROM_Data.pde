/********************* 
    SAVE COLORS
    This methods saves the current color to the EEPROM, so that it can  
    feature the saved color on startup.
  */
void save_colors(){
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


