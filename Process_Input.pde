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
                active_mode = select_fun_mode_for_physical_ctrl();
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
        if (active_mode == MODE_strobe) { soft_set_strobe_speed(pot.get_state(), POT_output_min, POT_output_max); }
        else if (active_mode == MODE_scroll) { soft_set_scroll_speed(pot.get_state(), POT_output_min, POT_output_max);}
        else if (active_mode == MODE_color) { soft_set_hsb_color(p_control_hsb, pot.get_state(), POT_output_min, POT_output_max); }
    }
}


/********************* 
  SELECT COLOR PARAM FOR PHYSICAL CONTROL
     This method is called whenever the switch is toggled to the color select side.
     The state of the color_control variable determines whether we are alternating
     between controls for different RGB, or HSB values. 
   */
void select_color_param_for_physical_ctrl() {
        p_control_hsb++;
        if (p_control_hsb >= NUM_color_ctrls) p_control_hsb = 0;  
        blink_delay(p_control_hsb+1);
}


/********************* 
  SELECT FUN MODE FOR PHYSICAL CONTROL
     This method is called whenever the switch is toggled to the fun mode select side.
     When method is called it toggles between the strobe and scroll mode.
   */
int select_fun_mode_for_physical_ctrl() {
    if (p_control_strobe_scroll == MODE_strobe) p_control_strobe_scroll = MODE_scroll;
    else p_control_strobe_scroll = MODE_strobe;
    return p_control_strobe_scroll;
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
        new_mode = false;
        if (new_val > old_val) takeover_direction = 1;
        else if (new_val < old_val) takeover_direction = -1;
        else soft_takeover_complete = true;
        return false;    
    }
    
    if (!soft_takeover_complete) {
        if (takeover_direction == 1 && (new_val < old_val + 5)) soft_takeover_complete = true;
        else if (takeover_direction == -1 && (new_val > old_val - 5)) soft_takeover_complete = true;
    }
    
    if (soft_takeover_complete) return true;
    
    return false;
}
