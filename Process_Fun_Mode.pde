/********************* 
  SOFT SET STROBE SPEED: sets the speed of the strobing lights with a soft takeover. 
  Called by physical controls when initially switched to the strobe control mode.
  */
void Bright_Lights::soft_set_strobe_speed (int new_val, int min_val, int max_val) {
    if (check_soft_takeover(strobe_speed, new_val)) {   
        set_strobe_speed (new_val, min_val, max_val);
    }
}

/********************* 
  SET STROBE SPEED: sets the speed of the strobing lights.
  */
void Bright_Lights::set_strobe_speed (int new_val, int min_val, int max_val) {
    strobe_speed = map(new_val, min_val, max_val, STROBE_speed_min, STROBE_speed_max);
    data_saved = false; 
}

/********************* 
  SOFT SET SCROLL SPEED: sets the speed of the scrolling lights with a soft takeover. 
  Called by physical controls when initially switched to the scroll control mode.
  */
void Bright_Lights::soft_set_scroll_speed (int new_val, int min_val, int max_val) {
    if (check_soft_takeover(scroll_speed, new_val)) {   
        set_scroll_speed (new_val, min_val, max_val);
    }
}

/********************* 
  SET SCROLL SPEED: sets the speed of the scrolling lights.
  */
void Bright_Lights::set_scroll_speed (int new_val, int min_val, int max_val) {
    scroll_speed = map(new_val, min_val, max_val, SCROLL_speed_min, SCROLL_speed_max);  
    data_saved = false;  
}

/********************* 
  SET SCROLL DIRECTION: sets the direction of the scrolling lights. Possible directions
  include: (0) to the left; (1) to the right; (2) to the center; (3) from the center
  */
void Bright_Lights::set_scroll_direction (int new_val, int min_val, int max_val) {
    scroll_direction = map(new_val, min_val, max_val, 0, 3);  
    data_saved = false;  
}

/********************* 
  SET SCROLL WIDTH: sets how many of the leds will be on while scrolling. The width can range
  from 1 led is on, to all leds except 1 are one.
  */
void Bright_Lights::set_scroll_width (int new_val, int min_val, int max_val) {
    scroll_width = map(new_val, min_val, max_val, SCROLL_width_min, SCROLL_width_max);  
    data_saved = false;  
}

/********************* 
  STROBE ACTIVE
    Controls the state of the lights when in strobe mode. This method is responsible for timing
    and setting the leds to turn and and off. 
  */
void Bright_Lights::strobe_active() {
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
    Controls the lights when in scroll mode based. Responsible for timing and determining which 
    lights should be turned on or off based on the current scroll direction, speed, and width.
  */
void Bright_Lights::scroll_active() {
    long current_time = millis();
    boolean new_state = false;
    
    // determine if it is time to the move the current scroll position based on the direction    
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

    // if it is time to move the scroll then move it
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
void Bright_Lights::scroll_led_array(int current_pos, int* led_array, int array_length) {
    for (int i = 0; i < array_length; i ++) {
        switch (scroll_direction) {
            case 0:
                led_array[i] = current_pos;
                current_pos--;
                if (current_pos < 0) current_pos = NUM_RGB_LED-1;
                break;
            case 1:
                led_array[i] = current_pos;
                current_pos++;
                if (current_pos >= NUM_RGB_LED) current_pos = 0;
                break;          
            case 2:
                led_array[i] = current_pos;
                led_array[(array_length-1)-i] = (NUM_RGB_LED-1) - current_pos;
                current_pos--;
                if (current_pos < 0) current_pos = (NUM_RGB_LED)/2;
                break;
            case 3:
                led_array[i] = current_pos;
                led_array[(array_length-1)-i] = (NUM_RGB_LED-1) - current_pos;
                current_pos++;
                if (current_pos >= NUM_RGB_LED/2) current_pos = 0;
                break;
        }
    }     
}


