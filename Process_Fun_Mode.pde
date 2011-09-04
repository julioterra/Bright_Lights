
void soft_set_strobe (int new_val, int min_val, int max_val) {
    if (!new_mode || check_soft_takeover(strobe_speed, new_val)) {   
        set_strobe ( new_val, min_val, max_val);
        new_mode = false;
    }
}

void set_strobe (int new_val, int min_val, int max_val) {
    strobe_speed = map(new_val, min_val, max_val, STROBE_inter_min, STROBE_inter_max);
    fun_mode_saved = false;  
}


void soft_set_scroll (int new_val, int min_val, int max_val) {
    if (!new_mode || check_soft_takeover(scroll_speed, new_val)) {   
        set_scroll (new_val, min_val, max_val);
        new_mode = false;        
    }
}

void set_scroll (int new_val, int min_val, int max_val) {
    scroll_speed = map(new_val, min_val, max_val, SCROLL_inter_min, SCROLL_inter_max);  
    fun_mode_saved = false;  
}

void set_scroll_direction (int new_val, int min_val, int max_val) {
    scroll_direction = map(new_val, min_val, max_val, 0, 4);  
    fun_mode_saved = false;  
}

void set_scroll_width (int new_val, int min_val, int max_val) {
    scroll_width = map(new_val, min_val, max_val, 1, (NUM_RGB_LED-1));  
    fun_mode_saved = false;  
}


/********************* 
  STROBE ACTIVE
    Controls the lights when in strobe mode.
  */
void strobe_active() {
    long current_time = millis();

    // determine if it is time to change the state of the lights and if so change the state flag
    if (current_time - strobe_last_switch > strobe_speed) {
        if (strobe_on) { strobe_on = false; } 
        else { strobe_on = true; }
        strobe_last_switch = current_time;
    }
    
    // turn lights on or off based on current state
    if (strobe_on) { lights_on_all(); } 
    else { lights_off_all(); }
}


/********************* 
  SCROLL ACTIVE
    Controls the lights when in scroll mode based on the current scroll direction,
    interval, and width.
  */
void scroll_active() {
    long current_time = millis();
    boolean new_state = false;
    
    // determine if it is time to the move the current scroll position, and if so move it    
    if (current_time - scroll_last_switch > scroll_speed) {
        if (scroll_direction == 0) {
            scroll_led_pos++;
            if (scroll_led_pos >= NUM_RGB_LED) scroll_led_pos = 0;
        }
        else if (scroll_direction == 1) {
            scroll_led_pos--;
            if (scroll_led_pos < 0) scroll_led_pos = NUM_RGB_LED-1;
        }            
    
        else if (scroll_direction == 2) {
            scroll_led_pos++;
            if (scroll_led_pos >= NUM_RGB_LED/2) scroll_led_pos = 0;
        }
        else if (scroll_direction == 3) {
            scroll_led_pos--;
            if (scroll_led_pos < 0) scroll_led_pos = (NUM_RGB_LED-1)/2;
        }
        new_state = true;
        scroll_last_switch = current_time;
    }    

    if (new_state) {
        if (scroll_direction == 0 || scroll_direction == 1) {
            int active_leds[scroll_width];
            scroll_led_array(scroll_led_pos, active_leds, scroll_width); 
            lights_on_multiple(active_leds, scroll_width);
        }
        else if (scroll_direction == 2 || scroll_direction == 3) {
            int adjusted_scroll_width = scroll_width;
            if (scroll_width > 3) adjusted_scroll_width = 3;  
            int array_length_adjusted = adjusted_scroll_width * 2;
            int active_leds[array_length_adjusted];
            scroll_led_array(scroll_led_pos, active_leds, array_length_adjusted); 
            lights_on_multiple(active_leds, array_length_adjusted);
        }
    }
}


/********************* 
  SCROLL LED ARRAY
    The scroll LED array .
  */
void scroll_led_array(int current_pos, int* led_array, int array_length) {
    for (int i = 0; i < array_length; i ++) {
        if (scroll_direction == 0) {
            led_array[i] = current_pos;
            current_pos--;
            if (current_pos < 0) current_pos = NUM_RGB_LED-1;
        }
        else if (scroll_direction == 1) {
            led_array[i] = current_pos;
            current_pos++;
            if (current_pos >= NUM_RGB_LED) current_pos = 0;
        }
        else if (scroll_direction == 2) {
            led_array[i] = current_pos;
            led_array[(array_length-1)-i] = (NUM_RGB_LED-1) - current_pos;
            current_pos--;
            if (current_pos < 0) current_pos = (NUM_RGB_LED)/2;
        }
        else if (scroll_direction == 3) {
            led_array[i] = current_pos;
            led_array[(array_length-1)-i] = (NUM_RGB_LED-1) - current_pos;
            current_pos++;
            if (current_pos >= NUM_RGB_LED/2) current_pos = 0;
        }
    }     
}


