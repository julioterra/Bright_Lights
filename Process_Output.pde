/********************* 
  CONTROL LIGHTS
    This method is used to control lights when device is not in realtime mode.
    Based on active mode status, it either turns on the lights, turns off the lights,
    or calls the fun_mode_on method to handle the fun mode. 
  */
void control_lights() {
    if (active_mode == MODE_color) lights_on_all();
    else if (active_mode == MODE_off) lights_off_all(); 
    else if (active_mode == MODE_fun) {
        if (fun_mode_active == FUN_strobe) strobe_active(); 
        else if (fun_mode_active == FUN_scroll) scroll_active(); 
    }
}


/********************* 
  LIGHTS ON REALTIME
    This method is used to control the lights when the device is in realtime 
    mode. It is called by the handle_serial method, when appropriate.
    ** Realtime mode enables a remote device to control the lights on bright 
    words using a serial connection. 
  */
void lights_on_realtime(byte* new_data) {
    Tlc.clear();      
    for (int i = 0; i < 24; i++) {  
        Tlc.set(rgb_pins[i], map(int(new_data[i]), 0, 127, 0, LED_max_level));
    }
    Tlc.update();  
}


/********************* 
  LIGHTS ON ALL
    Turns on all lights to the current color set in the rgb_vals array.
  */
void lights_on_all() {
    Tlc.clear();      
    for (int i = 0; i < NUM_RGB_LED; i++) {  
        Tlc.set(redPins[i], rgb_vals[R]);
        Tlc.set(greenPins[i], rgb_vals[G]);
        Tlc.set(bluePins[i], rgb_vals[B]);
    }
    Tlc.update();  
}


/********************* 
  LIGHTS ON SINGLE ONLY
    Turns on a single light to the current color saved in the rgb_vals array and
    turns off all other lights.
  */
void lights_on_single_only(int current_led) {
    Tlc.clear();  
    for (int i = 0; i < NUM_RGB_LED; i++) {
        if (current_led == i) {
            Tlc.set(redPins[i], rgb_vals[R]);
            Tlc.set(greenPins[i], rgb_vals[G]);
            Tlc.set(bluePins[i], rgb_vals[B]);
        }
    }      
    Tlc.update();  
}


/********************* 
  LIGHTS ON MULTIPLE
    Turns on all the lights on the led array
  */
void lights_on_multiple(int* led_array, int array_length) {
    
    Tlc.clear();  
    for (int j = 0; j < array_length; j++) {
        Tlc.set(redPins[led_array[j]], rgb_vals[R]);
        Tlc.set(greenPins[led_array[j]], rgb_vals[G]);
        Tlc.set(bluePins[led_array[j]], rgb_vals[B]);
    }      
    Tlc.update();  
}


/********************* 
  LIGHTS ON SINGLE
    Turns on a single light to current color saved in the rgb_vals array, while 
    leaving all other lights unchanged.
  */
void lights_on_single(int current_led) {
    Tlc.set(redPins[current_led], rgb_vals[R]);
    Tlc.set(greenPins[current_led], rgb_vals[G]);
    Tlc.set(bluePins[current_led], rgb_vals[B]);
    Tlc.update();  
}


/********************* 
  LIGHTS OFF ALL
    Turns all lights.
  */
void lights_off_all() {
      Tlc.clear();
      Tlc.update(); 
}


/********************* 
  LIGHTS OFF SINGLE
    Turns off a single lights only.
  */
void lights_off_single(int current_led) {
    Tlc.set(redPins[current_led], 0);
    Tlc.set(greenPins[current_led], 0);
    Tlc.set(bluePins[current_led], 0);
    Tlc.update();  
}


/********************* 
  BLINK DELAY
    Blinks the lights while delaying the reading of input. 
    Method is used to identify which color parameter is being controlled, 
    when the parameter is changed.
  */
void blink_delay(int blinks) {
   for (int i = 0; i < blinks; i++) {
     lights_on_all();
     delay(400);
     lights_off_all();
     delay(300);
   }  
}


