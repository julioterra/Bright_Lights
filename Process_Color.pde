
/********************* 
  SET COLOR
    This method is used to set the active R, G, B variable, or H, S, B variable. 
    the color_control variable determines whether the color is being controlled
    in rgb or hsb mode. Then the color_active, and active_hsb variables define
    which specific parameter from either of these modes is currently controlled
    by the potentiometer.
  */
void Bright_Lights::soft_set_hsb_color(int active_control, int new_val, int min_val, int max_val) {
   if (active_control == 0) new_val = map(new_val, min_val, max_val, 0, 360);
   else new_val = map(new_val, min_val, max_val, 0, 100);    
   
   if (check_soft_takeover(hsb_vals[active_control], new_val)) {   
        set_hsb_color(active_control, new_val);
    }
}

void Bright_Lights::set_hsb_color(int active_control, int new_val, int min_val, int max_val) {
   if (active_control == 0) new_val = map(new_val, min_val, max_val, 0, 360);
   else new_val = map(new_val, min_val, max_val, 0, 100);    
    if (new_val < 3) new_val = 0;
    set_hsb_color(active_control, new_val);
}

void Bright_Lights::set_hsb_color(int active_control, int new_val) {
    hsb_vals[active_control] = new_val;
    convertHSB();
    data_saved = false;   
    last_update = millis(); 
}

/********************* 
  CONVERT HSB
    Convert HSB colors into RGB colors.
 */
void Bright_Lights::convertHSB() {
      H2R_HSBtoRGB(hsb_vals[0], hsb_vals[1], hsb_vals[2], rgb_vals);
      for (int i = 0; i < NUM_color_ctrls; i++) rgb_vals[i] = map(rgb_vals[i], 0, 255, 0, LED_max_level);   
}



