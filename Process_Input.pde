/* HANDLE PHYSICAL INPUT
     This method checks the current state of the switch and potentiometer.
     If the state has changed on either of these, then the new state data
     is routed to the appropriate functions that control the current mode
     and state of the color, or fun mode.
  */
void  handle_physical_input() {
    // check current mode based on switch state
    for(int i = 0; i < NUM_switches; i ++) {
        if (switches[i].available()) {
            new_mode = true;
            int cur_state = switches[i].get_state();
            if (i == ID_strobe_switch && cur_state == HIGH) {
                active_mode = MODE_fun;
                select_fun_mode();
            } else if (i == ID_color_switch && cur_state == HIGH) {
                active_mode = MODE_color;
                select_color();
            } else if (switches[i].get_state() == LOW) {
                active_mode = MODE_off;
            }   
        }
    }
  
    // check pot state and route value to appropriate function
    if (pot.available()) {
        if (active_mode == MODE_fun) {
            set_fun_mode(pot.get_state());
        }
        else if (active_mode == MODE_color) {
            set_color(pot.get_state());
        }
    }
}

/* SELECT COLOR METHOD
     This method is called whenever the switch is toggled to the color select side.
     The state of the color_control variable determines whether we are alternating
     between controls for different RGB, or HSB values. 
   */
void select_color() {
    if (color_control == 0) {
        active_rgb++;
        if (active_rgb >= NUM_color_ctrls) active_rgb = 0;
        blink_delay(active_rgb+1);
    }
    
    else if (color_control == 1) {
        active_hsb++;
        if (active_hsb >= NUM_color_ctrls) active_hsb = 0;  
        blink_delay(active_hsb+1);
    }
}

/* SELECT FUN MODE
     This method is called whenever the switch is toggled to the fun mode select side.
     When method is called it toggles between the strobe and scroll mode.
   */
void select_fun_mode() {
    fun_mode_control++;
    if (fun_mode_control >= NUM_fun_modes) fun_mode_control = 0;
    Serial.print("select fun mode ");
    Serial.println(fun_mode_control);
}

/* SET COLOR
    This method is used to set the active R, G, B variable, or H, S, B variable. 
    the color_control variable determines whether the color is being controlled
    in rgb or hsb mode. Then the color_active, and active_hsb variables define
    which specific parameter from either of these modes is currently controlled
    by the potentiometer.
  */
void set_color(int new_val) {
    if (color_control == 0) {
      if (check_soft_takeover(rgb_vals[active_rgb], new_val)) {   
          rgb_vals[active_rgb] = new_val;   
          if (new_val < 3) rgb_vals[active_rgb] = 0;
          save_colors();
      }
    }
    else if (color_control == 1) {
      if (check_soft_takeover(hsb_vals[active_hsb], new_val)) {   
          hsb_vals[active_hsb] = new_val;   
          int hue = map(hsb_vals[0], 0, 255, 0, 360);
          int sat = map(hsb_vals[2], 0, 255, 0, 100);
          int bright = map(hsb_vals[1], 0, 255, 0, 100);
          HSBtoRGB(hue, sat, bright, rgb_vals);
          save_colors();
      }
    }
}

/* SET FUN MODE
    This method is used to set the strobe or scroll speed depending on the 
    state of the active_fun_mode variable.
  */
void set_fun_mode(int new_val) {
    if (fun_mode_control == FUN_strobe) {
        strobe_interval = map(new_val, POT_output_min, POT_output_max, 5, 80);  
    }
    else if (fun_mode_control == FUN_scroll) {
        scroll_interval = map(new_val, POT_output_min, POT_output_max, 15, 200);    
    }
}

/* CHECK SOFT TAKEOVER
    This method is used to enable soft takeover behavior when switching
    the parameter that the potentiometer is controlling. 
  */
bool soft_takeover_complete = false;
int takeover_direction = 0;

boolean check_soft_takeover(int old_val, int new_val) {

   if (new_mode) {
        soft_takeover_complete = false;
        new_mode = false;
        if (new_val > old_val) takeover_direction = 1;
        else if (new_val < old_val) takeover_direction = -1;
        else soft_takeover_complete = true;
        return false;    
    }
    
    if (!soft_takeover_complete) {
        if (takeover_direction > 0 && (new_val < old_val + 20)) soft_takeover_complete = true;
        else if (takeover_direction < 0 && new_val > old_val - 20) soft_takeover_complete = true;
    }
    
    if (soft_takeover_complete) return true;
    
    return false;
}


