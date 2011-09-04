/********************* 
  HANDLE PHYSICAL INPUT
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
                select_fun_mode_for_physical_ctrl();
            } else if (i == ID_color_switch && cur_state == HIGH) {
                active_mode = MODE_color;
                select_color_param_for_physical_ctrl();
            } else if (switches[i].get_state() == LOW) {
                active_mode = MODE_off;
            }   
        }
    }
  
    // check pot state and route value to appropriate function
    if (pot.available()) {
        if (active_mode == MODE_fun) {
            if (fun_mode_active == FUN_strobe) { soft_set_strobe(pot.get_state(), POT_output_min, POT_output_max); }
            else if (fun_mode_active == FUN_scroll) { soft_set_scroll(pot.get_state(), POT_output_min, POT_output_max);}

        }
        else if (active_mode == MODE_color) {
            if (color_mode == HSB) { soft_set_hsb_color(active_hsb, pot.get_state(), POT_output_min, POT_output_max); }
            else if (color_mode == RGB) { soft_set_rgb_color(active_hsb, pot.get_state(), POT_output_min, POT_output_max); }

        }
    }
}


/********************* 
  SELECT COLOR PARAM FOR PHYSICAL CONTROL
     This method is called whenever the switch is toggled to the color select side.
     The state of the color_control variable determines whether we are alternating
     between controls for different RGB, or HSB values. 
   */
void select_color_param_for_physical_ctrl() {
    if (color_mode == RGB) {
        active_rgb++;
        if (active_rgb >= NUM_color_ctrls) active_rgb = 0;
        blink_delay(active_rgb+1);
    }
    
    else if (color_mode == HSB) {
        active_hsb++;
        if (active_hsb >= NUM_color_ctrls) active_hsb = 0;  
        blink_delay(active_hsb+1);
    }
}


/********************* 
  SELECT FUN MODE FOR PHYSICAL CONTROL
     This method is called whenever the switch is toggled to the fun mode select side.
     When method is called it toggles between the strobe and scroll mode.
   */
void select_fun_mode_for_physical_ctrl() {
    fun_mode_active++;
    if (fun_mode_active >= NUM_fun_modes) fun_mode_active = 0;
}


/********************* 
  CHECK SOFT TAKEOVER
    Enables soft takeover behavior when switching the parameter that the potentiometer is controlling. 
  */
bool soft_takeover_complete = false;
int takeover_direction = 0;

boolean check_soft_takeover(int old_val, int new_val) {

   if (new_mode) {
        soft_takeover_complete = false;
//        new_mode = false;
        if (new_val > old_val) takeover_direction = 1;
        else if (new_val < old_val) takeover_direction = -1;
        else soft_takeover_complete = true;
//        return false;    
    }
    
    if (!soft_takeover_complete) {
        if (takeover_direction == 1 && (new_val < old_val + 5)) soft_takeover_complete = true;
        else if (takeover_direction == -1 && (new_val > old_val - 5)) soft_takeover_complete = true;
    }
    
    if (soft_takeover_complete) return true;
    
    return false;
}
