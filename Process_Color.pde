
/********************* 
  SET COLOR
    This method is used to set the active R, G, B variable, or H, S, B variable. 
    the color_control variable determines whether the color is being controlled
    in rgb or hsb mode. Then the color_active, and active_hsb variables define
    which specific parameter from either of these modes is currently controlled
    by the potentiometer.
  */
void soft_set_hsb_color(int active_control, int new_val, int min_val, int max_val) {
    if (!new_mode || check_soft_takeover(hsb_vals[active_control], new_val)) {   
        set_hsb_color(active_control, new_val, min_val, max_val);
        new_mode = false;
    }
}

void set_hsb_color(int active_control, int new_val, int min_val, int max_val) {
    if (active_control == 0) hsb_vals[active_control] = map(new_val, min_val, max_val, 0, 360);
    else hsb_vals[active_control] = map(new_val, min_val, max_val, 0, 100);    
    if (new_val < 3) hsb_vals[active_control] = 0;
    convertHSB();
    last_color_change = millis();
    color_saved = false;
    
}


void soft_set_rgb_color(int active_control, int new_val, int min_val, int max_val) {
    if (!new_mode || check_soft_takeover(rgb_vals[active_control], new_val)) {   
        set_rgb_color(active_control, new_val, min_val, max_val);
        new_mode = false;
    } 
}

void set_rgb_color(int active_control, int new_val, int min_val, int max_val) {
    rgb_vals[active_control] = map(new_val, min_val, max_val, 0, LED_max_level);   
    if (new_val < 3) rgb_vals[active_control] = 0;
}



/********************* 
  CONVERT HSB
    Convert HSB colors into RGB colors.
 */
void convertHSB() {
      HSBtoRGB(hsb_vals[0], hsb_vals[1], hsb_vals[2], rgb_vals);
      for (int i = 0; i < NUM_color_ctrls; i++) rgb_vals[i] = map(rgb_vals[i], 0, 255, 0, LED_max_level);   
}



